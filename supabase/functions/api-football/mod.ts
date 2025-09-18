// supabase/functions/api-football/mod.ts
// Deno (Supabase Edge Functions) – sincroniza API-FOOTBALL con Supabase
// Rutas:
//   GET  /health
//   POST /seed-fixtures?date=YYYY-MM-DD[&league=39,140,...][&season=2024]
//   POST /pick-match           body: { fixture_id: number, lock_minutes_before?: number }
//   POST /sync-live            (cron cada 1 min; también manual)
// Secrets necesarios: APIFOOTBALL_KEY (x-apisports-key)

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// ========= Config =========
const APIFOOTBALL_BASE = "https://v3.football.api-sports.io";
const API_KEY = Deno.env.get("APIFOOTBALL_KEY") || "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

if (!API_KEY) console.warn("[api-football] Missing APIFOOTBALL_KEY");
if (!SUPABASE_SERVICE_ROLE_KEY) console.warn("[api-football] Missing SERVICE ROLE key");

const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// ========= Helpers =========
async function afFetch(path: string, params: Record<string, any> = {}) {
  const url = new URL(APIFOOTBALL_BASE + path);
  Object.entries(params).forEach(([k, v]) => {
    if (v === undefined || v === null || v === "") return;
    url.searchParams.set(k, String(v));
  });

  const res = await fetch(url.toString(), {
    headers: { "x-apisports-key": API_KEY },
  });
  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`[AF] ${res.status} ${res.statusText} -> ${txt}`);
  }
  const json = await res.json();
  return json?.response ?? [];
}

async function countRedCards(fixtureId: number) {
  // API-FOOTBALL: /fixtures/events?fixture=ID
  const events = await afFetch("/fixtures/events", { fixture: fixtureId });
  let redHome = 0, redAway = 0;

  for (const ev of events ?? []) {
    const isCard = ev?.type === "Card";
    const isRed  = (ev?.detail === "Red Card") || (ev?.detail === "Second Yellow -> Red");
    if (!isCard || !isRed) continue;

    const teamSide = ev?.team?.id;
    if (teamSide) {
      // lo devolvemos como mapa { teamId -> reds } y resolvemos en upsertFixture
    }
  }

  // En este helper simple, volvemos a pedir el fixture para mapear team ids a home/away:
  const resp = await afFetch("/fixtures", { id: fixtureId });
  const fx = resp?.[0];
  const homeId = fx?.teams?.home?.id;
  const awayId = fx?.teams?.away?.id;

  // Reconteo por ids (más robusto):
  let reds: Record<number, number> = {};
  for (const ev of events ?? []) {
    if (ev?.type !== "Card") continue;
    const isRed  = (ev?.detail === "Red Card") || (ev?.detail === "Second Yellow -> Red");
    if (!isRed) continue;
    const teamId = ev?.team?.id;
    if (!teamId) continue;
    reds[teamId] = (reds[teamId] ?? 0) + 1;
  }

  redHome = homeId ? (reds[homeId] ?? 0) : 0;
  redAway = awayId ? (reds[awayId] ?? 0) : 0;

  return { redHome, redAway };
}

function normStatus(short?: string): "NS" | "LIVE" | "FT" {
  if (!short) return "NS";
  if (short === "NS" || short === "TBD" || short === "PST") return "NS";
  if (["FT", "AET", "PEN", "CANC"].includes(short)) return "FT";
  return "LIVE";
}

// ========= Upsert helpers =========
async function upsertLeague(l: any) {
  await sb.from("af_leagues").upsert({
    id: l.league.id,
    name: l.league.name,
    country: l.country?.name ?? null,
    logo: l.league.logo ?? null,
    type: l.league.type ?? null,
    seasons: l.seasons ? JSON.stringify(l.seasons) : "[]",
  });
}

async function upsertTeam(team: any) {
  await sb.from("af_teams").upsert({
    id: team.team.id,
    name: team.team.name,
    country: team.team.country ?? null,
    logo: team.team.logo ?? null,
  });
}

async function upsertFixture(fx, opts?: { redHome?: number; redAway?: number }) {
  const f = fx.fixture;
  const l = fx.league;
  const t = fx.teams;
  const g = fx.goals ?? {};
  const s = fx.score ?? {};
  const v = f.venue?.name ? `${f.venue.name}${f.venue.city ? " | " + f.venue.city : ""}` : null;

  await sb.from("af_fixtures").upsert({
    id: f.id,
    league_id: l.id,
    season: l.season,
    date: new Date(f.date).toISOString(),
    status_short: f.status?.short ?? null,
    status_long: f.status?.long ?? null,
    minute: f.status?.elapsed ?? null,
    referee: f.referee ?? null,
    venue: v,
    home_team_id: t.home?.id,
    away_team_id: t.away?.id,
    goals_home: g.home ?? null,
    goals_away: g.away ?? null,
    score_ht_home: s.halftime?.home ?? null,
    score_ht_away: s.halftime?.away ?? null,
    score_ft_home: s.fulltime?.home ?? null,
    score_ft_away: s.fulltime?.away ?? null,
    score_et_home: s.extratime?.home ?? null,
    score_et_away: s.extratime?.away ?? null,
    score_p_home: s.penalty?.home ?? null,
    score_p_away: s.penalty?.away ?? null,
    red_home: opts?.redHome ?? null,
    red_away: opts?.redAway ?? null,
    last_sync_at: new Date().toISOString()
  });
}

// ========= Actions =========

// 1) Pre-partido: pre-cargar fixtures de una fecha (y opcionalmente filtrar por ligas/temporada)
async function seedFixtures(date: string, leagues?: string, season?: string) {
  if (!date) throw new Error("date (YYYY-MM-DD) es requerido");

  // Traemos fixtures de ese día (puedes limitar por liga/season si quieres)
  const params: Record<string, string> = { date };
  if (leagues) params.league = leagues;  // "39,140,2" (CSV)
  if (season) params.season = season;

  const list = await afFetch("/fixtures", params);

  // Upsert de ligas, equipos y fixtures
  // NOTA: evitamos explosión de llamadas extra consultando /leagues o /teams;
  // aquí tomamos lo que viene embed en /fixtures.
  for (const fx of list) {
    try { await upsertLeague({ league: fx.league, seasons: [] }); } catch {}
    try { await upsertTeam({ team: { ...fx.teams.home, country: null, logo: fx.teams.home?.logo } }); } catch {}
    try { await upsertTeam({ team: { ...fx.teams.away, country: null, logo: fx.teams.away?.logo } }); } catch {}
    await upsertFixture(fx);
  }

  return { ok: true, count: list.length };
}

// 2) Selección del gestor: crear un match (tu tabla) desde un fixture
async function pickMatch(body: { fixture_id: number; lock_minutes_before?: number }) {
  if (!body?.fixture_id) throw new Error("fixture_id es requerido");
  const lockMin = Math.max(0, body.lock_minutes_before ?? 10);

  // Usamos la RPC (security definer) con service role
  const { data, error } = await sb.rpc("create_match_from_fixture", {
    p_fixture_id: body.fixture_id,
    p_lock_minutes_before: lockMin,
  });

  if (error) throw new Error(error.message);
  return { ok: true, match_id: data };
}

// 3) Durante/Post: sincronizar live/terminados para los matches “elegidos”
async function syncLiveNow() {
  // Buscamos matches vivos o a punto de arrancar/terminar (ventana ±3h)
  const now = new Date();
  const tmin = new Date(now.getTime() - 3 * 3600 * 1000).toISOString();
  const tmax = new Date(now.getTime() + 3 * 3600 * 1000).toISOString();

  // Tomamos solo los que tienen af_fixture_id
  const { data: ms, error } = await sb
    .from("matches")
    .select("id, af_fixture_id")
    .not("af_fixture_id", "is", null)
    .gte("start_time", tmin)
    .lte("start_time", tmax);
  if (error) throw new Error(error.message);

  const fixtureIds = (ms ?? []).map((m: any) => m.af_fixture_id);
  if (fixtureIds.length === 0) return { ok: true, updated: 0 };

  // API-FOOTBALL permite filtrar fixture por id=   (pero 1 por request).
  // Para eficiencia, agrupamos en paralelo con Promise.all (cuidando rate-limit).
  const chunks = chunk(fixtureIds, 20); // tamaño prudente
  let updated = 0;

  for (const ch of chunks) {
    // Solicitamos uno por uno dentro del chunk para respetar límites
    for (const fid of ch) {
      const resp = await afFetch("/fixtures", { id: fid });
      const fx = resp?.[0];
      if (!fx) continue;
      const reds = await countRedCards(fid);
      await upsertFixture(fx, { redHome: reds.redHome, redAway: reds.redAway });

      const short = fx.fixture?.status?.short;
      const goals = fx.goals ?? {};
      const minute = fx.fixture?.status?.elapsed ?? null;

      // Actualizamos el match “bonito” que usa el FE
      await sb.from("matches").update({
        status: normStatus(short),
        score_home: goals.home ?? null,
        score_away: goals.away ?? null,
        live_minute: minute,
        red_home: reds.redHome ?? null,
        red_away: reds.redAway ?? null,
        last_sync_at: new Date().toISOString()
      }).eq("af_fixture_id", fid);

      updated++;
    }
  }

  return { ok: true, updated };
}

function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

// ========= HTTP Entrypoint =========
Deno.serve(async (req) => {
  try {
    const url = new URL(req.url);
    const path = url.pathname.replace(/\/$/, "");

    // Health
    if (req.method === "GET" && path.endsWith("/health")) {
      return new Response(JSON.stringify({ ok: true }), { headers: { "content-type": "application/json" } });
    }

    // Seed fixtures (pre-partido)
    if (req.method === "POST" && path.endsWith("/seed-fixtures")) {
      const date = url.searchParams.get("date") || "";
      const leagues = url.searchParams.get("league") || undefined; // CSV opcional
      const season = url.searchParams.get("season") || undefined;
      const res = await seedFixtures(date, leagues, season);
      return json(res);
    }

    // Pick match (gestor)
    if (req.method === "POST" && path.endsWith("/pick-match")) {
      const body = await req.json().catch(() => ({}));
      const res = await pickMatch(body);
      return json(res);
    }

    // Sync live/post (cron o manual)
    if (req.method === "POST" && path.endsWith("/sync-live")) {
      const res = await syncLiveNow();
      return json(res);
    }

    // Cron (Supabase Scheduler) – hit raíz de la función
    // Puedes programar que la función se ejecute y por defecto correr sync
    if (req.method === "GET" && path.endsWith("/api-football")) {
      const res = await syncLiveNow();
      return json(res);
    }

    return new Response("Not found", { status: 404 });
  } catch (e) {
    console.error("[api-football] error:", e);
    return new Response(JSON.stringify({ ok: false, error: String(e.message || e) }), {
      status: 500,
      headers: { "content-type": "application/json" },
    });
  }
});

function json(obj: unknown, status = 200) {
  return new Response(JSON.stringify(obj), { status, headers: { "content-type": "application/json" } });
}

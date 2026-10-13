import { createSupabaseContext } from 'npm:@supabase/server@1'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Cache-Control': 'no-store',
}

const reply = (status: number, body: Record<string, unknown>) =>
  Response.json(body, { status, headers: cors })

const coordinate = (value: unknown, min: number, max: number): value is number =>
  typeof value === 'number' && Number.isFinite(value) && value >= min && value <= max

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response(null, { headers: cors })
  if (request.method !== 'POST') return reply(405, { error: 'method_not_allowed' })

  const { error: authError } = await createSupabaseContext(request, { auth: 'user' })
  if (authError) return reply(401, { error: 'unauthorized' })

  let input: Record<string, unknown>
  try {
    input = await request.json()
  } catch {
    return reply(400, { error: 'invalid_request' })
  }
  const { startLatitude, startLongitude, endLatitude, endLongitude } = input
  if (!coordinate(startLatitude, -90, 90) ||
      !coordinate(startLongitude, -180, 180) ||
      !coordinate(endLatitude, -90, 90) ||
      !coordinate(endLongitude, -180, 180)) {
    return reply(400, { error: 'invalid_coordinates' })
  }

  const key = Deno.env.get('KAKAO_REST_API_KEY')
  if (!key) return reply(503, { error: 'service_unavailable' })

  const url = new URL('https://dapi.kakao.com/v2/routing/publictraffic')
  url.search = new URLSearchParams({
    start_x: String(startLongitude),
    start_y: String(startLatitude),
    end_x: String(endLongitude),
    end_y: String(endLatitude),
  }).toString()

  try {
    const provider = await fetch(url, {
      headers: { Authorization: `KakaoAK ${key}` },
      signal: AbortSignal.timeout(8000),
    })
    if (!provider.ok) return reply(502, { error: 'provider_unavailable' })
    const data = await provider.json()
    if (data?.status !== 'OK' || !Array.isArray(data?.routes)) {
      return reply(200, { status: String(data?.status ?? 'NO_RESULTS'), routes: [] })
    }
    const routes = data.routes.slice(0, 5).map((route: Record<string, unknown>) => {
      const properties = route.properties as Record<string, unknown> | undefined
      const steps = Array.isArray(route.steps) ? route.steps : []
      return {
        type: properties?.type,
        totalTime: properties?.totalTime,
        transfers: properties?.transfers,
        fare: properties?.fare,
        steps: steps.map((step: Record<string, unknown>) => ({
          properties: step.properties,
        })),
      }
    })
    return reply(200, { status: 'OK', routes })
  } catch {
    return reply(502, { error: 'provider_unavailable' })
  }
})

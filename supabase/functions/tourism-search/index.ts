import { createSupabaseContext } from 'npm:@supabase/server@1'

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Cache-Control': 'no-store',
}

const reply = (status: number, body: Record<string, unknown>) =>
  Response.json(body, { status, headers: cors })

type TourItem = Record<string, unknown>

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
  const keyword = typeof input.keyword === 'string' ? input.keyword.trim() : ''
  const language = input.language
  if (keyword.length < 2 || keyword.length > 80 || !['en', 'ja'].includes(String(language))) {
    return reply(400, { error: 'invalid_request' })
  }

  const serviceKey = Deno.env.get('TOUR_API_SERVICE_KEY')
  if (!serviceKey) return reply(503, { error: 'service_unavailable' })

  const service = language === 'ja' ? 'JpnService2' : 'EngService2'
  const url = new URL(`https://apis.data.go.kr/B551011/${service}/searchKeyword2`)
  url.search = new URLSearchParams({
    serviceKey,
    MobileOS: 'ETC',
    MobileApp: 'NextMate',
    _type: 'json',
    numOfRows: '20',
    pageNo: '1',
    keyword,
  }).toString()

  try {
    const response = await fetch(url, { signal: AbortSignal.timeout(8000) })
    if (!response.ok) return reply(502, { error: 'provider_unavailable' })
    const payload = await response.json()
    const wrapper = payload?.response
    if (wrapper?.header?.resultCode !== '0000') {
      return reply(502, { error: 'provider_unavailable' })
    }
    const rawItems = wrapper?.body?.items?.item
    const items: TourItem[] = Array.isArray(rawItems)
      ? rawItems
      : rawItems && typeof rawItems === 'object' ? [rawItems] : []
    const places = items.flatMap((item) => {
      if (item.mapy == null || String(item.mapy).trim() === '' ||
          item.mapx == null || String(item.mapx).trim() === '') return []
      const latitude = Number(item.mapy)
      const longitude = Number(item.mapx)
      const contentId = String(item.contentid ?? '')
      const name = String(item.title ?? '').trim()
      const address = String(item.addr1 ?? '').trim()
      if (!/^\d{1,30}$/.test(contentId) || !name || !address ||
          !Number.isFinite(latitude) || latitude < -90 || latitude > 90 ||
          !Number.isFinite(longitude) || longitude < -180 || longitude > 180) return []
      return [{ contentId, language, name, address, latitude, longitude }]
    })
    return reply(200, { places })
  } catch {
    return reply(502, { error: 'provider_unavailable' })
  }
})

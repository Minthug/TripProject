part of '../../main.dart';

/// Route choices for an authenticated itinerary item. Never reuses the
/// gallery's sample times or fares as if they were live estimates.
class LiveRouteComparisonScreen extends StatefulWidget {
  const LiveRouteComparisonScreen({
    super.key,
    required this.backend,
    required this.data,
    required this.destinationItem,
    this.onUndo,
    this.originPlace,
    this.uberInstalled = false,
  });

  final NextMateBackend backend;
  final LiveTripData data;
  final Json destinationItem;
  final Json? originPlace;
  final bool uberInstalled;
  final Future<bool> Function()? onUndo;

  @override
  State<LiveRouteComparisonScreen> createState() =>
      _LiveRouteComparisonScreenState();
}

class _LiveRouteComparisonScreenState extends State<LiveRouteComparisonScreen> {
  late Future<List<Json>> _routesFuture;

  @override
  void initState() {
    super.initState();
    _routesFuture = _loadRoutes();
  }

  Future<List<Json>> _loadRoutes() async {
    final destination = widget.data.places[widget.destinationItem['place_id']];
    final latitude = destination?['latitude'];
    final longitude = destination?['longitude'];
    final originLatitude = widget.originPlace?['latitude'];
    final originLongitude = widget.originPlace?['longitude'];
    if (latitude is! num ||
        longitude is! num ||
        originLatitude is! num ||
        originLongitude is! num) {
      return const [];
    }
    final rows = await widget.backend.routes.list(
      widget.data.trip.id,
      limit: 100,
    );
    final now = DateTime.now();
    return rows.where((route) {
      if (route['itinerary_item_id'] != widget.destinationItem['id']) {
        return false;
      }
      final expiry = DateTime.tryParse(route['expires_at'] as String? ?? '');
      if (expiry != null && expiry.isBefore(now)) return false;
      final routeLatitude = route['destination_latitude'];
      final routeLongitude = route['destination_longitude'];
      final routeOriginLatitude = route['origin_latitude'];
      final routeOriginLongitude = route['origin_longitude'];
      return routeLatitude is num &&
          routeLongitude is num &&
          routeOriginLatitude is num &&
          routeOriginLongitude is num &&
          (routeLatitude - latitude).abs() < .0005 &&
          (routeLongitude - longitude).abs() < .0005 &&
          (routeOriginLatitude - originLatitude).abs() < .0005 &&
          (routeOriginLongitude - originLongitude).abs() < .0005;
    }).toList()..sort(
      (a, b) => (b['created_at'] as String? ?? '').compareTo(
        a['created_at'] as String? ?? '',
      ),
    );
  }

  Json? _latestRoute(List<Json> routes, Set<String> modes) {
    for (final route in routes) {
      if (modes.contains(route['travel_mode'])) return route;
    }
    return null;
  }

  String _duration(Json? route) {
    final seconds = route?['duration_seconds'];
    return seconds is num ? '약 ${(seconds / 60).ceil()}분' : '조회 전';
  }

  String _cost(Json? route) {
    final minimum = route?['estimated_cost_min'];
    final maximum = route?['estimated_cost_max'];
    if (minimum is! num) return '요금 정보 없음';
    final currency = route?['currency_code'] == 'KRW'
        ? '₩'
        : '${route?['currency_code'] ?? ''} ';
    final low = '$currency${minimum.round()}';
    return maximum is num && maximum != minimum
        ? '$low~${maximum.round()}'
        : low;
  }

  void _showTransitRoutes() {
    final destination = widget.data.places[widget.destinationItem['place_id']];
    final startLatitude = widget.originPlace?['latitude'];
    final startLongitude = widget.originPlace?['longitude'];
    final endLatitude = destination?['latitude'];
    final endLongitude = destination?['longitude'];
    final hasCoordinates =
        startLatitude is num &&
        startLongitude is num &&
        endLatitude is num &&
        endLongitude is num;
    final routes = hasCoordinates
        ? widget.backend.transitRouting.findRoutes(
            startLatitude: startLatitude.toDouble(),
            startLongitude: startLongitude.toDouble(),
            endLatitude: endLatitude.toDouble(),
            endLongitude: endLongitude.toDouble(),
          )
        : null;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .72,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('대중교통 경로', style: _sectionTitle),
                const SizedBox(height: 8),
                Text(
                  '${widget.originPlace?['display_name'] ?? '출발지 미등록'} → ${widget.data.placeName(widget.destinationItem)}',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: routes == null
                      ? const Center(
                          child: Text(
                            '출발지 또는 목적지의 위치가 등록되지 않았어요. 일정에서 정확한 장소를 선택해 주세요.',
                          ),
                        )
                      : FutureBuilder<List<Json>>(
                          future: routes,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData && !snapshot.hasError) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('경로를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.'),
                              );
                            }
                            final found = snapshot.data!;
                            if (found.isEmpty) {
                              return const Center(
                                child: Text('이 구간의 대중교통 경로를 찾지 못했어요.'),
                              );
                            }
                            return ListView.separated(
                              itemCount: found.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) =>
                                  _transitRouteCard(found[index], index),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _transitRouteCard(Json route, int index) {
    final fare = route['fare'];
    final fareValue = fare is Map ? fare['value'] : null;
    final steps = route['steps'] is List ? route['steps'] as List : const [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '경로 ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '약 ${((route['totalTime'] as num? ?? 0) / 60).ceil()}분 · ${fareValue is num ? '${fareValue.round()}원' : '요금 정보 없음'} · 환승 ${route['transfers'] ?? 0}회',
          ),
          const SizedBox(height: 12),
          for (final step in steps)
            if (step is Map && step['properties'] is Map)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _transitStepText(
                    Map<String, dynamic>.from(step['properties'] as Map),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _transitStepText(Json properties) {
    final type = switch (properties['type']) {
      'BUS' => '버스',
      'SUBWAY' => '지하철',
      _ => '도보',
    };
    final vehicles = properties['vehicles'];
    final vehicleNames = vehicles is List
        ? vehicles
              .whereType<Map>()
              .map((vehicle) => vehicle['name'])
              .whereType<String>()
              .join(' · ')
        : '';
    final guidance = properties['guidance'] as String? ?? '';
    return '$type${vehicleNames.isEmpty ? '' : ' $vehicleNames'}${guidance.isEmpty ? '' : ' · $guidance'}';
  }

  Future<void> _openUber() async {
    final destination = widget.data.places[widget.destinationItem['place_id']];
    final latitude = destination?['latitude'];
    final longitude = destination?['longitude'];
    final hasCoordinates = latitude is num && longitude is num;
    final name = widget.data.placeName(widget.destinationItem);
    final address = destination?['formatted_address'] as String?;
    try {
      final uri = !hasCoordinates
          ? uberAppUri
          : uberRideRequestUri(
              destinationName: name,
              destinationLatitude: latitude.toDouble(),
              destinationLongitude: longitude.toDouble(),
              destinationAddress: address,
            );
      var opened = false;
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        // No Uber handler: offer Uber's official install page below.
      }
      if (!opened) {
        final installOpened = await launchUrl(
          uberDownloadUri,
          mode: LaunchMode.externalApplication,
        );
        if (!installOpened && mounted) {
          _liveNotice(context, 'Uber 설치 안내를 열지 못했어요.');
        }
      }
    } catch (_) {
      if (mounted) _liveNotice(context, 'Uber를 열지 못했어요.');
    }
  }

  void _showUberAction() {
    final destination = widget.data.places[widget.destinationItem['place_id']];
    final hasCoordinates =
        destination?['latitude'] is num && destination?['longitude'] is num;
    final name = widget.data.placeName(widget.destinationItem);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Uber 차량 요청',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                hasCoordinates
                    ? 'Uber 앱에 목적지를 전달합니다. 정확한 승차 위치와 요금은 Uber에서 확인해 주세요.'
                    : '저장된 좌표가 없어 Uber에 목적지를 자동 입력할 수 없어요. 앱에서 $name을(를) 직접 검색해 주세요.',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _openUber();
                  },
                  icon: const Icon(Icons.local_taxi_rounded),
                  label: const Text('Uber 열기 / 설치 안내'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.data.places[widget.destinationItem['place_id']];
    final destinationName = widget.data.placeName(widget.destinationItem);
    final originName =
        widget.originPlace?['display_name'] as String? ?? '현재 위치 확인 전';
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: FutureBuilder<List<Json>>(
          future: _routesFuture,
          builder: (context, snapshot) {
            final routes = snapshot.data ?? const <Json>[];
            final transit = _latestRoute(routes, {'transit'});
            final taxi = _latestRoute(routes, {'uber', 'driving'});
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: '일정으로 돌아가기',
                  ),
                  const SizedBox(height: 14),
                  const Text('다음 장소 이동수단 비교', style: _sectionTitle),
                  const SizedBox(height: 8),
                  Text(
                    '$originName → $destinationName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    destination?['formatted_address'] as String? ??
                        '도착지 주소 확인 전',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 24),
                  if (snapshot.connectionState != ConnectionState.done)
                    const LinearProgressIndicator()
                  else if (snapshot.hasError)
                    const Text('저장된 경로를 불러오지 못했어요. 아래 이동수단 정보는 조회 전 상태입니다.')
                  else if (routes.isEmpty)
                    const Text(
                      '대중교통 카드를 누르면 앱 안에서 경로를 조회해요. 택시 예상 요금은 아직 연결되지 않았어요.',
                    ),
                  const SizedBox(height: 18),
                  _liveModeCard(
                    key: const ValueKey('transit-mode-card'),
                    icon: Icons.directions_subway_rounded,
                    title: '대중교통',
                    duration: _duration(transit),
                    cost: _cost(transit),
                    detail: transit == null
                        ? '버스·지하철 경로 조회 전'
                        : '저장된 예상 경로 · 실시간 아님',
                    onTap: _showTransitRoutes,
                  ),
                  const SizedBox(height: 10),
                  _liveModeCard(
                    key: const ValueKey('taxi-mode-card'),
                    icon: Icons.local_taxi_rounded,
                    title: '택시 / Uber',
                    duration: _duration(taxi),
                    cost: _cost(taxi),
                    detail: taxi == null
                        ? widget.uberInstalled
                              ? '택시 경로·요금 조회 전'
                              : '택시 경로 조회 전 · Uber 설치 확인 필요'
                        : '저장된 예상 경로 · 실시간 아님',
                    onTap: _showUberAction,
                  ),
                  const Spacer(),
                  if (widget.onUndo != null)
                    OutlinedButton.icon(
                      onPressed: () async {
                        final restored = await widget.onUndo!();
                        if (restored && context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('방문 상태 되돌리기'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _liveModeCard({
    required Key key,
    required IconData icon,
    required String title,
    required String duration,
    required String cost,
    required String detail,
    required VoidCallback onTap,
  }) => InkWell(
    key: key,
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('예상 시간 $duration · 예상 비용 $cost'),
          const SizedBox(height: 5),
          Text(
            detail,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

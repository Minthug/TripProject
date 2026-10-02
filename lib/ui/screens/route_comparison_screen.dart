part of '../../main.dart';

enum _TravelMode { uber, transit, walk }

enum _TransitRouteKind { subway, bus }

class RouteComparisonScreen extends StatefulWidget {
  const RouteComparisonScreen({super.key, this.uberInstalled = true});

  final bool uberInstalled;

  @override
  State<RouteComparisonScreen> createState() => _RouteComparisonScreenState();
}

class _RouteComparisonScreenState extends State<RouteComparisonScreen> {
  _TravelMode selected = _TravelMode.transit;
  _TransitRouteKind transitRoute = _TransitRouteKind.subway;

  void _continue() {
    switch (selected) {
      case _TravelMode.uber:
        if (widget.uberInstalled) {
          _showUberHandoff(context);
        } else {
          _showPrototypeMessage(
            context,
            message: 'Uber 앱스토어 페이지를 열 준비가 되었습니다.',
          );
        }
        return;
      case _TravelMode.transit:
        _openTransitGuide(context);
        return;
      case _TravelMode.walk:
        _showPrototypeMessage(context, message: '도보 길안내를 시작할 준비가 되었습니다.');
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AppHeader(
              title: 'Choose how to go',
              subtitle: 'Live estimates · Updated now',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: _RouteDots(),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RouteAddress(
                          label: 'FROM',
                          title: 'Bukchon Hanok Village',
                          detail: '북촌한옥마을 · Current location',
                        ),
                        SizedBox(height: 15),
                        _RouteAddress(
                          label: 'TO',
                          title: 'MMCA Seoul',
                          detail: '국립현대미술관 서울 · Main entrance',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),
            const Row(
              children: [
                Expanded(
                  child: Text('Compare time & cost', style: _sectionTitle),
                ),
                Text(
                  'Leave 1:32 PM',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _TransportOptionCard(
              selected: selected == _TravelMode.uber,
              available: widget.uberInstalled,
              icon: Icons.local_taxi_rounded,
              title: 'Uber',
              badge: widget.uberInstalled ? 'FASTEST' : 'APP NEEDED',
              duration: '17–22 min',
              arrival: widget.uberInstalled
                  ? 'Arrive 1:49–1:54 PM'
                  : 'Uber is not installed',
              cost: '₩13,000–17,000',
              note: widget.uberInstalled
                  ? 'Pickup 3 min away · Traffic included'
                  : 'Install Uber to request this ride',
              onTap: () => setState(() => selected = _TravelMode.uber),
            ),
            if (selected == _TravelMode.uber && !widget.uberInstalled) ...[
              const SizedBox(height: 8),
              _UberUnavailableNotice(
                onUseTransit: () =>
                    setState(() => selected = _TravelMode.transit),
              ),
            ],
            const SizedBox(height: 9),
            _TransportOptionCard(
              selected: selected == _TravelMode.transit,
              icon: transitRoute == _TransitRouteKind.subway
                  ? Icons.directions_subway_rounded
                  : Icons.directions_bus_rounded,
              title: 'Public transit',
              badge: 'BEST VALUE',
              duration: transitRoute == _TransitRouteKind.subway
                  ? '29 min'
                  : '24 min',
              arrival: transitRoute == _TransitRouteKind.subway
                  ? 'Arrive 2:01 PM'
                  : 'Arrive 1:56 PM',
              cost: '₩1,500',
              note: transitRoute == _TransitRouteKind.subway
                  ? 'Subway Line 3 · 1 stop · 14 min walk'
                  : 'Bus 11 · 5 stops · 4 min walk',
              onTap: () => setState(() => selected = _TravelMode.transit),
            ),
            if (selected == _TravelMode.transit) ...[
              const SizedBox(height: 8),
              _TransitRoutePreview(
                selected: transitRoute,
                onChanged: (value) => setState(() => transitRoute = value),
              ),
            ],
            const SizedBox(height: 9),
            _TransportOptionCard(
              selected: selected == _TravelMode.walk,
              icon: Icons.directions_walk_rounded,
              title: 'Walk',
              badge: 'NO FARE',
              duration: '31 min',
              arrival: 'Arrive 2:03 PM',
              cost: 'Free',
              note: '2.1 km · Some uphill sections',
              onTap: () => setState(() => selected = _TravelMode.walk),
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Times and fares are estimates and may change with traffic or service conditions.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _PrimaryAction(
              label: switch (selected) {
                _TravelMode.uber =>
                  widget.uberInstalled ? 'Prepare Uber' : 'Install Uber',
                _TravelMode.transit => 'View transit steps',
                _TravelMode.walk => 'Start walking directions',
              },
              icon: Icons.arrow_forward_rounded,
              background: AppColors.green,
              foreground: Colors.white,
              onTap: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitRoutePreview extends StatelessWidget {
  const _TransitRoutePreview({required this.selected, required this.onChanged});

  final _TransitRouteKind selected;
  final ValueChanged<_TransitRouteKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final subway = selected == _TransitRouteKind.subway;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F7),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _TransitRouteTab(
                  selected: subway,
                  icon: Icons.directions_subway_rounded,
                  title: 'Subway · Line 3',
                  detail: '29 min',
                  onTap: () => onChanged(_TransitRouteKind.subway),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _TransitRouteTab(
                  selected: !subway,
                  icon: Icons.directions_bus_rounded,
                  title: 'Bus · No. 11',
                  detail: '24 min',
                  onTap: () => onChanged(_TransitRouteKind.bus),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  subway
                      ? 'Line 3 toward Daehwa'
                      : 'Bus 11 toward Seoul Station',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                subway ? '1 stop' : '5 stops',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: subway
                ? const _TransitPointMap(
                    key: ValueKey('subway-map'),
                    color: Color(0xFFF06A24),
                    points: [
                      _TransitMapPoint(
                        'Walk 6m',
                        '도보',
                        Icons.directions_walk_rounded,
                      ),
                      _TransitMapPoint('Anguk', '안국', '3'),
                      _TransitMapPoint('Gyeongbokgung', '경복궁', '3'),
                      _TransitMapPoint('Walk 8m', 'MMCA', Icons.flag_rounded),
                    ],
                  )
                : const _TransitPointMap(
                    key: ValueKey('bus-map'),
                    color: Color(0xFF2E6FAD),
                    points: [
                      _TransitMapPoint(
                        'Bukchon',
                        '정류장',
                        Icons.directions_walk_rounded,
                      ),
                      _TransitMapPoint(
                        'Anguk',
                        '안국역',
                        Icons.directions_bus_rounded,
                      ),
                      _TransitMapPoint(
                        '5 stops',
                        '직행',
                        Icons.more_horiz_rounded,
                      ),
                      _TransitMapPoint('MMCA', '서울관', Icons.flag_rounded),
                    ],
                  ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                subway
                    ? Icons.sync_alt_rounded
                    : Icons.check_circle_outline_rounded,
                size: 14,
                color: AppColors.green,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  subway
                      ? 'Orange signs · No transfer · Exit 6'
                      : 'Blue bus · No transfer · Get off at MMCA',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransitRouteTab extends StatelessWidget {
  const _TransitRouteTab({
    required this.selected,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.deepGreen : Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? AppColors.deepGreen : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.green,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      color: selected ? Colors.white60 : AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitMapPoint {
  const _TransitMapPoint(this.title, this.local, this.marker);

  final String title;
  final String local;
  final Object marker;
}

class _UberUnavailableNotice extends StatelessWidget {
  const _UberUnavailableNotice({required this.onUseTransit});

  final VoidCallback onUseTransit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE6B7AB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.mobile_off_rounded,
            color: Color(0xFFB64B43),
            size: 19,
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uber app required',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 2),
                Text(
                  'Install Uber to request this ride. You can still compare the estimate.',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: onUseTransit,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Use transit'),
          ),
        ],
      ),
    );
  }
}

class _TransitPointMap extends StatelessWidget {
  const _TransitPointMap({
    super.key,
    required this.color,
    required this.points,
  });

  final Color color;
  final List<_TransitMapPoint> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: Stack(
        children: [
          Positioned(
            left: 35,
            right: 35,
            top: 13,
            child: Container(height: 4, color: color.withValues(alpha: .7)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points
                .map(
                  (point) => Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 29,
                          height: 29,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 3),
                          ),
                          child: point.marker is IconData
                              ? Icon(
                                  point.marker as IconData,
                                  size: 13,
                                  color: color,
                                )
                              : Text(
                                  point.marker as String,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          point.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          point.local,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TransportOptionCard extends StatelessWidget {
  const _TransportOptionCard({
    required this.selected,
    this.available = true,
    required this.icon,
    required this.title,
    required this.badge,
    required this.duration,
    required this.arrival,
    required this.cost,
    required this.note,
    required this.onTap,
  });

  final bool selected;
  final bool available;
  final IconData icon;
  final String title;
  final String badge;
  final String duration;
  final String arrival;
  final String cost;
  final String note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: !available
                ? const Color(0xFFFFF8F5)
                : selected
                ? AppColors.paleGreen
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: !available
                  ? const Color(0xFFE6B7AB)
                  : selected
                  ? AppColors.green
                  : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: available
                          ? AppColors.green
                          : const Color(0xFFB64B43),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 7,
                          runSpacing: 3,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: !available
                                    ? const Color(0xFFFFE4DE)
                                    : selected
                                    ? AppColors.green
                                    : const Color(0xFFF0F2EF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  color: !available
                                      ? const Color(0xFFB64B43)
                                      : selected
                                      ? Colors.white
                                      : AppColors.muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          arrival,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selected ? AppColors.green : AppColors.muted,
                    size: 19,
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  _EstimateValue(label: 'TIME', value: duration),
                  Container(width: 1, height: 30, color: AppColors.line),
                  _EstimateValue(label: 'EST. COST', value: cost),
                ],
              ),
              const SizedBox(height: 9),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  note,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstimateValue extends StatelessWidget {
  const _EstimateValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

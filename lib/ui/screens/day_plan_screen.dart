part of '../../main.dart';

class FlexibleDayPlanScreen extends StatefulWidget {
  const FlexibleDayPlanScreen({super.key});

  @override
  State<FlexibleDayPlanScreen> createState() => _FlexibleDayPlanScreenState();
}

class _FlexibleDayPlanScreenState extends State<FlexibleDayPlanScreen> {
  final List<int> order = [0, 1, 2, 3];
  bool palaceMoved = false;
  bool orderSuggested = false;

  static const places = [
    _DayPlace(
      id: 0,
      title: 'MMCA Seoul',
      local: '국립현대미술관 서울',
      hours: 'Open · Closes 6:00 PM',
      note: 'Go first · Last admission 5:00 PM',
      availability: _PlaceAvailability.closing,
      icon: Icons.account_balance_rounded,
    ),
    _DayPlace(
      id: 1,
      title: 'Gyeongbokgung Palace',
      local: '경복궁',
      hours: 'Closed on Tuesdays',
      note: 'Open Wed 9:00 AM–6:00 PM',
      availability: _PlaceAvailability.closed,
      icon: Icons.temple_buddhist_rounded,
    ),
    _DayPlace(
      id: 2,
      title: 'Myeongdong Cathedral',
      local: '명동성당',
      hours: 'Open · Closes 7:00 PM',
      note: 'No fixed visit time',
      availability: _PlaceAvailability.open,
      icon: Icons.church_rounded,
    ),
    _DayPlace(
      id: 3,
      title: 'N Seoul Tower',
      local: '남산서울타워',
      hours: 'Open · Closes 11:00 PM',
      note: 'Good for the evening',
      availability: _PlaceAvailability.open,
      icon: Icons.landscape_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleOrder = order
        .where((id) => !(palaceMoved && id == 1))
        .toList();
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tuesday, Sep 15',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Seoul · Today',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showPrototypeMessage(context),
                icon: const Icon(Icons.more_horiz_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Places for today',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'No timetable. Go at your own pace.',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: palaceMoved
                  ? AppColors.paleGreen
                  : const Color(0xFFFFF2D7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  palaceMoved
                      ? Icons.check_circle_rounded
                      : Icons.error_rounded,
                  size: 17,
                  color: palaceMoved
                      ? AppColors.green
                      : const Color(0xFFC88300),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    palaceMoved
                        ? 'All places are available today'
                        : '1 place is closed today',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (orderSuggested)
                  const Text(
                    'Best order applied',
                    style: TextStyle(fontSize: 11, color: AppColors.green),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ReorderableListView.builder(
              padding: EdgeInsets.zero,
              buildDefaultDragHandles: false,
              itemCount: visibleOrder.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final movedId = visibleOrder.removeAt(oldIndex);
                  visibleOrder.insert(newIndex, movedId);
                  final hidden = palaceMoved ? [1] : <int>[];
                  order
                    ..clear()
                    ..addAll(visibleOrder)
                    ..addAll(hidden);
                  orderSuggested = false;
                });
              },
              itemBuilder: (context, index) {
                final place = places[visibleOrder[index]];
                return Padding(
                  key: ValueKey(place.id),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DayPlaceCard(
                    index: index,
                    place: place,
                    onMoveDay: place.availability == _PlaceAvailability.closed
                        ? () => setState(() => palaceMoved = true)
                        : null,
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openPlaceExplorer(context),
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('Add place'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => setState(() => orderSuggested = true),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                  label: const Text('Suggest order'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deepGreen,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _PrimaryAction(
            label: 'Return to L7 Myeongdong',
            icon: Icons.home_rounded,
            background: const Color(0xFFF7F0D5),
            foreground: AppColors.ink,
            onTap: () => _showReturnToStaySheet(context),
          ),
        ],
      ),
    );
  }
}

enum _PlaceAvailability { open, closing, closed }

class _DayPlace {
  const _DayPlace({
    required this.id,
    required this.title,
    required this.local,
    required this.hours,
    required this.note,
    required this.availability,
    required this.icon,
  });

  final int id;
  final String title;
  final String local;
  final String hours;
  final String note;
  final _PlaceAvailability availability;
  final IconData icon;
}

class _DayPlaceCard extends StatelessWidget {
  const _DayPlaceCard({
    required this.index,
    required this.place,
    this.onMoveDay,
  });

  final int index;
  final _DayPlace place;
  final VoidCallback? onMoveDay;

  @override
  Widget build(BuildContext context) {
    final closed = place.availability == _PlaceAvailability.closed;
    final closing = place.availability == _PlaceAvailability.closing;
    final accent = closed
        ? const Color(0xFFB64B43)
        : closing
        ? const Color(0xFFC88300)
        : AppColors.green;
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 10, 10),
      decoration: BoxDecoration(
        color: closed ? const Color(0xFFFFF5F3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: closed ? const Color(0xFFF0C3BE) : AppColors.line,
        ),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 16),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 18,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: closed ? const Color(0xFFFFE4E0) : AppColors.paleGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(place.icon, size: 19, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${place.local} · ${place.hours}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: closed ? accent : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  place.note,
                  style: TextStyle(
                    fontSize: 11,
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onMoveDay != null)
            TextButton(
              onPressed: onMoveDay,
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'Move to Wed',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            )
          else
            const Icon(Icons.chevron_right_rounded, size: 18),
        ],
      ),
    );
  }
}

void _showReturnToStaySheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ReturnToStaySheet(),
  );
}

class _ReturnToStaySheet extends StatelessWidget {
  const _ReturnToStaySheet();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 11, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Return to your stay',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              const Text(
                'L7 Myeongdong · L7 명동 바이 롯데',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              _ReturnModeTile(
                icon: Icons.directions_subway_rounded,
                title: 'Public transit',
                detail: '27 min · No transfers',
                trailing: '₩1,500',
                recommended: true,
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const Scaffold(body: TouristTransitGuideScreen()),
                    ),
                  );
                },
              ),
              const SizedBox(height: 9),
              _ReturnModeTile(
                icon: Icons.local_taxi_rounded,
                title: 'Uber Taxi',
                detail: '18 min · Pickup nearby',
                trailing: 'Open Uber',
                onTap: () => _showPrototypeMessage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReturnModeTile extends StatelessWidget {
  const _ReturnModeTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.trailing,
    required this.onTap,
    this.recommended = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String trailing;
  final VoidCallback onTap;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: recommended ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: recommended ? AppColors.green : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.green, size: 21),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (recommended) ...[
                        const Text(
                          'Recommended',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

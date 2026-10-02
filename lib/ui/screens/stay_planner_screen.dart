part of '../../main.dart';

class StayBasedPlannerScreen extends StatefulWidget {
  const StayBasedPlannerScreen({super.key});

  @override
  State<StayBasedPlannerScreen> createState() => _StayBasedPlannerScreenState();
}

class _StayBasedPlannerScreenState extends State<StayBasedPlannerScreen> {
  int selectedStay = 0;
  final Set<int> addedPlaces = {0};

  static const _recommendations = [
    [
      ('Myeongdong Cathedral', '명동성당', '8 min walk', 'Easy first-day stop'),
      ('N Seoul Tower', '남산서울타워', '22 min transit', 'Best after 6 PM'),
      ('Namdaemun Market', '남대문시장', '15 min walk', 'Breakfast favorite'),
    ],
    [
      ('Gyeongbokgung Palace', '경복궁', '9 min walk', 'Go before 10 AM'),
      ('MMCA Seoul', '국립현대미술관 서울', '7 min walk', 'Closed at 6 PM'),
      ('Bukchon Hanok Village', '북촌한옥마을', '6 min walk', 'Quiet morning route'),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final places = _recommendations[selectedStay];
    final stayName = selectedStay == 0 ? 'L7 Myeongdong' : 'Bukchon Hanok Stay';
    return _PhonePage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: Navigator.of(context).canPop()
                      ? () => Navigator.pop(context)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Build your trip',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: AddStayMapScreen()),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Stay'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.green,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Plan around your stays',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Seoul · Sep 14–18 · 4 nights',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            const _StayTimeline(),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: _StaySelector(
                    selected: selectedStay == 0,
                    title: 'L7 Myeongdong',
                    dates: 'Sep 14–16 · 2 nights',
                    onTap: () => setState(() => selectedStay = 0),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _StaySelector(
                    selected: selectedStay == 1,
                    title: 'Bukchon Hanok',
                    dates: 'Sep 16–18 · 2 nights',
                    onTap: () => setState(() => selectedStay = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Popular near your stay',
                        style: _sectionTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Starting from $stayName',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.green,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 9),
            for (var index = 0; index < places.length; index++) ...[
              _NearbyPlaceCard(
                place: places[index],
                added: addedPlaces.contains(selectedStay * 10 + index),
                onTap: () => setState(() {
                  final key = selectedStay * 10 + index;
                  addedPlaces.contains(key)
                      ? addedPlaces.remove(key)
                      : addedPlaces.add(key);
                }),
              ),
              if (index != places.length - 1) const SizedBox(height: 8),
            ],
            const SizedBox(height: 18),
            _PrimaryAction(
              label: 'Build ${addedPlaces.length} place itinerary',
              icon: Icons.auto_awesome_rounded,
              background: AppColors.green,
              foreground: Colors.white,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const TravelAppShell(initialIndex: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StayTimeline extends StatelessWidget {
  const _StayTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'All nights covered',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              Spacer(),
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              for (final day in ['14', '15', '16', '17', '18'])
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.deepGreen,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'L7 · 2 nights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 24,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Bukchon · 2 nights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F0D5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              children: [
                Icon(Icons.luggage_rounded, size: 15),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Sep 16 · Stay move day · Plan luggage',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaySelector extends StatelessWidget {
  const _StaySelector({
    required this.selected,
    required this.title,
    required this.dates,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String dates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: selected ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hotel_rounded,
                  size: 14,
                  color: selected ? AppColors.green : AppColors.muted,
                ),
                const Spacer(),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.green,
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              dates,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyPlaceCard extends StatelessWidget {
  const _NearbyPlaceCard({
    required this.place,
    required this.added,
    required this.onTap,
  });

  final (String, String, String, String) place;
  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.green,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${place.$2} · ${place.$3}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                Text(
                  place.$4,
                  style: const TextStyle(fontSize: 11, color: AppColors.green),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 61,
            height: 31,
            child: added
                ? OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.green,
                      side: const BorderSide(color: AppColors.green),
                    ),
                    child: const Text('Added', style: TextStyle(fontSize: 11)),
                  )
                : FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.deepGreen,
                    ),
                    child: const Text('+ Add', style: TextStyle(fontSize: 11)),
                  ),
          ),
        ],
      ),
    );
  }
}

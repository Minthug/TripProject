part of '../../main.dart';

class TripOverviewScreen extends StatefulWidget {
  const TripOverviewScreen({super.key, this.showBack = true});

  final bool showBack;

  @override
  State<TripOverviewScreen> createState() => _TripOverviewScreenState();
}

class _TripOverviewScreenState extends State<TripOverviewScreen> {
  bool issuesOnly = false;

  static const days = [
    _OverviewDay(
      day: 'MON',
      date: '14',
      title: 'Arrival day',
      stay: 'L7 Myeongdong',
      items: ['4:20 PM · Arrive at ICN', 'Check in at L7 Myeongdong'],
      openTime: 'Evening is open',
    ),
    _OverviewDay(
      day: 'TUE',
      date: '15',
      title: 'Myeongdong & palace',
      stay: 'L7 Myeongdong',
      items: ['Myeongdong Cathedral', 'Gyeongbokgung Palace', 'N Seoul Tower'],
      openTime: 'Morning is open',
      issue: 'Gyeongbokgung is closed on Tuesdays',
    ),
    _OverviewDay(
      day: 'WED',
      date: '16',
      title: 'Move to Bukchon',
      stay: 'L7 → Bukchon Hanok',
      items: ['11:00 AM · Check out L7', '3:00 PM · Check in Bukchon'],
      openTime: '4 hours between stays · plan luggage storage',
      moveDay: true,
    ),
    _OverviewDay(
      day: 'THU',
      date: '17',
      title: 'Museums & local tour',
      stay: 'Bukchon Hanok Stay',
      items: ['2:00 PM · MMCA ticket', '2:30 PM · Bukchon food tour'],
      openTime: 'Morning is open',
      issue: 'Two reservations overlap by 30 minutes',
    ),
    _OverviewDay(
      day: 'FRI',
      date: '18',
      title: 'Departure day',
      stay: 'Bukchon Hanok Stay',
      items: ['11:00 AM · Check out', '5:30 PM · Flight from ICN'],
      openTime: '11:00 AM–2:30 PM is open',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleDays = issuesOnly
        ? days.where((day) => day.issue != null).toList()
        : days;
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.showBack) ...[
                _MapCircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: Navigator.of(context).canPop()
                      ? () => Navigator.pop(context)
                      : null,
                ),
                const SizedBox(width: 11),
              ],
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seoul trip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Sep 14–18 · 4 nights',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
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
          const SizedBox(height: 15),
          const Text(
            'Your whole trip',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Stays, open time and conflicts across every day.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _OverviewStat(value: '5', label: 'DAYS'),
              ),
              SizedBox(width: 7),
              Expanded(
                child: _OverviewStat(value: '2', label: 'STAYS'),
              ),
              SizedBox(width: 7),
              Expanded(
                child: _OverviewStat(
                  value: '2',
                  label: 'ISSUES',
                  warning: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final day in days) ...[
                        _OverviewDateDot(day: day),
                        if (day != days.last) const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                selected: issuesOnly,
                showCheckmark: false,
                avatar: Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: issuesOnly ? Colors.white : const Color(0xFFB64B43),
                ),
                label: const Text('Issues'),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: issuesOnly ? Colors.white : AppColors.ink,
                ),
                selectedColor: const Color(0xFFB64B43),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.line),
                onSelected: (value) => setState(() => issuesOnly = value),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: visibleDays.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) => _OverviewDayCard(
                day: visibleDays[index],
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const Scaffold(body: FlexibleDayPlanScreen()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewDay {
  const _OverviewDay({
    required this.day,
    required this.date,
    required this.title,
    required this.stay,
    required this.items,
    required this.openTime,
    this.issue,
    this.moveDay = false,
  });

  final String day;
  final String date;
  final String title;
  final String stay;
  final List<String> items;
  final String openTime;
  final String? issue;
  final bool moveDay;
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.value,
    required this.label,
    this.warning = false,
  });

  final String value;
  final String label;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF2D7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: warning ? const Color(0xFFE9C984) : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: warning ? const Color(0xFFB86D00) : AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewDateDot extends StatelessWidget {
  const _OverviewDateDot({required this.day});

  final _OverviewDay day;

  @override
  Widget build(BuildContext context) {
    final issue = day.issue != null;
    return Container(
      width: 43,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: day.moveDay
            ? AppColors.deepGreen
            : issue
            ? const Color(0xFFFFF2D7)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: issue ? const Color(0xFFE9C984) : AppColors.line,
        ),
      ),
      child: Column(
        children: [
          Text(
            day.day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: day.moveDay ? Colors.white70 : AppColors.muted,
            ),
          ),
          Text(
            day.date,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: day.moveDay ? Colors.white : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewDayCard extends StatelessWidget {
  const _OverviewDayCard({required this.day, required this.onOpen});

  final _OverviewDay day;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final hasIssue = day.issue != null;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasIssue ? const Color(0xFFE8B5AF) : AppColors.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: day.moveDay
                          ? AppColors.deepGreen
                          : AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Column(
                      children: [
                        Text(
                          day.day,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: day.moveDay
                                ? Colors.white70
                                : AppColors.muted,
                          ),
                        ),
                        Text(
                          day.date,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: day.moveDay ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                day.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (day.moveDay) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F0D5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'MOVE DAY',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.hotel_rounded,
                              size: 12,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                day.stay,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: AppColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              for (final item in day.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item, style: const TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              _OverviewNotice(
                icon: day.moveDay
                    ? Icons.luggage_rounded
                    : Icons.free_breakfast_outlined,
                text: day.openTime,
                moveDay: day.moveDay,
              ),
              if (hasIssue) ...[
                const SizedBox(height: 6),
                _OverviewNotice(
                  icon: Icons.error_outline_rounded,
                  text: day.issue!,
                  issue: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewNotice extends StatelessWidget {
  const _OverviewNotice({
    required this.icon,
    required this.text,
    this.issue = false,
    this.moveDay = false,
  });

  final IconData icon;
  final String text;
  final bool issue;
  final bool moveDay;

  @override
  Widget build(BuildContext context) {
    final color = issue
        ? const Color(0xFFB64B43)
        : moveDay
        ? const Color(0xFF9A6A00)
        : AppColors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: issue
            ? const Color(0xFFFFF2F0)
            : moveDay
            ? const Color(0xFFFFF2D7)
            : AppColors.paleGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

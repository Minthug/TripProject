part of '../../main.dart';

class TripSetupScreen extends StatefulWidget {
  const TripSetupScreen({super.key});

  @override
  State<TripSetupScreen> createState() => _TripSetupScreenState();
}

class _TripSetupScreenState extends State<TripSetupScreen> {
  int startDay = 14;
  int endDay = 18;

  void _selectDay(int day) {
    setState(() {
      if (day < startDay || startDay != endDay) {
        startDay = day;
        endDay = day;
      } else {
        endDay = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.deepGreen,
                    size: 20,
                  ),
                ),
                const Spacer(),
                const Text(
                  'New trip',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'When will you be\nin Seoul?',
              style: TextStyle(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 9),
            const Text(
              '먼저 여행 날짜와 머무를 숙소를 알려주세요.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            const _SetupProgress(),
            const SizedBox(height: 18),
            _TripCalendar(
              startDay: startDay,
              endDay: endDay,
              onDaySelected: _selectDay,
            ),
            const SizedBox(height: 14),
            const Text('Where are you staying?', style: _sectionTitle),
            const SizedBox(height: 9),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showPrototypeMessage(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Row(
                  children: [
                    _ContainerIcon(icon: Icons.hotel_rounded),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'L7 Myeongdong',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '137 Toegye-ro · 서울 중구',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F0D5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 17),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '숙소를 기준으로 매일 첫 경로와 귀가 경로를 추천해요.',
                      style: TextStyle(fontSize: 11, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _PrimaryAction(
              label: 'Next · Add places',
              icon: Icons.arrow_forward_rounded,
              background: AppColors.green,
              foreground: Colors.white,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const Scaffold(body: StayBasedPlannerScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupProgress extends StatelessWidget {
  const _SetupProgress();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _step('1', 'Dates', true),
        _line(true),
        _step('2', 'Stay', true),
        _line(false),
        _step('3', 'Places', false),
      ],
    );
  }

  Widget _step(String number, String label, bool active) => Expanded(
    child: Column(
      children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.deepGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? AppColors.deepGreen : AppColors.line,
            ),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: active ? Colors.white : AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.ink : AppColors.muted,
          ),
        ),
      ],
    ),
  );

  Widget _line(bool active) => Container(
    width: 36,
    height: 1.5,
    margin: const EdgeInsets.only(bottom: 16),
    color: active ? AppColors.green : AppColors.line,
  );
}

class _TripCalendar extends StatelessWidget {
  const _TripCalendar({
    required this.startDay,
    required this.endDay,
    required this.onDaySelected,
  });

  final int startDay;
  final int endDay;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    const days = <int?>[
      null,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
      null,
      null,
      null,
      null,
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.chevron_left_rounded, size: 20),
              Expanded(
                child: Text(
                  'September 2026',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              for (final label in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 31,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) return const SizedBox.shrink();
              final endpoint = day == startDay || day == endDay;
              final within = day >= startDay && day <= endDay;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onDaySelected(day),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: endpoint
                        ? AppColors.deepGreen
                        : within
                        ? AppColors.paleGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: endpoint ? FontWeight.w800 : FontWeight.w500,
                      color: endpoint ? Colors.white : AppColors.ink,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 15,
                color: AppColors.green,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Sep $startDay – $endDay  ·  ${endDay - startDay + 1} days',
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

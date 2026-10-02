part of '../../main.dart';

class TouristTransitGuideScreen extends StatefulWidget {
  const TouristTransitGuideScreen({super.key});

  @override
  State<TouristTransitGuideScreen> createState() =>
      _TouristTransitGuideScreenState();
}

class _TouristTransitGuideScreenState extends State<TouristTransitGuideScreen> {
  int currentStep = 0;

  static const steps = [
    _TransitStep(
      title: 'Walk to Exit 6',
      local: '을지로입구역 6번 출구',
      detail: '4 min · 280 m',
      icon: Icons.directions_walk_rounded,
    ),
    _TransitStep(
      title: 'Follow green Line 2 signs',
      local: '2호선 · 을지로3가 방면 · 승강장 2',
      detail: 'Board near car 4-2 for an easier transfer',
      icon: Icons.directions_subway_rounded,
    ),
    _TransitStep(
      title: 'Ride 1 stop',
      local: '을지로입구 → 을지로3가',
      detail: 'Transfer at the next stop',
      icon: Icons.train_rounded,
    ),
    _TransitStep(
      title: 'Transfer at Euljiro 3-ga',
      local: '을지로3가역 · 3호선 대화 방면',
      detail: 'Follow orange Line 3 signs · 4 min',
      icon: Icons.sync_alt_rounded,
    ),
    _TransitStep(
      title: 'Ride 2 stops',
      local: '을지로3가 → 종로3가 → 안국',
      detail: '1 stop remaining after Jongno 3-ga',
      icon: Icons.train_rounded,
    ),
    _TransitStep(
      title: 'Leave through Anguk Exit 1',
      local: '안국역 1번 출구',
      detail: 'Elevator available near Exit 6',
      icon: Icons.exit_to_app_rounded,
    ),
    _TransitStep(
      title: 'Walk to MMCA Seoul',
      local: '국립현대미술관 서울관 정문',
      detail: '8 min · 560 m',
      icon: Icons.hotel_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    final onLine3 = currentStep >= 3;
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: Navigator.of(context).canPop()
                    ? () => Navigator.pop(context)
                    : null,
                borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To MMCA Seoul',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '31 min · Lines 2 → 3',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.offline_pin_rounded,
                      size: 13,
                      color: AppColors.green,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TransitProgress(
                    currentStep: currentStep,
                    total: steps.length,
                  ),
                  const SizedBox(height: 10),
                  _LiveTransitStatus(step: currentStep),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.deepGreen,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOW · STEP ${currentStep + 1} OF ${steps.length}',
                          style: const TextStyle(
                            color: Color(0xFFAED8C4),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Icon(step.icon, color: AppColors.yellow, size: 25),
                        const SizedBox(height: 9),
                        Text(
                          step.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          step.local,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          step.detail,
                          style: const TextStyle(
                            color: Color(0xFFC5D6CE),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        _LineBadge(
                          number: onLine3 ? '3' : '2',
                          color: onLine3
                              ? const Color(0xFFF06A24)
                              : const Color(0xFF00A84D),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                onLine3
                                    ? 'Toward Jongno 3-ga · Anguk'
                                    : 'Toward Euljiro 3-ga · Seongsu',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                onLine3 ? '종로3가 · 안국 방면' : '을지로3가 · 성수 방면',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: onLine3
                                      ? const Color(0xFFF06A24)
                                      : AppColors.green,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                onLine3
                                    ? 'Do not take Ogeum direction'
                                    : 'Do not take City Hall · Hongdae direction',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFB64B43),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.fromLTRB(11, 9, 11, 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Subway map',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Line 2 → Line 3 · 4 stops',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        _LiveTransitMap(currentStep: currentStep),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text('Full route', style: _sectionTitle),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'T-money · Tap in & out · ₩1,500',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: steps.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 5),
                    itemBuilder: (context, index) => _TransitStepRow(
                      number: index + 1,
                      step: steps[index],
                      active: index == currentStep,
                      done: index < currentStep,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTransitHelp(context),
                  icon: const Icon(Icons.translate_rounded, size: 17),
                  label: const Text('Need help'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.line),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => setState(() {
                    if (currentStep < steps.length - 1) currentStep += 1;
                  }),
                  icon: const Icon(Icons.check_rounded, size: 17),
                  label: Text(
                    currentStep == steps.length - 1
                        ? 'Arrived'
                        : _nextStepLabel(currentStep),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _nextStepLabel(int step) => switch (step) {
    0 => 'I entered the station',
    1 => 'I found the platform',
    2 => 'I got off to transfer',
    3 => 'I boarded Line 3',
    4 => 'I got off at Anguk',
    5 => 'I left the station',
    _ => 'I arrived',
  };
}

class _LiveTransitStatus extends StatelessWidget {
  const _LiveTransitStatus({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final (title, detail, icon) = switch (step) {
      0 => (
        'Board at Euljiro 1-ga · Platform 2',
        'Enter through Exit 6 · Train arrives in 3 min',
        Icons.location_on_rounded,
      ),
      1 => (
        'Platform 2 · Board near car 4-2',
        'Line 2 toward Euljiro 3-ga · 1 stop',
        Icons.directions_subway_rounded,
      ),
      2 => (
        '1 stop remaining',
        'Next: Euljiro 3-ga · Transfer to Line 3',
        Icons.pin_drop_rounded,
      ),
      3 => (
        'Transfer here · Euljiro 3-ga',
        'Follow orange Line 3 signs · 4 min',
        Icons.sync_alt_rounded,
      ),
      4 => (
        '2 stops remaining · Get off at Anguk',
        'Next: Jongno 3-ga · Then 1 more stop',
        Icons.train_rounded,
      ),
      _ => (
        'Use Anguk Exit 1',
        'Follow Exit 1 signs · MMCA is an 8 min walk',
        Icons.exit_to_app_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paleGreen,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.green.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _LiveDot(),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'LIVE ROUTE STATUS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Updated now',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(icon, size: 21, color: AppColors.green),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _LiveFact(label: 'BOARD', value: 'Platform 2'),
              SizedBox(width: 6),
              _LiveFact(label: 'TRANSFER', value: 'Euljiro 3-ga'),
              SizedBox(width: 6),
              _LiveFact(label: 'EXIT', value: 'Anguk 1'),
            ],
          ),
          const SizedBox(height: 7),
          const Row(
            children: [
              Icon(Icons.gps_off_rounded, size: 12, color: AppColors.muted),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'GPS can drift underground. Use the step button to keep guidance accurate.',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 7,
    height: 7,
    decoration: const BoxDecoration(
      color: Color(0xFF2AA66F),
      shape: BoxShape.circle,
    ),
  );
}

class _LiveFact extends StatelessWidget {
  const _LiveFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTransitMap extends StatelessWidget {
  const _LiveTransitMap({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const points = [
      ('Euljiro 1-ga', '을지로입구', '2', 1),
      ('Euljiro 3-ga', '환승', '2→3', 3),
      ('Jongno 3-ga', '종로3가', '3', 4),
      ('Anguk · Exit 1', '안국', '3', 5),
    ];
    return SizedBox(
      height: 84,
      child: Stack(
        children: [
          Positioned(
            left: 37,
            right: 37,
            top: 14,
            child: Row(
              children: [
                Expanded(
                  child: Container(height: 4, color: const Color(0xFF00A84D)),
                ),
                Expanded(
                  flex: 2,
                  child: Container(height: 4, color: const Color(0xFFF06A24)),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: points.map((point) {
              final active = currentStep >= point.$4;
              final transfer = point.$3 == '2→3';
              final color = point.$3 == '2'
                  ? const Color(0xFF00A84D)
                  : const Color(0xFFF06A24);
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: transfer ? 34 : 29,
                      height: transfer ? 34 : 29,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? color : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 3),
                        boxShadow: active
                            ? const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        point.$3,
                        style: TextStyle(
                          color: active ? Colors.white : color,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      point.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      point.$2,
                      style: TextStyle(
                        fontSize: 11,
                        color: transfer
                            ? const Color(0xFFF06A24)
                            : AppColors.muted,
                        fontWeight: transfer
                            ? FontWeight.w800
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TransitStep {
  const _TransitStep({
    required this.title,
    required this.local,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String local;
  final String detail;
  final IconData icon;
}

class _TransitProgress extends StatelessWidget {
  const _TransitProgress({required this.currentStep, required this.total});

  final int currentStep;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 5),
            decoration: BoxDecoration(
              color: active ? AppColors.green : AppColors.line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _LineBadge extends StatelessWidget {
  const _LineBadge({required this.number, required this.color});

  final String number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TransitStepRow extends StatelessWidget {
  const _TransitStepRow({
    required this.number,
    required this.step,
    required this.active,
    required this.done,
  });

  final int number;
  final _TransitStep step;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.paleGreen : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: active ? AppColors.green : AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.green
                  : active
                  ? AppColors.deepGreen
                  : const Color(0xFFF0F2EF),
              shape: BoxShape.circle,
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: active ? Colors.white : AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  step.local,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Icon(
            step.icon,
            size: 16,
            color: active ? AppColors.green : AppColors.muted,
          ),
        ],
      ),
    );
  }
}

void _showTransitHelp(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _TransitHelpSheet(),
  );
}

class _TransitHelpSheet extends StatelessWidget {
  const _TransitHelpSheet();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.deepGreen,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '역무원에게 보여주세요',
                style: TextStyle(
                  color: Color(0xFFAED8C4),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '2호선 시청·홍대입구 방면\n타는 곳이 어디인가요?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.3,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Where is Line 2 toward City Hall and Hongdae?',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showPrototypeMessage(context),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Play Korean audio'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F0D5),
                    foregroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

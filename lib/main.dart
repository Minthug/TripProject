import 'package:flutter/material.dart';
import 'screen_flow_board.dart';

void main() => runApp(const TripProjectApp());

class TripProjectApp extends StatelessWidget {
  const TripProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NextMate UI Gallery',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
          surface: AppColors.canvas,
        ),
        scaffoldBackgroundColor: AppColors.board,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
      ),
      home: const DesignGalleryPage(),
    );
  }
}

class AppColors {
  static const ink = Color(0xFF17201B);
  static const green = Color(0xFF1E6B4E);
  static const deepGreen = Color(0xFF173F32);
  static const canvas = Color(0xFFF8F9F7);
  static const board = Color(0xFFF1F2EF);
  static const muted = Color(0xFF69716C);
  static const line = Color(0xFFE0E4E0);
  static const paleGreen = Color(0xFFE8F1EC);
  static const yellow = Color(0xFFF5D67B);
}

class DesignGalleryPage extends StatefulWidget {
  const DesignGalleryPage({super.key});

  @override
  State<DesignGalleryPage> createState() => _DesignGalleryPageState();
}

class _DesignGalleryPageState extends State<DesignGalleryPage> {
  int selected = 0;
  late bool flowMode;

  @override
  void initState() {
    super.initState();
    flowMode = Uri.base.queryParameters['view'] == 'flow';
    final requestedScreen = int.tryParse(
      Uri.base.queryParameters['screen'] ?? '',
    );
    if (requestedScreen != null &&
        requestedScreen >= 0 &&
        requestedScreen < variants.length) {
      selected = requestedScreen;
    }
  }

  static const variants = [
    _VariantInfo('00', 'Splash', '앱 실행과 여행 상태 확인'),
    _VariantInfo('01', 'Plan trip', '여행 날짜와 숙소 먼저 등록'),
    _VariantInfo('02', 'Stay planner', '다중 숙소와 주변 명소로 일정 구성'),
    _VariantInfo('03', 'Add stay', '지도에서 숙소 위치와 입구 확인'),
    _VariantInfo('04', 'Day plan', '운영시간 중심의 느슨한 하루 일정'),
    _VariantInfo('05', 'Transit guide', '관광객용 단계별 대중교통 안내'),
    _VariantInfo('06', 'Taxi handoff', '출발지와 목적지 최종 확인'),
    _VariantInfo('07', 'Driver card', '기사에게 현지어 목적지 표시'),
    _VariantInfo('A', 'Next move', '출발 시각과 다음 행동 중심'),
    _VariantInfo('B', 'Day timeline', '하루 일정의 흐름 중심'),
    _VariantInfo('C', 'Live map', '현재 위치와 경로 중심'),
  ];

  Widget _screen(int index) => switch (index) {
    0 => const SplashScreenPreview(),
    1 => const TripSetupScreen(),
    2 => const StayBasedPlannerScreen(),
    3 => const AddStayMapScreen(),
    4 => const FlexibleDayPlanScreen(),
    5 => const TouristTransitGuideScreen(),
    6 => const UberHandoffPreview(),
    7 => const DriverCardPreview(),
    8 => const NextMoveHome(),
    9 => const TimelineHome(),
    _ => const MapFirstHome(),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1180;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _GalleryHeader(
                  selected: selected,
                  showSelector: !wide,
                  flowMode: flowMode,
                  onSelected: (value) => setState(() => selected = value),
                  onModeChanged: (value) => setState(() => flowMode = value),
                ),
                Expanded(
                  child: flowMode
                      ? const ScreenFlowBoard()
                      : wide
                      ? SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(24, 10, 0, 36),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                variants.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 24),
                                  child: _Preview(
                                    info: variants[index],
                                    child: _screen(index),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                            child: _Preview(
                              info: variants[selected],
                              child: _screen(selected),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.selected,
    required this.showSelector,
    required this.flowMode,
    required this.onSelected,
    required this.onModeChanged,
  });

  final int selected;
  final bool showSelector;
  final bool flowMode;
  final ValueChanged<int> onSelected;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NextMate · UI Gallery',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '첫 화면 디자인 탐색 · Seoul Day 2',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Text(
                'Product prototype',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 8,
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.phone_iphone_rounded, size: 16),
                    label: Text('Screens'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.account_tree_outlined, size: 16),
                    label: Text('Flow map'),
                  ),
                ],
                selected: {flowMode},
                onSelectionChanged: (value) => onModeChanged(value.first),
              ),
              if (showSelector && !flowMode)
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 0, label: Text('00')),
                    ButtonSegment(value: 1, label: Text('01')),
                    ButtonSegment(value: 2, label: Text('02')),
                    ButtonSegment(value: 3, label: Text('03')),
                    ButtonSegment(value: 4, label: Text('04')),
                    ButtonSegment(value: 5, label: Text('05')),
                    ButtonSegment(value: 6, label: Text('06')),
                    ButtonSegment(value: 7, label: Text('07')),
                    ButtonSegment(value: 8, label: Text('A')),
                    ButtonSegment(value: 9, label: Text('B')),
                    ButtonSegment(value: 10, label: Text('C')),
                  ],
                  selected: {selected},
                  onSelectionChanged: (value) => onSelected(value.first),
                )
              else
                Text(
                  flowMode ? '버튼 → 화면 연결도' : '11 screens',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.info, required this.child});

  final _VariantInfo info;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 390,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.ink,
                  child: Text(
                    info.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  info.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 844,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0xFFCED3CF), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class SplashScreenPreview extends StatelessWidget {
  const SplashScreenPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.deepGreen,
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F0D5),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 26,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const _NextMateMark(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'NextMate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your next move, made local.',
                    style: TextStyle(
                      color: Color(0xFFBFD1C9),
                      fontSize: 13,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Text(
                'TRAVEL WITH CONFIDENCE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8EACA0),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextMateMark extends StatelessWidget {
  const _NextMateMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NextMateMarkPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _NextMateMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.deepGreen
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = AppColors.green;
    final start = Offset(size.width * .28, size.height * .66);
    final end = Offset(size.width * .72, size.height * .34);
    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * .28,
        size.height * .27,
        size.width * .72,
        size.height * .73,
        end.dx,
        end.dy,
      );
    canvas.drawPath(route, routePaint);
    canvas.drawCircle(start, 7, dotPaint);
    canvas.drawCircle(end, 7, dotPaint);
    canvas.drawCircle(start, 2.5, Paint()..color = const Color(0xFFF7F0D5));
    canvas.drawCircle(end, 2.5, Paint()..color = const Color(0xFFF7F0D5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
          const Spacer(),
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
                builder: (_) => const Scaffold(body: StayBasedPlannerScreen()),
              ),
            ),
          ),
        ],
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
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
                    style: TextStyle(fontSize: 9, color: AppColors.muted),
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
              Text(
                'Sep $startDay – $endDay  ·  ${endDay - startDay + 1} days',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
              const Spacer(),
              const Text(
                'Build your trip',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
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
                    const Text('Popular near your stay', style: _sectionTitle),
                    const SizedBox(height: 2),
                    Text(
                      'Starting from $stayName',
                      style: const TextStyle(
                        fontSize: 10,
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
          const Spacer(),
          _PrimaryAction(
            label: 'Build ${addedPlaces.length} place itinerary',
            icon: Icons.auto_awesome_rounded,
            background: AppColors.green,
            foreground: Colors.white,
            onTap: () => _showPrototypeMessage(context),
          ),
        ],
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
                    style: TextStyle(fontSize: 9, color: AppColors.muted),
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
                      fontSize: 9,
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
                      fontSize: 9,
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
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
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
              style: const TextStyle(fontSize: 8.5, color: AppColors.muted),
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
                  style: const TextStyle(fontSize: 9, color: AppColors.muted),
                ),
                Text(
                  place.$4,
                  style: const TextStyle(fontSize: 8.5, color: AppColors.green),
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
                    child: const Text('Added', style: TextStyle(fontSize: 9)),
                  )
                : FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.deepGreen,
                    ),
                    child: const Text('+ Add', style: TextStyle(fontSize: 9)),
                  ),
          ),
        ],
      ),
    );
  }
}

class AddStayMapScreen extends StatefulWidget {
  const AddStayMapScreen({super.key});

  @override
  State<AddStayMapScreen> createState() => _AddStayMapScreenState();
}

class _AddStayMapScreenState extends State<AddStayMapScreen> {
  final _searchController = TextEditingController(text: 'L7 Myeongdong');
  bool showResults = false;
  bool mapMoved = false;
  Offset mapOffset = Offset.zero;
  String stayName = 'L7 Myeongdong';
  String localName = 'L7 명동 바이 롯데';
  String address = '서울특별시 중구 퇴계로 137';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectResult({
    required String name,
    required String local,
    required String newAddress,
  }) {
    setState(() {
      stayName = name;
      localName = local;
      address = newAddress;
      _searchController.text = name;
      showResults = false;
      mapMoved = false;
      mapOffset = Offset.zero;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onPanUpdate: (details) => setState(() {
              mapOffset += details.delta;
              mapMoved = true;
              showResults = false;
            }),
            child: _StayPickerMap(offset: mapOffset),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 16,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  children: [
                    _MapCircleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: Navigator.of(context).canPop()
                          ? () => Navigator.pop(context)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Add a stay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Seoul',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 3,
                  shadowColor: Colors.black26,
                  child: TextField(
                    controller: _searchController,
                    onTap: () => setState(() => showResults = true),
                    onChanged: (_) => setState(() => showResults = true),
                    decoration: InputDecoration(
                      hintText: 'Hotel name or address',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.green,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _searchController.clear();
                          showResults = true;
                        }),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (showResults) ...[
                  const SizedBox(height: 7),
                  _StaySearchResults(onSelected: _selectResult),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 245,
          child: Column(
            children: [
              _MapCircleButton(
                icon: Icons.my_location_rounded,
                onTap: () => setState(() {
                  mapOffset = Offset.zero;
                  mapMoved = false;
                }),
              ),
              const SizedBox(height: 8),
              const _MapCircleButton(icon: Icons.layers_outlined),
            ],
          ),
        ),
        const Align(alignment: Alignment(0, -.1), child: _CenterStayPin()),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 11, 20, 22),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBF9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5DAD6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.hotel_rounded,
                          color: AppColors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mapMoved ? 'Custom entrance pin' : stayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mapMoved ? 'Move the map to adjust' : localName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  _LocationCheckRow(
                    icon: Icons.signpost_rounded,
                    title: 'Local address',
                    detail: address,
                  ),
                  const SizedBox(height: 9),
                  _LocationCheckRow(
                    icon: Icons.door_front_door_rounded,
                    title: 'Pickup entrance',
                    detail: mapMoved
                        ? 'Pin adjusted manually'
                        : 'Main entrance · Toegye-ro',
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAction(
                    label: 'Use this location',
                    icon: Icons.arrow_forward_rounded,
                    background: AppColors.green,
                    foreground: Colors.white,
                    onTap: () => _showStayDatesSheet(
                      context,
                      stayName: mapMoved ? 'Custom stay' : stayName,
                      address: address,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaySearchResults extends StatelessWidget {
  const _StaySearchResults({required this.onSelected});

  final void Function({
    required String name,
    required String local,
    required String newAddress,
  })
  onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: Column(
        children: [
          _StaySearchResult(
            title: 'L7 Myeongdong',
            detail: 'L7 명동 바이 롯데 · 137 Toegye-ro',
            onTap: () => onSelected(
              name: 'L7 Myeongdong',
              local: 'L7 명동 바이 롯데',
              newAddress: '서울특별시 중구 퇴계로 137',
            ),
          ),
          const Divider(height: 1, indent: 48),
          _StaySearchResult(
            title: 'L7 Hongdae',
            detail: 'L7 홍대 바이 롯데 · 141 Yanghwa-ro',
            onTap: () => onSelected(
              name: 'L7 Hongdae',
              local: 'L7 홍대 바이 롯데',
              newAddress: '서울특별시 마포구 양화로 141',
            ),
          ),
        ],
      ),
    );
  }
}

class _StaySearchResult extends StatelessWidget {
  const _StaySearchResult({
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: const Icon(
        Icons.hotel_rounded,
        color: AppColors.green,
        size: 19,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        detail,
        style: const TextStyle(fontSize: 9, color: AppColors.muted),
      ),
      trailing: const Icon(Icons.north_west_rounded, size: 15),
    );
  }
}

class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 19, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _CenterStayPin extends StatelessWidget {
  const _CenterStayPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.deepGreen,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Text(
            'Entrance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Icon(Icons.location_on_rounded, color: AppColors.green, size: 42),
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

class _LocationCheckRow extends StatelessWidget {
  const _LocationCheckRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.green),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 9, color: AppColors.muted),
              ),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StayPickerMap extends StatelessWidget {
  const _StayPickerMap({required this.offset});

  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StayPickerMapPainter(offset),
      child: const SizedBox.expand(),
    );
  }
}

class _StayPickerMapPainter extends CustomPainter {
  const _StayPickerMapPainter(this.offset);

  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8ECE7),
    );
    canvas.save();
    canvas.translate(offset.dx % 120, offset.dy % 120);
    final minor = Paint()
      ..color = const Color(0xFFD1D9D3)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    for (var x = -100.0; x < size.width + 100; x += 92) {
      canvas.drawLine(
        Offset(x, -100),
        Offset(x + 150, size.height + 100),
        minor,
      );
    }
    for (var y = 120.0; y < size.height; y += 115) {
      final path = Path()
        ..moveTo(-100, y)
        ..cubicTo(
          size.width * .25,
          y - 28,
          size.width * .7,
          y + 32,
          size.width + 100,
          y - 5,
        );
      canvas.drawPath(path, road);
    }
    canvas.drawCircle(
      Offset(size.width * .2, size.height * .43),
      47,
      Paint()..color = const Color(0xFFCFE2DE),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StayPickerMapPainter oldDelegate) =>
      oldDelegate.offset != offset;
}

void _showStayDatesSheet(
  BuildContext context, {
  required String stayName,
  required String address,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _StayDatesSheet(
      stayName: stayName,
      address: address,
      onAdd: () {
        Navigator.pop(sheetContext);
        _showPrototypeMessage(context);
      },
    ),
  );
}

class _StayDatesSheet extends StatelessWidget {
  const _StayDatesSheet({
    required this.stayName,
    required this.address,
    required this.onAdd,
  });

  final String stayName;
  final String address;
  final VoidCallback onAdd;

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
              const SizedBox(height: 18),
              const Text(
                'When are you staying?',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                stayName,
                style: const TextStyle(fontSize: 13, color: AppColors.green),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              const SizedBox(height: 17),
              const Row(
                children: [
                  Expanded(
                    child: _StayDateBox(
                      label: 'CHECK-IN',
                      date: 'Wed, Sep 16',
                      time: '3:00 PM',
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: _StayDateBox(
                      label: 'CHECK-OUT',
                      date: 'Fri, Sep 18',
                      time: '11:00 AM',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 17,
                      color: AppColors.green,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fills your uncovered Sep 16–18 stay · 2 nights',
                        style: TextStyle(fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryAction(
                label: 'Add 2-night stay',
                icon: Icons.add_rounded,
                background: AppColors.green,
                foreground: Colors.white,
                onTap: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StayDateBox extends StatelessWidget {
  const _StayDateBox({
    required this.label,
    required this.date,
    required this.time,
  });

  final String label;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

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
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
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
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (orderSuggested)
                  const Text(
                    'Best order applied',
                    style: TextStyle(fontSize: 8.5, color: AppColors.green),
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
                  onPressed: () => _showPrototypeMessage(context),
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
                    fontSize: 8.8,
                    color: closed ? accent : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  place.note,
                  style: TextStyle(
                    fontSize: 8.8,
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
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800),
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
                          style: TextStyle(fontSize: 8, color: AppColors.green),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trailing,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

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
      local: '2호선 · 시청·홍대입구 방면',
      detail: 'Not Jamsil · Seongsu direction',
      icon: Icons.directions_subway_rounded,
    ),
    _TransitStep(
      title: 'Ride 1 stop',
      local: '을지로입구 → 시청',
      detail: 'We will alert you before your stop',
      icon: Icons.train_rounded,
    ),
    _TransitStep(
      title: 'Leave through Exit 7',
      local: '시청역 7번 출구',
      detail: 'Elevator available at Exit 8',
      icon: Icons.exit_to_app_rounded,
    ),
    _TransitStep(
      title: 'Walk to L7 Myeongdong',
      local: 'L7 명동 바이 롯데',
      detail: '3 min · 190 m',
      icon: Icons.hotel_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
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
                      'Back to L7 Myeongdong',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '27 min · Subway Line 2',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
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
                        fontSize: 9,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _TransitProgress(currentStep: currentStep, total: steps.length),
          const SizedBox(height: 14),
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
                    fontSize: 9,
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
            child: const Row(
              children: [
                _LineBadge(),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toward City Hall · Hongdae',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '시청 · 홍대입구 방면',
                        style: TextStyle(fontSize: 10, color: AppColors.green),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Do not take Jamsil · Seongsu direction',
                        style: TextStyle(fontSize: 9, color: Color(0xFFB64B43)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
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
                  style: TextStyle(fontSize: 8.5, color: AppColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
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
    2 => 'I am on the train',
    3 => 'I left the station',
    _ => 'I arrived',
  };
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
  const _LineBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF00A84D),
        shape: BoxShape.circle,
      ),
      child: const Text(
        '2',
        style: TextStyle(
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
                      fontSize: 9,
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
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  step.local,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 8.5, color: AppColors.muted),
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

class DriverCardPreview extends StatelessWidget {
  const DriverCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DriverCardContent(preview: true);
  }
}

class _DriverCardContent extends StatelessWidget {
  const _DriverCardContent({this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.deepGreen,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: preview ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    style: IconButton.styleFrom(
                      disabledBackgroundColor: Colors.white.withValues(
                        alpha: .12,
                      ),
                      disabledForegroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: .12),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHOW TO YOUR DRIVER',
                          style: TextStyle(
                            color: Color(0xFFAED8C4),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Destination card',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Text(
                      '한국어  KO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFB),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.waving_hand_rounded,
                            color: Color(0xFFE7AA27),
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '기사님, 안녕하세요.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      const Text(
                        '국립현대미술관\n서울관 정문으로\n가 주세요.',
                        style: TextStyle(
                          fontSize: 27,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.7,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(height: 1, color: AppColors.line),
                      const SizedBox(height: 17),
                      const _DriverDetail(
                        icon: Icons.location_on_rounded,
                        label: '목적지',
                        value: '국립현대미술관 서울',
                      ),
                      const SizedBox(height: 14),
                      const _DriverDetail(
                        icon: Icons.signpost_rounded,
                        label: '주소',
                        value: '서울특별시 종로구 삼청로 30',
                      ),
                      const SizedBox(height: 14),
                      const _DriverDetail(
                        icon: Icons.door_front_door_rounded,
                        label: '내리는 곳',
                        value: '서울관 정문 · 삼청로 방면',
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: AppColors.green,
                              size: 18,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'English check',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Please take me to the main entrance of MMCA Seoul.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: preview
                      ? null
                      : () => _showPrototypeMessage(context),
                  icon: const Icon(Icons.volume_up_rounded, size: 19),
                  label: const Text('Play Korean audio'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F0D5),
                    foregroundColor: AppColors.ink,
                    disabledBackgroundColor: const Color(0xFFF7F0D5),
                    disabledForegroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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

class _DriverDetail extends StatelessWidget {
  const _DriverDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.green, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showDriverCard(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const _DriverCardContent()));
}

class UberHandoffPreview extends StatelessWidget {
  const UberHandoffPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const NextMoveHome(),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .38)),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: _UberHandoffSheetContent(preview: true),
        ),
      ],
    );
  }
}

class _UberHandoffSheetContent extends StatelessWidget {
  const _UberHandoffSheetContent({this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7DBD8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 17),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to open Uber?',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Check your pickup and destination first.',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                _UberBadge(),
              ],
            ),
            const SizedBox(height: 18),
            const _HandoffRoute(),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: AppColors.green,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Destination coordinates and Korean address are ready.',
                      style: TextStyle(fontSize: 10.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: preview ? null : () => _showDriverCard(context),
                    icon: const Icon(Icons.translate_rounded, size: 17),
                    label: const Text('Driver card'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      disabledForegroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                    onPressed: preview
                        ? null
                        : () => _showPrototypeMessage(context),
                    icon: const Icon(Icons.open_in_new_rounded, size: 17),
                    label: const Text('Continue in Uber'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      disabledBackgroundColor: AppColors.ink,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            const Center(
              child: Text(
                'Fare, vehicle selection and payment continue in Uber.',
                style: TextStyle(fontSize: 9.5, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UberBadge extends StatelessWidget {
  const _UberBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Text(
        'UBER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

class _HandoffRoute extends StatelessWidget {
  const _HandoffRoute();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F7),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: 5), child: _RouteDots()),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteAddress(
                  label: 'PICKUP',
                  title: 'Current location',
                  detail: 'Bukchon-ro 5-gil · GPS updated now',
                ),
                SizedBox(height: 15),
                _RouteAddress(
                  label: 'DESTINATION',
                  title: 'MMCA Seoul',
                  detail: '국립현대미술관 서울 · Main entrance',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.edit_outlined, size: 17, color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

class _RouteDots extends StatelessWidget {
  const _RouteDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 73,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 1.5, height: 53, color: const Color(0xFFBFC7C2)),
          const Positioned(
            top: 0,
            child: Icon(
              Icons.my_location_rounded,
              size: 15,
              color: AppColors.green,
            ),
          ),
          const Positioned(
            bottom: 0,
            child: Icon(
              Icons.location_on_rounded,
              size: 17,
              color: AppColors.deepGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteAddress extends StatelessWidget {
  const _RouteAddress({
    required this.label,
    required this.title,
    required this.detail,
  });

  final String label;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        Text(
          detail,
          style: const TextStyle(fontSize: 9.5, color: AppColors.muted),
        ),
      ],
    );
  }
}

void _showUberHandoff(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .42),
    builder: (_) =>
        const SafeArea(top: false, child: _UberHandoffSheetContent()),
  );
}

class NextMoveHome extends StatelessWidget {
  const NextMoveHome({super.key});

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AppHeader(
              title: 'Seoul · Day 2',
              subtitle: 'Tuesday, September 15',
            ),
            const SizedBox(height: 22),
            const _LocationLine(label: 'Bukchon Hanok Village'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'NEXT STOP',
                        style: TextStyle(
                          color: Color(0xFFAED8C4),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.more_horiz, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'MMCA Seoul',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '국립현대미술관 서울 · 2:00 PM',
                    style: TextStyle(color: Color(0xFFC7D8D0), fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: AppColors.yellow,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Leave in 24 minutes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Arrive around 1:52 PM',
                                style: TextStyle(
                                  color: Color(0xFFC7D8D0),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAction(
                    label: 'Prepare an Uber',
                    icon: Icons.local_taxi_rounded,
                    background: const Color(0xFFF7F0D5),
                    foreground: AppColors.ink,
                    onTap: () => _showUberHandoff(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Other ways to get there', style: _sectionTitle),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ModeTile(
                    icon: Icons.directions_subway_rounded,
                    title: 'Transit',
                    detail: '24 min · Direct',
                    onTap: () => _openTransitGuide(context),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: _ModeTile(
                    icon: Icons.directions_walk_rounded,
                    title: 'Walk',
                    detail: '31 min · 2.1 km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Text('Today', style: _sectionTitle),
                Spacer(),
                Text(
                  'View itinerary',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _MiniTimeline(),
          ],
        ),
      ),
    );
  }
}

class TimelineHome extends StatelessWidget {
  const TimelineHome({super.key});

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'Today in Seoul',
            subtitle: '3 of 5 places remaining',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                _ContainerIcon(icon: Icons.my_location_rounded),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are at',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bukchon Hanok Village',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Text(
                  '1:08 PM',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Your day',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Column(
              children: [
                _TimelineRow(
                  time: '10:00',
                  title: 'Gyeongbokgung Palace',
                  subtitle: 'Visited · 1h 34m',
                  state: _TimelineState.done,
                ),
                _TimelineRow(
                  time: '12:00',
                  title: 'Bukchon Hanok Village',
                  subtitle: 'You are here',
                  state: _TimelineState.current,
                ),
                _TimelineRow(
                  time: '14:00',
                  title: 'MMCA Seoul',
                  subtitle: 'Next · Reservation',
                  state: _TimelineState.next,
                ),
                _TimelineRow(
                  time: '16:30',
                  title: 'Cheonggyecheon Stream',
                  subtitle: 'Free time',
                  state: _TimelineState.upcoming,
                ),
                _TimelineRow(
                  time: '18:00',
                  title: 'Myeongdong Kyoja',
                  subtitle: 'Dinner',
                  state: _TimelineState.upcoming,
                  drawLine: false,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave in 24 min',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Uber · 17 min to MMCA',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 14),
                _PrimaryAction(
                  label: 'Plan next move',
                  icon: Icons.route_rounded,
                  background: Colors.white,
                  foreground: AppColors.ink,
                  onTap: () => _showPrototypeMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapFirstHome extends StatelessWidget {
  const MapFirstHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _MapCanvas()),
        Positioned(
          left: 18,
          right: 18,
          top: 18,
          child: Row(
            children: [
              const _RoundButton(icon: Icons.menu_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 19,
                        color: AppColors.green,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Bukchon → MMCA Seoul',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 18,
          top: 92,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Leave in 24 min',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAF8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 25,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D8D4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next destination',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'MMCA Seoul',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '국립현대미술관 서울 · Main entrance',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '2:00 PM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RouteChoice(
                  selected: true,
                  icon: Icons.local_taxi_rounded,
                  title: 'Uber Taxi',
                  detail: '17 min',
                  trailing: 'Recommended',
                  onTap: () => _showUberHandoff(context),
                ),
                const SizedBox(height: 9),
                _RouteChoice(
                  selected: false,
                  icon: Icons.directions_subway_rounded,
                  title: 'Public transit',
                  detail: '24 min · No transfers',
                  trailing: '₩1,500',
                  onTap: () => _openTransitGuide(context),
                ),
                const SizedBox(height: 14),
                _PrimaryAction(
                  label: 'Prepare an Uber',
                  icon: Icons.arrow_forward_rounded,
                  background: AppColors.green,
                  foreground: Colors.white,
                  onTap: () => _showUberHandoff(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PhonePage extends StatelessWidget {
  const _PhonePage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.canvas,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: child,
      ),
    ),
  );
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: const Icon(Icons.person_outline_rounded, size: 21),
        ),
      ],
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.my_location_rounded, size: 16, color: AppColors.green),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        const Text(
          'Updated now',
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.title,
    required this.detail,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.green, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: const TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTimeline extends StatelessWidget {
  const _MiniTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          _MiniRow(
            dot: Color(0xFF98A09B),
            time: '10:00',
            label: 'Gyeongbokgung',
            checked: true,
          ),
          SizedBox(height: 11),
          _MiniRow(
            dot: AppColors.green,
            time: '12:00',
            label: 'Bukchon · You are here',
          ),
          SizedBox(height: 11),
          _MiniRow(
            dot: Color(0xFFE7B542),
            time: '14:00',
            label: 'MMCA Seoul · Next',
          ),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({
    required this.dot,
    required this.time,
    required this.label,
    this.checked = false,
  });
  final Color dot;
  final String time;
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            time,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        if (checked)
          const Icon(Icons.check_rounded, size: 15, color: AppColors.muted),
      ],
    );
  }
}

class _ContainerIcon extends StatelessWidget {
  const _ContainerIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: AppColors.green, size: 19),
  );
}

enum _TimelineState { done, current, next, upcoming }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.state,
    this.drawLine = true,
  });
  final String time;
  final String title;
  final String subtitle;
  final _TimelineState state;
  final bool drawLine;

  @override
  Widget build(BuildContext context) {
    final active = state == _TimelineState.current;
    final next = state == _TimelineState.next;
    final done = state == _TimelineState.done;
    final dotColor = active
        ? AppColors.green
        : next
        ? const Color(0xFFE7B542)
        : const Color(0xFFCBD0CC);
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: done ? const Color(0xFF9AA09C) : const Color(0xFF4F5852),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: active
                        ? Border.all(color: const Color(0xFFBBD7CA), width: 4)
                        : null,
                  ),
                ),
                if (drawLine)
                  Expanded(child: Container(width: 1.5, color: AppColors.line)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Opacity(
              opacity: done ? .52 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: active ? AppColors.green : AppColors.muted,
                      fontWeight: active || next
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (active)
            const Icon(
              Icons.location_on_rounded,
              size: 17,
              color: AppColors.green,
            ),
        ],
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(),
      child: const Stack(
        children: [
          Positioned(
            left: 75,
            top: 252,
            child: _MapPin(
              label: 'You',
              icon: Icons.navigation_rounded,
              dark: true,
            ),
          ),
          Positioned(
            right: 54,
            top: 170,
            child: _MapPin(label: 'MMCA', icon: Icons.flag_rounded),
          ),
          Positioned(
            right: 20,
            top: 350,
            child: Column(
              children: [
                _MapControl(icon: Icons.add),
                SizedBox(height: 2),
                _MapControl(icon: Icons.remove),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFE8ECE7), BlendMode.src);
    final minor = Paint()
      ..color = const Color(0xFFD5DCD6)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final major = Paint()
      ..color = const Color(0xFFF9FAF8)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    final route = Paint()
      ..color = AppColors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      Rect.fromLTWH(-80, 115, 270, 120),
      Paint()..color = const Color(0xFFCFE1DF),
    );
    for (var i = -80.0; i < size.width + 80; i += 82) {
      canvas.drawLine(Offset(i, 0), Offset(i + 170, size.height * .67), minor);
    }
    for (var y = 72.0; y < size.height * .68; y += 105) {
      final path = Path()
        ..moveTo(0, y)
        ..cubicTo(
          size.width * .25,
          y - 35,
          size.width * .62,
          y + 35,
          size.width,
          y - 5,
        );
      canvas.drawPath(path, major);
    }
    final routePath = Path()
      ..moveTo(96, 280)
      ..cubicTo(135, 225, 180, 270, 220, 205)
      ..cubicTo(245, 166, 278, 207, 313, 185);
    canvas.drawPath(routePath, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.label, required this.icon, this.dark = false});
  final String label;
  final IconData icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.ink : AppColors.green;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(width: 12, height: 7, color: color),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    color: Colors.white,
    child: Icon(icon, size: 18),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    elevation: 2,
    child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 21)),
  );
}

class _RouteChoice extends StatelessWidget {
  const _RouteChoice({
    required this.selected,
    required this.icon,
    required this.title,
    required this.detail,
    required this.trailing,
    this.onTap,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String detail;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.green),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
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
            Text(
              trailing,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.green : AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openTransitGuide(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: TouristTransitGuideScreen()),
    ),
  );
}

void _showPrototypeMessage(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('다음 단계에서 이동수단 비교 화면으로 연결됩니다.')));
}

class _VariantInfo {
  const _VariantInfo(this.key, this.title, this.description);
  final String key;
  final String title;
  final String description;
}

const _sectionTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800);

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
  double textScale = 1.15;
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
    _VariantInfo('ON', 'First-run onboarding', '기능·언어·권한·Uber 준비'),
    _VariantInfo('00', 'Splash', '앱 실행과 여행 상태 확인'),
    _VariantInfo('01', 'Plan trip', '여행 날짜와 숙소 먼저 등록'),
    _VariantInfo('02', 'Stay planner', '다중 숙소와 주변 명소로 일정 구성'),
    _VariantInfo('03', 'Add stay', '지도에서 숙소 위치와 입구 확인'),
    _VariantInfo('04', 'Trip overview', '전체 날짜·숙소·빈 시간·충돌 확인'),
    _VariantInfo('05', 'Day plan', '운영시간 중심의 느슨한 하루 일정'),
    _VariantInfo('06', 'Add place', '지도와 운영정보로 관광지 추가'),
    _VariantInfo('07', 'Place detail', '입구·예약 확인과 일정 수정'),
    _VariantInfo('08', 'Transit guide', '관광객용 단계별 대중교통 안내'),
    _VariantInfo('09', 'Route comparison', '시간과 비용으로 이동수단 비교'),
    _VariantInfo('10', 'Taxi handoff', '출발지와 목적지 최종 확인'),
    _VariantInfo('11', 'Driver card', '기사에게 현지어 목적지 표시'),
    _VariantInfo('12', 'Departure alert', '출발·지연·건너뛰기 상태 관리'),
    _VariantInfo('13', 'Profile & settings', '언어·권한·이동수단 설정'),
    _VariantInfo('A', 'Next move', '출발 시각과 다음 행동 중심'),
    _VariantInfo('B', 'Day timeline', '하루 일정의 흐름 중심'),
    _VariantInfo('C', 'Live map', '현재 위치와 경로 중심'),
    _VariantInfo('ST', 'Recovery states', '오류를 설명하고 다음 행동 안내'),
  ];

  bool get uberInstalled => Uri.base.queryParameters['uber'] != 'missing';

  Widget _screen(int index) => switch (index) {
    0 => const OnboardingScreen(),
    1 => const SplashScreenPreview(),
    2 => const TripSetupScreen(),
    3 => const StayBasedPlannerScreen(),
    4 => const AddStayMapScreen(),
    5 => const TripOverviewScreen(),
    6 => const FlexibleDayPlanScreen(),
    7 => const PlaceExplorerScreen(),
    8 => const AttractionDetailScreen(),
    9 => const TouristTransitGuideScreen(),
    10 => RouteComparisonScreen(uberInstalled: uberInstalled),
    11 => UberHandoffPreview(uberInstalled: uberInstalled),
    12 => const DriverCardPreview(),
    13 => const DepartureAlertScreen(),
    14 => const ProfileSettingsScreen(),
    15 => const TravelAppShell(),
    16 => const TimelineHome(),
    17 => const MapFirstHome(),
    _ => const RecoveryStatesScreen(),
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
                  textScale: textScale,
                  showSelector: !wide,
                  flowMode: flowMode,
                  onSelected: (value) => setState(() => selected = value),
                  onModeChanged: (value) => setState(() => flowMode = value),
                  onTextScaleChanged: (value) =>
                      setState(() => textScale = value.clamp(1.0, 1.3)),
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
                                    textScale: textScale,
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
                              textScale: textScale,
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
    required this.textScale,
    required this.showSelector,
    required this.flowMode,
    required this.onSelected,
    required this.onModeChanged,
    required this.onTextScaleChanged,
  });

  final int selected;
  final double textScale;
  final bool showSelector;
  final bool flowMode;
  final ValueChanged<int> onSelected;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<double> onTextScaleChanged;

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
              if (!showSelector)
                const Text(
                  'Product prototype',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.start,
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
              if (!flowMode)
                _TextScaleControl(
                  value: textScale,
                  onChanged: onTextScaleChanged,
                ),
              if (showSelector && !flowMode)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 48,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: List.generate(
                        _DesignGalleryPageState.variants.length,
                        (index) => ButtonSegment(
                          value: index,
                          label: Text(
                            _DesignGalleryPageState.variants[index].key,
                          ),
                        ),
                      ),
                      selected: {selected},
                      onSelectionChanged: (value) => onSelected(value.first),
                    ),
                  ),
                )
              else
                Text(
                  flowMode
                      ? '버튼 → 화면 연결도'
                      : '${_DesignGalleryPageState.variants.length} screens',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextScaleControl extends StatelessWidget {
  const _TextScaleControl({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F3),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TextScaleButton(
            label: 'A−',
            tooltip: '글자 작게',
            enabled: value > 1.0,
            onTap: () => onChanged(value - .15),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          _TextScaleButton(
            label: 'A+',
            tooltip: '글자 크게',
            enabled: value < 1.3,
            onTap: () => onChanged(value + .15),
          ),
        ],
      ),
    );
  }
}

class _TextScaleButton extends StatelessWidget {
  const _TextScaleButton({
    required this.label,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 38,
          height: 32,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: enabled
                    ? AppColors.ink
                    : AppColors.muted.withValues(alpha: .35),
                fontSize: label == 'A+' ? 15 : 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.info,
    required this.textScale,
    required this.child,
  });

  final _VariantInfo info;
  final double textScale;
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
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child,
            ),
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
                  fontSize: 11,
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
                          fontSize: 12,
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
                                fontSize: 12,
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
        style: const TextStyle(fontSize: 11, color: AppColors.muted),
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
              fontSize: 11,
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
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
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
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
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
                        style: TextStyle(fontSize: 11),
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
              fontSize: 11,
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
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

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

class PlaceExplorerScreen extends StatefulWidget {
  const PlaceExplorerScreen({super.key, this.showBack = true});

  final bool showBack;

  @override
  State<PlaceExplorerScreen> createState() => _PlaceExplorerScreenState();
}

class _PlaceExplorerScreenState extends State<PlaceExplorerScreen> {
  int selectedCategory = 0;
  final Map<int, String> scheduledDays = {0: 'Tuesday, Sep 15'};

  static const places = [
    _ExplorePlace(
      id: 0,
      title: 'Myeongdong Cathedral',
      local: '명동성당',
      hours: 'Open · Closes 7:00 PM',
      travel: '8 min walk from L7',
      note: 'Available today',
      address: '서울특별시 중구 명동길 74',
      entrance: 'Main entrance on Myeongdong-gil',
      localEntrance: '명동길 정문',
      reservation: 'No reservation needed',
      state: _ExplorePlaceState.open,
      icon: Icons.church_rounded,
    ),
    _ExplorePlace(
      id: 1,
      title: 'N Seoul Tower',
      local: '남산서울타워',
      hours: 'Open · Closes 11:00 PM',
      travel: '22 min by transit',
      note: 'Good for the evening',
      address: '서울특별시 용산구 남산공원길 105',
      entrance: 'Seoul Tower Plaza entrance',
      localEntrance: '서울타워 플라자 입구',
      reservation: 'Ticket recommended',
      state: _ExplorePlaceState.open,
      icon: Icons.landscape_rounded,
    ),
    _ExplorePlace(
      id: 2,
      title: 'Namdaemun Market',
      local: '남대문시장',
      hours: 'Some shops close at 5:00 PM',
      travel: '15 min walk from L7',
      note: 'Go soon for more open shops',
      address: '서울특별시 중구 남대문시장4길 21',
      entrance: 'Gate 2 by Hoehyeon Station',
      localEntrance: '회현역 방향 2번 게이트',
      reservation: 'No reservation needed',
      state: _ExplorePlaceState.closing,
      icon: Icons.storefront_rounded,
    ),
    _ExplorePlace(
      id: 3,
      title: 'Gyeongbokgung Palace',
      local: '경복궁',
      hours: 'Closed on Tuesday',
      travel: '24 min by transit',
      note: 'Available Wed, Sep 16',
      address: '서울특별시 종로구 사직로 161',
      entrance: 'Gwanghwamun main gate',
      localEntrance: '광화문 정문',
      reservation: 'On-site ticket available',
      state: _ExplorePlaceState.closed,
      icon: Icons.temple_buddhist_rounded,
    ),
  ];

  List<_ExplorePlace> get visiblePlaces => switch (selectedCategory) {
    1 => places.where((place) => place.id != 2).toList(),
    2 => places.where((place) => place.id == 2).toList(),
    _ => places,
  };

  void _openDetail(_ExplorePlace place) {
    _showExplorePlaceDetail(
      context,
      place: place,
      scheduledDay: scheduledDays[place.id],
      onSave: (day) => setState(() => scheduledDays[place.id] = day),
      onRemove: () => setState(() => scheduledDays.remove(place.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _StayPickerMap(offset: Offset.zero)),
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
                    if (widget.showBack) ...[
                      _MapCircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: Navigator.of(context).canPop()
                            ? () => Navigator.pop(context)
                            : null,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _showPlaceSearch(
                            context,
                            places: places,
                            onSelected: _openDetail,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 13,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: AppColors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    'Search places in Seoul',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ExploreCategoryChip(
                        label: 'Near stay',
                        selected: selectedCategory == 0,
                        onTap: () => setState(() => selectedCategory = 0),
                      ),
                      const SizedBox(width: 7),
                      _ExploreCategoryChip(
                        label: 'Landmarks',
                        selected: selectedCategory == 1,
                        onTap: () => setState(() => selectedCategory = 1),
                      ),
                      const SizedBox(width: 7),
                      _ExploreCategoryChip(
                        label: 'Food & market',
                        selected: selectedCategory == 2,
                        onTap: () => setState(() => selectedCategory = 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 68,
          top: 215,
          child: _ExploreMapLabel(
            icon: Icons.hotel_rounded,
            label: 'L7',
            hotel: true,
          ),
        ),
        Positioned(
          right: 66,
          top: 190,
          child: _ExploreMapLabel(
            icon: Icons.church_rounded,
            label: 'Cathedral',
            onTap: () => _openDetail(places[0]),
          ),
        ),
        Positioned(
          right: 28,
          top: 270,
          child: _ExploreMapLabel(
            icon: Icons.landscape_rounded,
            label: 'N Tower',
            onTap: () => _openDetail(places[1]),
          ),
        ),
        Positioned(
          left: 142,
          top: 292,
          child: _ExploreMapLabel(
            icon: Icons.storefront_rounded,
            label: 'Market',
            warning: true,
            onTap: () => _openDetail(places[2]),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 492,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
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
                  const SizedBox(height: 14),
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Near L7 Myeongdong',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Add to Tuesday, Sep 15',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: visiblePlaces.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final place = visiblePlaces[index];
                        return _ExplorePlaceCard(
                          place: place,
                          added: scheduledDays.containsKey(place.id),
                          onTap: () => _openDetail(place),
                          onAdd: () => setState(
                            () => scheduledDays[place.id] = 'Tuesday, Sep 15',
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          '${scheduledDays.length} place${scheduledDays.length == 1 ? '' : 's'} saved',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: Navigator.of(context).canPop()
                            ? () => Navigator.pop(context)
                            : null,
                        child: const Text('Done'),
                      ),
                    ],
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

enum _ExplorePlaceState { open, closing, closed }

class _ExplorePlace {
  const _ExplorePlace({
    required this.id,
    required this.title,
    required this.local,
    required this.hours,
    required this.travel,
    required this.note,
    required this.address,
    required this.entrance,
    required this.localEntrance,
    required this.reservation,
    required this.state,
    required this.icon,
  });

  final int id;
  final String title;
  final String local;
  final String hours;
  final String travel;
  final String note;
  final String address;
  final String entrance;
  final String localEntrance;
  final String reservation;
  final _ExplorePlaceState state;
  final IconData icon;
}

class _ExploreCategoryChip extends StatelessWidget {
  const _ExploreCategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: Colors.white,
      selectedColor: AppColors.deepGreen,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.ink,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(color: selected ? AppColors.deepGreen : AppColors.line),
      padding: const EdgeInsets.symmetric(horizontal: 5),
    );
  }
}

class _ExploreMapLabel extends StatelessWidget {
  const _ExploreMapLabel({
    required this.icon,
    required this.label,
    this.hotel = false,
    this.warning = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool hotel;
  final bool warning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = hotel
        ? AppColors.ink
        : warning
        ? const Color(0xFFC88300)
        : AppColors.green;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: Colors.white),
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
      ),
    );
  }
}

class _ExplorePlaceCard extends StatelessWidget {
  const _ExplorePlaceCard({
    required this.place,
    required this.added,
    required this.onTap,
    required this.onAdd,
  });

  final _ExplorePlace place;
  final bool added;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final closed = place.state == _ExplorePlaceState.closed;
    final warning = place.state == _ExplorePlaceState.closing;
    final accent = closed
        ? const Color(0xFFB64B43)
        : warning
        ? const Color(0xFFC88300)
        : AppColors.green;
    return Material(
      color: closed ? const Color(0xFFFFF5F3) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(11, 10, 9, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: closed ? const Color(0xFFF0C3BE) : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${place.local} · ${place.travel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      place.hours,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: closed ? 68 : 55,
                height: 31,
                child: added
                    ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          disabledForegroundColor: AppColors.green,
                          side: const BorderSide(color: AppColors.green),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Added',
                          style: TextStyle(fontSize: 11),
                        ),
                      )
                    : FilledButton(
                        onPressed: closed ? onTap : onAdd,
                        style: FilledButton.styleFrom(
                          backgroundColor: closed
                              ? accent
                              : AppColors.deepGreen,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          closed ? 'Sep 16' : '+ Add',
                          style: const TextStyle(fontSize: 11),
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

void _showPlaceSearch(
  BuildContext context, {
  required List<_ExplorePlace> places,
  required ValueChanged<_ExplorePlace> onSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 15),
              const TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search landmarks, food or address',
                  prefixIcon: Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Color(0xFFF4F6F3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final place in places)
                ListTile(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Future<void>.delayed(
                      Duration.zero,
                      () => onSelected(place),
                    );
                  },
                  leading: Icon(place.icon, color: AppColors.green),
                  title: Text(
                    place.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    '${place.local} · ${place.hours}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showExplorePlaceDetail(
  BuildContext context, {
  required _ExplorePlace place,
  required String? scheduledDay,
  required ValueChanged<String> onSave,
  required VoidCallback onRemove,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _ExplorePlaceDetailSheet(
      place: place,
      scheduledDay: scheduledDay,
      onSave: (day) {
        onSave(day);
        Navigator.pop(sheetContext);
      },
      onRemove: () {
        onRemove();
        Navigator.pop(sheetContext);
      },
    ),
  );
}

class AttractionDetailScreen extends StatefulWidget {
  const AttractionDetailScreen({super.key});

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  String? scheduledDay = 'Tuesday, Sep 15';

  static const place = _ExplorePlace(
    id: 0,
    title: 'Myeongdong Cathedral',
    local: '명동성당',
    hours: 'Open · 9:00 AM–7:00 PM',
    travel: '8 min walk from L7',
    note: 'Last entry is 30 minutes before closing.',
    address: '서울특별시 중구 명동길 74',
    entrance: 'Main entrance on Myeongdong-gil',
    localEntrance: '명동길 정문',
    reservation: 'No reservation needed',
    state: _ExplorePlaceState.open,
    icon: Icons.church_rounded,
  );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE7ECE8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _ExplorePlaceDetailSheet(
          place: place,
          scheduledDay: scheduledDay,
          onSave: (day) => setState(() => scheduledDay = day),
          onRemove: () => setState(() => scheduledDay = null),
          fullHeight: true,
        ),
      ),
    );
  }
}

class _ExplorePlaceDetailSheet extends StatefulWidget {
  const _ExplorePlaceDetailSheet({
    required this.place,
    required this.scheduledDay,
    required this.onSave,
    required this.onRemove,
    this.fullHeight = false,
  });

  final _ExplorePlace place;
  final String? scheduledDay;
  final ValueChanged<String> onSave;
  final VoidCallback onRemove;
  final bool fullHeight;

  @override
  State<_ExplorePlaceDetailSheet> createState() =>
      _ExplorePlaceDetailSheetState();
}

class _ExplorePlaceDetailSheetState extends State<_ExplorePlaceDetailSheet> {
  late String selectedDay;

  bool get editing => widget.scheduledDay != null;

  @override
  void initState() {
    super.initState();
    selectedDay =
        widget.scheduledDay ??
        (widget.place.state == _ExplorePlaceState.closed
            ? 'Wednesday, Sep 16'
            : 'Tuesday, Sep 15');
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final closed =
        place.state == _ExplorePlaceState.closed &&
        selectedDay == 'Tuesday, Sep 15';
    final content = Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(28),
        bottom: widget.fullHeight ? const Radius.circular(28) : Radius.zero,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: editing ? AppColors.paleGreen : AppColors.ink,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        editing ? 'IN YOUR ITINERARY' : 'PLACE DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .5,
                          color: editing ? AppColors.green : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: closed
                            ? const Color(0xFFFFE4E0)
                            : AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        place.icon,
                        color: closed
                            ? const Color(0xFFB64B43)
                            : AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            place.local,
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
                const SizedBox(height: 17),
                const Text(
                  'Visit date',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _DetailDayChip(
                      day: 'Tue',
                      date: '15',
                      closed: place.state == _ExplorePlaceState.closed,
                      selected: selectedDay == 'Tuesday, Sep 15',
                      onTap: () =>
                          setState(() => selectedDay = 'Tuesday, Sep 15'),
                    ),
                    const SizedBox(width: 7),
                    _DetailDayChip(
                      day: 'Wed',
                      date: '16',
                      selected: selectedDay == 'Wednesday, Sep 16',
                      recommended: place.state == _ExplorePlaceState.closed,
                      onTap: () =>
                          setState(() => selectedDay = 'Wednesday, Sep 16'),
                    ),
                    const SizedBox(width: 7),
                    _DetailDayChip(
                      day: 'Thu',
                      date: '17',
                      selected: selectedDay == 'Thursday, Sep 17',
                      onTap: () =>
                          setState(() => selectedDay = 'Thursday, Sep 17'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _LocationCheckRow(
                  icon: Icons.schedule_rounded,
                  title: closed ? 'Closed on selected date' : 'Operating hours',
                  detail: closed ? 'Choose Wednesday or Thursday' : place.hours,
                ),
                const SizedBox(height: 10),
                _LocationCheckRow(
                  icon: Icons.door_front_door_rounded,
                  title: 'Visitor entrance · ${place.localEntrance}',
                  detail: place.entrance,
                ),
                const SizedBox(height: 10),
                _LocationCheckRow(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Reservation',
                  detail: place.reservation,
                ),
                const SizedBox(height: 10),
                _LocationCheckRow(
                  icon: Icons.translate_rounded,
                  title: 'Address in Korean',
                  detail: place.address,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: closed
                        ? const Color(0xFFFFF2D7)
                        : AppColors.paleGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    place.note,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _PrimaryAction(
                  label: closed
                      ? 'Choose an open date'
                      : editing
                      ? 'Save itinerary changes'
                      : 'Add to itinerary',
                  icon: editing ? Icons.check_rounded : Icons.add_rounded,
                  background: closed ? AppColors.line : AppColors.green,
                  foreground: closed ? AppColors.muted : Colors.white,
                  onTap: closed ? () {} : () => widget.onSave(selectedDay),
                ),
                if (editing) ...[
                  const SizedBox(height: 5),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.delete_outline_rounded, size: 17),
                      label: const Text('Remove from itinerary'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFB64B43),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    if (!widget.fullHeight) return content;
    return SizedBox(height: 780, child: content);
  }
}

class _DetailDayChip extends StatelessWidget {
  const _DetailDayChip({
    required this.day,
    required this.date,
    required this.selected,
    required this.onTap,
    this.closed = false,
    this.recommended = false,
  });

  final String day;
  final String date;
  final bool selected;
  final bool closed;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.deepGreen : const Color(0xFFF5F7F4),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? AppColors.deepGreen : AppColors.line,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$day $date',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
              Text(
                closed
                    ? 'Closed'
                    : recommended
                    ? 'Best day'
                    : 'Open',
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? Colors.white70
                      : closed
                      ? const Color(0xFFB64B43)
                      : AppColors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openPlaceExplorer(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: PlaceExplorerScreen()),
    ),
  );
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
                            fontSize: 11,
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
                        fontSize: 12,
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
                                      fontSize: 12,
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
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
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
  const UberHandoffPreview({super.key, this.uberInstalled = true});

  final bool uberInstalled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const NextMoveHome(),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .38)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _UberHandoffSheetContent(
            preview: true,
            uberInstalled: uberInstalled,
          ),
        ),
      ],
    );
  }
}

class _UberHandoffSheetContent extends StatelessWidget {
  const _UberHandoffSheetContent({
    this.preview = false,
    this.uberInstalled = true,
  });

  final bool preview;
  final bool uberInstalled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .92,
        ),
        child: SingleChildScrollView(
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            uberInstalled
                                ? 'Ready to open Uber?'
                                : 'Uber is not installed',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            uberInstalled
                                ? 'Check your pickup and destination first.'
                                : 'Install Uber before requesting this ride.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _UberBadge(available: uberInstalled),
                  ],
                ),
                const SizedBox(height: 18),
                const _HandoffRoute(),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: uberInstalled
                        ? AppColors.paleGreen
                        : const Color(0xFFFFEFEC),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        uberInstalled
                            ? Icons.check_circle_rounded
                            : Icons.mobile_off_rounded,
                        size: 17,
                        color: uberInstalled
                            ? AppColors.green
                            : const Color(0xFFB64B43),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          uberInstalled
                              ? 'Destination coordinates and Korean address are ready.'
                              : 'Ride requests are unavailable. Your route details are saved.',
                          style: const TextStyle(fontSize: 11),
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
                        onPressed: preview
                            ? null
                            : () => _showDriverCard(context),
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
                        onPressed: uberInstalled && preview
                            ? null
                            : () => _showPrototypeMessage(
                                context,
                                message: uberInstalled
                                    ? 'Uber 앱으로 이동할 준비가 되었습니다.'
                                    : 'Uber 앱스토어 페이지를 열 준비가 되었습니다.',
                              ),
                        icon: Icon(
                          uberInstalled
                              ? Icons.open_in_new_rounded
                              : Icons.download_rounded,
                          size: 17,
                        ),
                        label: Text(
                          uberInstalled ? 'Continue in Uber' : 'Install Uber',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: uberInstalled
                              ? AppColors.ink
                              : AppColors.green,
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
                Center(
                  child: Text(
                    uberInstalled
                        ? 'Fare, vehicle selection and payment continue in Uber.'
                        : 'Or return to route comparison and choose public transit.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UberBadge extends StatelessWidget {
  const _UberBadge({this.available = true});

  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: available ? AppColors.ink : const Color(0xFFFFE4DE),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        available ? 'UBER' : 'NOT INSTALLED',
        style: TextStyle(
          color: available ? Colors.white : const Color(0xFFB64B43),
          fontSize: 11,
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
            fontSize: 11,
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
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
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

enum _DepartureChoice { undecided, now, tenMinutes, delayed, skipped }

class DepartureAlertScreen extends StatefulWidget {
  const DepartureAlertScreen({super.key});

  @override
  State<DepartureAlertScreen> createState() => _DepartureAlertScreenState();
}

class _DepartureAlertScreenState extends State<DepartureAlertScreen> {
  _DepartureChoice choice = _DepartureChoice.undecided;

  Future<void> _skipNextPlace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip MMCA Seoul?'),
        content: const Text(
          'MMCA Seoul will stay in your saved places. Cheonggyecheon Stream becomes your next stop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep this stop'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip next place'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => choice = _DepartureChoice.skipped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skipped = choice == _DepartureChoice.skipped;
    final (eyebrow, title, detail, statusColor) = switch (choice) {
      _DepartureChoice.now => (
        'LEAVING NOW',
        'Ready to head out',
        'Arrive at MMCA around 1:52 PM',
        const Color(0xFF69C99C),
      ),
      _DepartureChoice.tenMinutes => (
        'REMINDER SET',
        'Leave in 10 minutes',
        'We will remind you again at 1:42 PM',
        AppColors.yellow,
      ),
      _DepartureChoice.delayed => (
        'RUNNING LATE',
        'About 25 minutes delayed',
        'Estimated arrival · 2:17 PM',
        const Color(0xFFF2A08C),
      ),
      _DepartureChoice.skipped => (
        'STOP SKIPPED',
        'Cheonggyecheon is next',
        '18 min by public transit',
        const Color(0xFF8CBDEA),
      ),
      _ => (
        'ON TIME',
        'Leave in 24 minutes',
        'Arrive at MMCA around 1:52 PM',
        const Color(0xFF69C99C),
      ),
    };

    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'Departure status',
            subtitle: 'Seoul · Day 2 · Updated now',
          ),
          const SizedBox(height: 17),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.deepGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              eyebrow,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '1:08 PM',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          style: const TextStyle(
                            color: Color(0xFFC7D8D0),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DepartureDestination(
                          icon: skipped
                              ? Icons.water_rounded
                              : Icons.museum_outlined,
                          title: skipped
                              ? 'Cheonggyecheon Stream'
                              : 'MMCA Seoul',
                          local: skipped ? '청계천' : '국립현대미술관 서울',
                          time: skipped ? 'Next' : '2:00 PM',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 19),
                  const Text('Update your departure', style: _sectionTitle),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose once. You can change it again at any time.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.now,
                          icon: Icons.directions_run_rounded,
                          title: 'Leave now',
                          detail: 'Start directions',
                          color: AppColors.green,
                          onTap: () =>
                              setState(() => choice = _DepartureChoice.now),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.tenMinutes,
                          icon: Icons.snooze_rounded,
                          title: 'Leave in 10 min',
                          detail: 'Remind me again',
                          color: const Color(0xFFB18316),
                          onTap: () => setState(
                            () => choice = _DepartureChoice.tenMinutes,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.delayed,
                          icon: Icons.schedule_rounded,
                          title: 'I am delayed',
                          detail: 'Recheck the day',
                          color: const Color(0xFFC45C4D),
                          onTap: () =>
                              setState(() => choice = _DepartureChoice.delayed),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.skipped,
                          icon: Icons.skip_next_rounded,
                          title: 'Skip next place',
                          detail: 'Keep it saved',
                          color: const Color(0xFF536A8A),
                          onTap: _skipNextPlace,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DepartureImpact(choice: choice),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _PrimaryAction(
            label: switch (choice) {
              _DepartureChoice.now => 'Start route',
              _DepartureChoice.tenMinutes => 'Keep 10-minute reminder',
              _DepartureChoice.delayed => 'Review adjusted itinerary',
              _DepartureChoice.skipped => 'Plan route to Cheonggyecheon',
              _ => 'Keep current departure',
            },
            icon: choice == _DepartureChoice.tenMinutes
                ? Icons.notifications_active_outlined
                : Icons.arrow_forward_rounded,
            background: AppColors.green,
            foreground: Colors.white,
            onTap: () =>
                _showPrototypeMessage(context, message: '출발 상태가 일정에 반영되었습니다.'),
          ),
        ],
      ),
    );
  }
}

class _DepartureDestination extends StatelessWidget {
  const _DepartureDestination({
    required this.icon,
    required this.title,
    required this.local,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String local;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.yellow, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  local,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartureActionCard extends StatelessWidget {
  const _DepartureActionCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartureImpact extends StatelessWidget {
  const _DepartureImpact({required this.choice});

  final _DepartureChoice choice;

  @override
  Widget build(BuildContext context) {
    final (icon, title, detail, warning) = switch (choice) {
      _DepartureChoice.now => (
        Icons.check_circle_outline_rounded,
        'You will arrive about 8 minutes early',
        'The rest of today stays unchanged.',
        false,
      ),
      _DepartureChoice.tenMinutes => (
        Icons.notifications_active_outlined,
        'Reminder scheduled for 1:42 PM',
        'You should still arrive before your reservation.',
        false,
      ),
      _DepartureChoice.delayed => (
        Icons.warning_amber_rounded,
        'Your 2:00 PM reservation may be affected',
        'Cheonggyecheon moves about 25 minutes later.',
        true,
      ),
      _DepartureChoice.skipped => (
        Icons.skip_next_rounded,
        'MMCA Seoul remains in saved places',
        'Cheonggyecheon is now your next destination.',
        false,
      ),
      _ => (
        Icons.event_available_outlined,
        'Your schedule is currently on time',
        'Leave by 1:32 PM to arrive around 1:52 PM.',
        false,
      ),
    };
    final color = warning ? const Color(0xFFB64B43) : AppColors.green;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFEFEC) : AppColors.paleGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum DefaultTravelMode { uber, transit, walk }

class TravelPreferences {
  const TravelPreferences({
    this.userLanguage = 'English',
    this.destinationLanguage = '한국어 · Korean',
    this.locationAllowed = true,
    this.uberInstalled = true,
    this.defaultMode = DefaultTravelMode.transit,
  });

  const TravelPreferences.standaloneHome()
    : userLanguage = 'English',
      destinationLanguage = '한국어 · Korean',
      locationAllowed = true,
      uberInstalled = true,
      defaultMode = DefaultTravelMode.uber;

  final String userLanguage;
  final String destinationLanguage;
  final bool locationAllowed;
  final bool uberInstalled;
  final DefaultTravelMode defaultMode;
}

String _travelCopy(
  String language, {
  required String english,
  required String korean,
  required String japanese,
}) {
  if (language.startsWith('한국어')) return korean;
  if (language.startsWith('日本語')) return japanese;
  return english;
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    this.initialPreferences = const TravelPreferences(),
    this.onSaved,
  });

  final TravelPreferences initialPreferences;
  final ValueChanged<TravelPreferences>? onSaved;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late String userLanguage;
  late String destinationLanguage;
  late bool locationAllowed;
  late bool uberInstalled;
  bool uberChecked = false;
  bool uberChecking = false;
  late DefaultTravelMode defaultMode;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPreferences;
    userLanguage = initial.userLanguage;
    destinationLanguage = initial.destinationLanguage;
    locationAllowed = initial.locationAllowed;
    uberInstalled = initial.uberInstalled;
    defaultMode = initial.defaultMode;
  }

  void _saveSettings() {
    widget.onSaved?.call(
      TravelPreferences(
        userLanguage: userLanguage,
        destinationLanguage: destinationLanguage,
        locationAllowed: locationAllowed,
        uberInstalled: uberInstalled,
        defaultMode: defaultMode,
      ),
    );
    _showPrototypeMessage(context, message: '사용자 설정이 여행 UI에 반영되었습니다.');
  }

  Future<void> _checkUberStatus() async {
    setState(() => uberChecking = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      uberChecking = false;
      uberChecked = true;
      uberInstalled = false;
      if (defaultMode == DefaultTravelMode.uber) {
        defaultMode = DefaultTravelMode.transit;
      }
    });
  }

  Future<void> _pickUserLanguage() async {
    final value = await _showSettingPicker(
      context,
      title: 'App language',
      current: userLanguage,
      options: const ['English', '한국어 · Korean', '日本語 · Japanese'],
    );
    if (value != null && mounted) setState(() => userLanguage = value);
  }

  Future<void> _pickDestinationLanguage() async {
    final value = await _showSettingPicker(
      context,
      title: 'Destination language',
      current: destinationLanguage,
      options: const ['한국어 · Korean', '日本語 · Japanese', '中文 · Chinese'],
    );
    if (value != null && mounted) {
      setState(() => destinationLanguage = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'Profile & settings',
            subtitle: 'Language, permissions and travel defaults',
            showProfile: false,
          ),
          const SizedBox(height: 17),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.deepGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: Color(0xFFF5D67B),
                          child: Text(
                            'MK',
                            style: TextStyle(
                              color: AppColors.deepGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Min Kim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Seoul trip · Sep 14–18',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Languages', style: _sectionTitle),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: 'App language',
                        detail: 'Menus and travel guidance',
                        value: userLanguage,
                        onTap: _pickUserLanguage,
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      _SettingsTile(
                        icon: Icons.record_voice_over_rounded,
                        title: 'Destination language',
                        detail: 'Local names and driver card',
                        value: destinationLanguage,
                        onTap: _pickDestinationLanguage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  const Text('Travel readiness', style: _sectionTitle),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _PermissionTile(
                        allowed: locationAllowed,
                        onChanged: (value) =>
                            setState(() => locationAllowed = value),
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      _UberInstallTile(
                        installed: uberInstalled,
                        checked: uberChecked,
                        checking: uberChecking,
                        onCheck: _checkUberStatus,
                        onInstall: () => _showPrototypeMessage(
                          context,
                          message: 'Uber 앱스토어 페이지를 열 준비가 되었습니다.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  const Text('Default travel mode', style: _sectionTitle),
                  const SizedBox(height: 4),
                  const Text(
                    'Used first when NextMate recommends your next move.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _DefaultModeOption(
                          selected: defaultMode == DefaultTravelMode.uber,
                          icon: Icons.local_taxi_rounded,
                          label: 'Uber',
                          onTap: () {
                            if (!uberInstalled) {
                              _showPrototypeMessage(
                                context,
                                message: 'Uber 설치 후 기본 이동수단으로 선택할 수 있습니다.',
                              );
                              return;
                            }
                            setState(
                              () => defaultMode = DefaultTravelMode.uber,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _DefaultModeOption(
                          selected: defaultMode == DefaultTravelMode.transit,
                          icon: Icons.directions_subway_rounded,
                          label: 'Transit',
                          onTap: () => setState(
                            () => defaultMode = DefaultTravelMode.transit,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _DefaultModeOption(
                          selected: defaultMode == DefaultTravelMode.walk,
                          icon: Icons.directions_walk_rounded,
                          label: 'Walk',
                          onTap: () => setState(
                            () => defaultMode = DefaultTravelMode.walk,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: AppColors.green,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location is used only for routes and nearby guidance while you use the app.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _PrimaryAction(
            label: 'Save settings',
            icon: Icons.check_rounded,
            background: AppColors.green,
            foreground: Colors.white,
            onTap: _saveSettings,
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(children: children),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _SettingIcon(icon: icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.chevron_right_rounded, size: 17),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.allowed, required this.onChanged});

  final bool allowed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const _SettingIcon(icon: Icons.location_on_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location permission',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                Text(
                  allowed ? 'While using the app' : 'Location guidance is off',
                  style: TextStyle(
                    fontSize: 11,
                    color: allowed ? AppColors.green : const Color(0xFFB64B43),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: allowed, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _UberInstallTile extends StatelessWidget {
  const _UberInstallTile({
    required this.installed,
    required this.checked,
    required this.checking,
    required this.onCheck,
    required this.onInstall,
  });

  final bool installed;
  final bool checked;
  final bool checking;
  final VoidCallback onCheck;
  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              _SettingIcon(
                icon: installed
                    ? Icons.local_taxi_outlined
                    : Icons.mobile_off_rounded,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uber app',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      checking
                          ? 'Checking this device…'
                          : installed
                          ? 'Installed · Ready to open'
                          : checked
                          ? 'Checked · Not installed'
                          : 'Installation not checked',
                      style: TextStyle(
                        fontSize: 11,
                        color: checking
                            ? AppColors.muted
                            : installed
                            ? AppColors.green
                            : const Color(0xFFB64B43),
                      ),
                    ),
                  ],
                ),
              ),
              if (checking)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else
                TextButton(
                  onPressed: installed ? onCheck : onInstall,
                  child: Text(installed ? 'Check again' : 'Get Uber'),
                ),
            ],
          ),
          if (!checking && checked && !installed) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Color(0xFFB64B43),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Ride requests are unavailable. Transit and walking remain available.',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: AppColors.paleGreen,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 17, color: AppColors.green),
  );
}

class _DefaultModeOption extends StatelessWidget {
  const _DefaultModeOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.green),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 15,
              color: selected ? AppColors.green : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _showSettingPicker(
  BuildContext context, {
  required String title,
  required String current,
  required List<String> options,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 11, 20, 20),
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
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              ...options.map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: option == current
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green,
                        )
                      : const Icon(
                          Icons.radio_button_off_rounded,
                          color: AppColors.muted,
                        ),
                  onTap: () => Navigator.pop(context, option),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

enum _RecoveryScenario {
  loading,
  emptySearch,
  offline,
  locationDenied,
  routeFailed,
  uberMissing,
  staleTransit,
}

extension on _RecoveryScenario {
  String get tabLabel => switch (this) {
    _RecoveryScenario.loading => 'Loading',
    _RecoveryScenario.emptySearch => 'No results',
    _RecoveryScenario.offline => 'Offline',
    _RecoveryScenario.locationDenied => 'Location',
    _RecoveryScenario.routeFailed => 'Route',
    _RecoveryScenario.uberMissing => 'Uber',
    _RecoveryScenario.staleTransit => 'Stale info',
  };

  String get eyebrow => switch (this) {
    _RecoveryScenario.loading => 'CHECKING LIVE OPTIONS',
    _RecoveryScenario.emptySearch => 'SEARCH COMPLETE',
    _RecoveryScenario.offline => 'CONNECTION LOST',
    _RecoveryScenario.locationDenied => 'ACTION REQUIRED',
    _RecoveryScenario.routeFailed => 'ROUTE UNAVAILABLE',
    _RecoveryScenario.uberMissing => 'APP REQUIRED',
    _RecoveryScenario.staleTransit => 'LAST UPDATED 8 MIN AGO',
  };

  String get title => switch (this) {
    _RecoveryScenario.loading => 'Finding your best route',
    _RecoveryScenario.emptySearch => 'No places match your search',
    _RecoveryScenario.offline => "You're offline",
    _RecoveryScenario.locationDenied => 'Turn on location for live guidance',
    _RecoveryScenario.routeFailed => 'No route found right now',
    _RecoveryScenario.uberMissing => "Uber isn't installed",
    _RecoveryScenario.staleTransit => 'Live times may be outdated',
  };

  String get description => switch (this) {
    _RecoveryScenario.loading =>
      'Checking traffic, train arrivals and walking time to MMCA Seoul.',
    _RecoveryScenario.emptySearch =>
      'Try a shorter place name, clear filters or search around your stay.',
    _RecoveryScenario.offline =>
      'Live routes cannot refresh, but your saved trip is still available.',
    _RecoveryScenario.locationDenied =>
      'NextMate needs your location only while you use directions and nearby search.',
    _RecoveryScenario.routeFailed =>
      'Transit data is temporarily unavailable for this departure time.',
    _RecoveryScenario.uberMissing =>
      'Install Uber to request a ride, or continue with another travel mode.',
    _RecoveryScenario.staleTransit =>
      'Platform and arrival details were saved earlier and may have changed.',
  };

  String get primaryAction => switch (this) {
    _RecoveryScenario.loading => 'Cancel route search',
    _RecoveryScenario.emptySearch => 'Clear search & filters',
    _RecoveryScenario.offline => 'Try connecting again',
    _RecoveryScenario.locationDenied => 'Open location settings',
    _RecoveryScenario.routeFailed => 'Try another travel mode',
    _RecoveryScenario.uberMissing => 'Open App Store',
    _RecoveryScenario.staleTransit => 'Refresh live times',
  };

  String? get secondaryAction => switch (this) {
    _RecoveryScenario.loading => null,
    _RecoveryScenario.emptySearch => 'Search near L7 Myeongdong',
    _RecoveryScenario.offline => 'Use saved trip offline',
    _RecoveryScenario.locationDenied => 'Enter a starting point',
    _RecoveryScenario.routeFailed => 'Retry this route',
    _RecoveryScenario.uberMissing => 'Use public transit instead',
    _RecoveryScenario.staleTransit => 'Keep saved route',
  };

  String get availableTitle => switch (this) {
    _RecoveryScenario.loading => 'You can keep browsing your itinerary',
    _RecoveryScenario.emptySearch => 'Your existing itinerary is unchanged',
    _RecoveryScenario.offline => 'Saved trip available offline',
    _RecoveryScenario.locationDenied => 'Manual starting point is available',
    _RecoveryScenario.routeFailed => 'Uber and walking are still available',
    _RecoveryScenario.uberMissing => 'Transit and walking still work',
    _RecoveryScenario.staleTransit => 'Saved station steps remain available',
  };

  IconData get icon => switch (this) {
    _RecoveryScenario.loading => Icons.route_rounded,
    _RecoveryScenario.emptySearch => Icons.search_off_rounded,
    _RecoveryScenario.offline => Icons.wifi_off_rounded,
    _RecoveryScenario.locationDenied => Icons.location_off_rounded,
    _RecoveryScenario.routeFailed => Icons.alt_route_rounded,
    _RecoveryScenario.uberMissing => Icons.mobile_off_rounded,
    _RecoveryScenario.staleTransit => Icons.history_rounded,
  };

  Color get color => switch (this) {
    _RecoveryScenario.loading => AppColors.green,
    _RecoveryScenario.emptySearch => const Color(0xFF52645A),
    _RecoveryScenario.offline => const Color(0xFFB64B43),
    _RecoveryScenario.locationDenied => const Color(0xFFB86D00),
    _RecoveryScenario.routeFailed => const Color(0xFFB64B43),
    _RecoveryScenario.uberMissing => const Color(0xFF27332D),
    _RecoveryScenario.staleTransit => const Color(0xFF9A6800),
  };

  Color get paleColor => switch (this) {
    _RecoveryScenario.loading => AppColors.paleGreen,
    _RecoveryScenario.emptySearch => const Color(0xFFF0F2F0),
    _RecoveryScenario.offline => const Color(0xFFFFEFEC),
    _RecoveryScenario.locationDenied => const Color(0xFFFFF2D7),
    _RecoveryScenario.routeFailed => const Color(0xFFFFEFEC),
    _RecoveryScenario.uberMissing => const Color(0xFFECEFED),
    _RecoveryScenario.staleTransit => const Color(0xFFFFF4D9),
  };
}

class RecoveryStatesScreen extends StatefulWidget {
  const RecoveryStatesScreen({super.key});

  @override
  State<RecoveryStatesScreen> createState() => _RecoveryStatesScreenState();
}

class _RecoveryStatesScreenState extends State<RecoveryStatesScreen> {
  _RecoveryScenario scenario = _RecoveryScenario.offline;

  void _handleAction(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$action selected'),
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'When plans change',
            subtitle: 'Clear status · useful fallback · next action',
            showProfile: false,
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 42,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _RecoveryScenario.values
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(item.tabLabel),
                          selected: scenario == item,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => scenario = item),
                          selectedColor: AppColors.deepGreen,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: scenario == item
                                ? Colors.white
                                : AppColors.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide(
                            color: scenario == item
                                ? AppColors.deepGreen
                                : AppColors.line,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SingleChildScrollView(
                key: ValueKey(scenario),
                child: _RecoveryStatePanel(
                  scenario: scenario,
                  onPrimary: () => _handleAction(scenario.primaryAction),
                  onSecondary: scenario.secondaryAction == null
                      ? null
                      : () => _handleAction(scenario.secondaryAction!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryStatePanel extends StatelessWidget {
  const _RecoveryStatePanel({
    required this.scenario,
    required this.onPrimary,
    required this.onSecondary,
  });

  final _RecoveryScenario scenario;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: scenario.paleColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              scenario.eyebrow,
              style: TextStyle(
                color: scenario.color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scenario.paleColor,
              shape: BoxShape.circle,
            ),
            child: scenario == _RecoveryScenario.loading
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: scenario.color,
                    ),
                  )
                : Icon(scenario.icon, color: scenario.color, size: 27),
          ),
          const SizedBox(height: 17),
          Text(
            scenario.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            scenario.description,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (scenario == _RecoveryScenario.loading) ...[
            const SizedBox(height: 18),
            const _RouteLoadingPreview(),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: scenario.paleColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: scenario.color,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What still works',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scenario.availableTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PrimaryAction(
            label: scenario.primaryAction,
            icon: scenario == _RecoveryScenario.loading
                ? Icons.close_rounded
                : Icons.arrow_forward_rounded,
            background: scenario.color,
            foreground: Colors.white,
            onTap: onPrimary,
          ),
          if (onSecondary != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondary,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  scenario.secondaryAction!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteLoadingPreview extends StatelessWidget {
  const _RouteLoadingPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LinearProgressIndicator(
          minHeight: 4,
          color: AppColors.green,
          backgroundColor: AppColors.paleGreen,
        ),
        const SizedBox(height: 13),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9ECE9),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: index == 1 ? .72 : .55,
                        child: Container(
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E4E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FractionallySizedBox(
                        widthFactor: index == 2 ? .48 : .36,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF0EE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  String language = 'English';
  bool locationAllowed = false;
  bool uberInstalled = false;

  void _continue() {
    if (step < 3) {
      setState(() {
        if (step == 2) locationAllowed = true;
        step += 1;
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: TripSetupScreen()),
      ),
    );
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'NextMate',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              if (step < 3)
                TextButton(
                  onPressed: () => setState(() => step = 3),
                  child: const Text('Skip setup'),
                ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: List.generate(4, (index) {
              final active = index <= step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: active ? AppColors.green : AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'STEP ${step + 1} OF 4',
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SingleChildScrollView(
                key: ValueKey(step),
                child: switch (step) {
                  0 => const _OnboardingIntro(),
                  1 => _OnboardingLanguage(
                    selected: language,
                    onChanged: (value) => setState(() => language = value),
                  ),
                  2 => _OnboardingLocation(allowed: locationAllowed),
                  _ => _OnboardingUber(
                    installed: uberInstalled,
                    onChanged: (value) => setState(() => uberInstalled = value),
                  ),
                },
              ),
            ),
          ),
          if (step > 0) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => setState(() => step -= 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back'),
              ),
            ),
          ],
          const SizedBox(height: 5),
          _PrimaryAction(
            label: switch (step) {
              0 => 'See how it works',
              1 => 'Continue in $language',
              2 => locationAllowed ? 'Continue' : 'Allow location & continue',
              _ => 'Start planning my trip',
            },
            icon: step == 3 ? Icons.check_rounded : Icons.arrow_forward_rounded,
            background: AppColors.green,
            foreground: Colors.white,
            onTap: _continue,
          ),
        ],
      ),
    );
  }
}

class _OnboardingIntro extends StatelessWidget {
  const _OnboardingIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.travel_explore_rounded,
          title: 'Travel with confidence',
          detail:
              'NextMate keeps your stays, daily plans and next move together.',
        ),
        const SizedBox(height: 18),
        const Text('What NextMate helps with', style: _sectionTitle),
        const SizedBox(height: 9),
        const _OnboardingFeature(
          icon: Icons.calendar_month_rounded,
          title: 'Build days around your stays',
          detail: 'Keep every date, hotel and open time easy to understand.',
        ),
        const SizedBox(height: 8),
        const _OnboardingFeature(
          icon: Icons.compare_arrows_rounded,
          title: 'Compare every way to go',
          detail: 'See Uber, transit and walking time and cost together.',
        ),
        const SizedBox(height: 8),
        const _OnboardingFeature(
          icon: Icons.assistant_direction_rounded,
          title: 'Get tourist-friendly guidance',
          detail: 'Follow stations, transfers, exits and local-language help.',
        ),
      ],
    );
  }
}

class _OnboardingLanguage extends StatelessWidget {
  const _OnboardingLanguage({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const languages = [
      ('English', 'English'),
      ('한국어', 'Korean'),
      ('日本語', 'Japanese'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.translate_rounded,
          title: 'Choose your language',
          detail: 'You can change this later in Profile & settings.',
        ),
        const SizedBox(height: 18),
        ...languages.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OnboardingChoice(
              selected: selected == item.$1,
              title: item.$1,
              detail: item.$2,
              onTap: () => onChanged(item.$1),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.language_rounded, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'For this Seoul trip, Korean names and addresses will also be shown.',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingLocation extends StatelessWidget {
  const _OnboardingLocation({required this.allowed});

  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.my_location_rounded,
          title: 'Know what is nearby',
          detail:
              'Allow location while using the app for routes and departure reminders.',
        ),
        const SizedBox(height: 18),
        Container(
          height: 175,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFEA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _MapCanvas()),
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.green, width: 4),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 12),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_pin_circle_rounded,
                    color: AppColors.green,
                    size: 31,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _PermissionReason(
          icon: Icons.route_rounded,
          title: 'Routes from where you are',
        ),
        const SizedBox(height: 7),
        const _PermissionReason(
          icon: Icons.notifications_active_outlined,
          title: 'Useful departure reminders',
        ),
        const SizedBox(height: 7),
        const _PermissionReason(
          icon: Icons.lock_outline_rounded,
          title: 'Only while you use NextMate',
        ),
        if (allowed) ...[
          const SizedBox(height: 9),
          const Text(
            'Location permission is ready.',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

class _OnboardingUber extends StatelessWidget {
  const _OnboardingUber({required this.installed, required this.onChanged});

  final bool installed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.local_taxi_rounded,
          title: 'Get Uber ready',
          detail:
              'NextMate prepares pickup and destination, then hands off to Uber.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: installed ? AppColors.green : AppColors.line,
              width: installed ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'UBER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uber app status',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      installed ? 'Installed · Ready' : 'Not confirmed yet',
                      style: TextStyle(
                        color: installed ? AppColors.green : AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                installed
                    ? Icons.check_circle_rounded
                    : Icons.help_outline_rounded,
                color: installed ? AppColors.green : AppColors.muted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => onChanged(!installed),
            icon: Icon(
              installed
                  ? Icons.remove_circle_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: 17,
            ),
            label: Text(
              installed ? 'Uber is not installed' : 'Uber is installed',
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _OnboardingFeature(
          icon: Icons.pin_drop_outlined,
          title: 'Pickup point checked first',
          detail: 'Confirm the exact entrance before opening Uber.',
        ),
        const SizedBox(height: 8),
        const _OnboardingFeature(
          icon: Icons.translate_rounded,
          title: 'Driver card is always available',
          detail: 'Show the destination and entrance in the local language.',
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'You can finish setup even without Uber.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.yellow, size: 23),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              color: Color(0xFFC7D8D0),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingFeature extends StatelessWidget {
  const _OnboardingFeature({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingChoice extends StatelessWidget {
  const _OnboardingChoice({
    required this.selected,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
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
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.green : AppColors.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionReason extends StatelessWidget {
  const _PermissionReason({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.green, size: 17),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class TravelAppShell extends StatefulWidget {
  const TravelAppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<TravelAppShell> createState() => _TravelAppShellState();
}

class _TravelAppShellState extends State<TravelAppShell> {
  late int selectedIndex;
  TravelPreferences preferences = const TravelPreferences();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          NextMoveHome(
            preferences: preferences,
            onViewTrip: () => setState(() => selectedIndex = 1),
            onOpenProfile: () => setState(() => selectedIndex = 3),
          ),
          const TripOverviewScreen(showBack: false),
          const PlaceExplorerScreen(showBack: false),
          ProfileSettingsScreen(
            initialPreferences: preferences,
            onSaved: (value) => setState(() => preferences = value),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.paleGreen,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Today',
              korean: '오늘',
              japanese: '今日',
            ),
          ),
          NavigationDestination(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.calendar_month_outlined),
            ),
            selectedIcon: const Badge(
              label: Text('2'),
              child: Icon(Icons.calendar_month_rounded),
            ),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Trip',
              korean: '일정',
              japanese: '旅程',
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Explore',
              korean: '장소',
              japanese: '探索',
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Profile',
              korean: '프로필',
              japanese: '設定',
            ),
          ),
        ],
      ),
    );
  }
}

class NextMoveHome extends StatelessWidget {
  const NextMoveHome({
    super.key,
    this.preferences = const TravelPreferences.standaloneHome(),
    this.onViewTrip,
    this.onOpenProfile,
  });

  final TravelPreferences preferences;
  final VoidCallback? onViewTrip;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final language = preferences.userLanguage;
    final effectiveMode =
        preferences.defaultMode == DefaultTravelMode.uber &&
            !preferences.uberInstalled
        ? DefaultTravelMode.transit
        : preferences.defaultMode;
    final modeLabel = switch (effectiveMode) {
      DefaultTravelMode.uber => 'Uber',
      DefaultTravelMode.transit => _travelCopy(
        language,
        english: 'Transit',
        korean: '대중교통',
        japanese: '公共交通',
      ),
      DefaultTravelMode.walk => _travelCopy(
        language,
        english: 'Walk',
        korean: '도보',
        japanese: '徒歩',
      ),
    };
    final destinationName = preferences.destinationLanguage.startsWith('日本語')
        ? '国立現代美術館 ソウル館 · 2:00 PM'
        : preferences.destinationLanguage.startsWith('中文')
        ? '国立现代美术馆 首尔馆 · 2:00 PM'
        : '국립현대미술관 서울 · 2:00 PM';
    final primaryLabel = switch (effectiveMode) {
      DefaultTravelMode.uber => _travelCopy(
        language,
        english: 'Prepare an Uber',
        korean: 'Uber 호출 준비',
        japanese: 'Uberを準備',
      ),
      DefaultTravelMode.transit => _travelCopy(
        language,
        english: 'View transit steps',
        korean: '대중교통 단계 보기',
        japanese: '乗換案内を見る',
      ),
      DefaultTravelMode.walk => _travelCopy(
        language,
        english: 'Start walking directions',
        korean: '도보 길안내 시작',
        japanese: '徒歩案内を開始',
      ),
    };
    final primaryIcon = switch (effectiveMode) {
      DefaultTravelMode.uber => Icons.local_taxi_rounded,
      DefaultTravelMode.transit => Icons.directions_subway_rounded,
      DefaultTravelMode.walk => Icons.directions_walk_rounded,
    };

    void openPreferredMode() {
      switch (effectiveMode) {
        case DefaultTravelMode.uber:
          _showUberHandoff(context);
          return;
        case DefaultTravelMode.transit:
          _openTransitGuide(context);
          return;
        case DefaultTravelMode.walk:
          _showPrototypeMessage(context, message: '도보 길안내를 시작할 준비가 되었습니다.');
          return;
      }
    }

    return _PhonePage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppHeader(
              title: _travelCopy(
                language,
                english: 'Seoul · Day 2',
                korean: '서울 · 여행 2일차',
                japanese: 'ソウル · 2日目',
              ),
              subtitle: _travelCopy(
                language,
                english: 'Tuesday, September 15',
                korean: '9월 15일 화요일',
                japanese: '9月15日 火曜日',
              ),
              onProfileTap:
                  onOpenProfile ?? () => _openProfileSettings(context),
            ),
            const SizedBox(height: 22),
            _LocationLine(
              label: 'Bukchon Hanok Village',
              enabled: preferences.locationAllowed,
              disabledLabel: _travelCopy(
                language,
                english: 'Location off · Using your stay',
                korean: '위치 꺼짐 · 숙소를 출발지로 사용',
                japanese: '位置情報オフ · 宿泊先を使用',
              ),
            ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_travelCopy(language, english: 'NEXT STOP', korean: '다음 장소', japanese: '次の場所')} · ${modeLabel.toUpperCase()}',
                          style: const TextStyle(
                            color: Color(0xFFAED8C4),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const Icon(Icons.more_horiz, color: Colors.white70),
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
                  Text(
                    destinationName,
                    style: const TextStyle(
                      color: Color(0xFFC7D8D0),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),
                  InkWell(
                    onTap: () => _openDepartureAlert(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
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
                          Text(
                            'MANAGE',
                            style: TextStyle(
                              color: AppColors.yellow,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .6,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAction(
                    label: primaryLabel,
                    icon: primaryIcon,
                    background: const Color(0xFFF7F0D5),
                    foreground: AppColors.ink,
                    onTap: openPreferredMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _travelCopy(
                language,
                english: 'Other ways to get there',
                korean: '다른 이동 방법',
                japanese: 'ほかの移動方法',
              ),
              style: _sectionTitle,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ModeTile(
                    icon: Icons.directions_subway_rounded,
                    title: _travelCopy(
                      language,
                      english: 'Transit',
                      korean: '대중교통',
                      japanese: '公共交通',
                    ),
                    detail: '24 min · Direct',
                    onTap: () => _openTransitGuide(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModeTile(
                    icon: Icons.directions_walk_rounded,
                    title: _travelCopy(
                      language,
                      english: 'Walk',
                      korean: '도보',
                      japanese: '徒歩',
                    ),
                    detail: '31 min · 2.1 km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openRouteComparison(
                  context,
                  uberInstalled: preferences.uberInstalled,
                ),
                icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                label: Text(
                  _travelCopy(
                    language,
                    english: 'Compare time & cost',
                    korean: '시간과 비용 비교',
                    japanese: '時間と料金を比較',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _travelCopy(
                      language,
                      english: 'Today',
                      korean: '오늘 일정',
                      japanese: '今日の予定',
                    ),
                    style: _sectionTitle,
                  ),
                ),
                TextButton(
                  onPressed:
                      onViewTrip ??
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const Scaffold(body: TripOverviewScreen()),
                        ),
                      ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _travelCopy(
                      language,
                      english: 'View itinerary',
                      korean: '전체 일정',
                      japanese: '旅程を見る',
                    ),
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
          _AppHeader(
            title: 'Today in Seoul',
            subtitle: '3 of 5 places remaining',
            onProfileTap: () => _openProfileSettings(context),
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
            child: SingleChildScrollView(
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
                  onTap: () => _openRouteComparison(context),
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
  const _AppHeader({
    required this.title,
    required this.subtitle,
    this.onProfileTap,
    this.showProfile = true,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onProfileTap;
  final bool showProfile;

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
        if (showProfile)
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(Icons.person_outline_rounded, size: 21),
            ),
          ),
      ],
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({
    required this.label,
    this.enabled = true,
    this.disabledLabel = 'Location is off',
  });
  final String label;
  final bool enabled;
  final String disabledLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          enabled ? Icons.my_location_rounded : Icons.location_off_rounded,
          size: 16,
          color: enabled ? AppColors.green : const Color(0xFFB86D00),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            enabled ? label : disabledLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: enabled ? AppColors.ink : const Color(0xFFB86D00),
            ),
          ),
        ),
        Text(
          enabled ? 'Updated now' : 'SETTINGS',
          style: TextStyle(
            fontSize: 11,
            color: enabled ? AppColors.muted : const Color(0xFFB86D00),
            fontWeight: enabled ? FontWeight.w400 : FontWeight.w800,
          ),
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
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
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
      height: 80,
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
                fontSize: 12,
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

void _openRouteComparison(BuildContext context, {bool uberInstalled = true}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          Scaffold(body: RouteComparisonScreen(uberInstalled: uberInstalled)),
    ),
  );
}

void _openDepartureAlert(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: DepartureAlertScreen()),
    ),
  );
}

void _openProfileSettings(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: ProfileSettingsScreen()),
    ),
  );
}

void _showPrototypeMessage(
  BuildContext context, {
  String message = '다음 단계는 프로토타입에서 제공되지 않습니다.',
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _VariantInfo {
  const _VariantInfo(this.key, this.title, this.description);
  final String key;
  final String title;
  final String description;
}

const _sectionTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800);

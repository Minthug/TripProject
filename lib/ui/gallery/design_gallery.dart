part of '../../main.dart';

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
    _VariantInfo('AU', 'Sign in', 'Google·Apple·이메일 로그인과 회원가입'),
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
    18 => const RecoveryStatesScreen(),
    _ => const AuthScreen(),
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

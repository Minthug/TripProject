part of '../../main.dart';

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

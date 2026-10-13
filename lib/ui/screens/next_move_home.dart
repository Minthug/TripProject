part of '../../main.dart';

class NextMoveHome extends StatelessWidget {
  const NextMoveHome({
    super.key,
    this.preferences = const TravelPreferences.standaloneHome(),
    this.onViewTrip,
    this.onOpenProfile,
    this.liveData,
    this.onRefresh,
    this.onAdvancePlace,
    this.onComparePlace,
    this.advancingPlace = false,
  });

  final TravelPreferences preferences;
  final VoidCallback? onViewTrip;
  final VoidCallback? onOpenProfile;
  final LiveTripData? liveData;
  final Future<void> Function()? onRefresh;
  final Future<void> Function(Json item, String status)? onAdvancePlace;
  final Future<void> Function(Json item)? onComparePlace;
  final bool advancingPlace;

  @override
  Widget build(BuildContext context) {
    final live = liveData;
    final liveDay = live?.currentDay;
    final today = _liveDate(DateTime.now());
    final beforeTrip = live != null && today.compareTo(live.trip.startDate) < 0;
    final afterTrip = live != null && today.compareTo(live.trip.endDate) > 0;
    final liveItems = liveDay == null ? <Json>[] : live!.itemsFor(liveDay);
    final nextItem = liveItems
        .where(
          (item) =>
              item['progress_status'] != 'completed' &&
              item['progress_status'] != 'skipped',
        )
        .firstOrNull;
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
      child: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppHeader(
                title: live == null
                    ? _travelCopy(
                        language,
                        english: 'Seoul · Day 2',
                        korean: '서울 · 여행 2일차',
                        japanese: 'ソウル · 2日目',
                      )
                    : '${live.trip.destinationName} · ${beforeTrip
                          ? '여행 시작 전'
                          : afterTrip
                          ? '지난 여행'
                          : '${live.days.indexOf(liveDay!) + 1}일차'}',
                subtitle: live == null
                    ? _travelCopy(
                        language,
                        english: 'Tuesday, September 15',
                        korean: '9월 15일 화요일',
                        japanese: '9月15日 火曜日',
                      )
                    : '${live.trip.title} · $liveDay',
                onProfileTap:
                    onOpenProfile ?? () => _openProfileSettings(context),
              ),
              const SizedBox(height: 22),
              if (live == null)
                _LocationLine(
                  label: 'Bukchon Hanok Village',
                  enabled: preferences.locationAllowed,
                  disabledLabel: _travelCopy(
                    language,
                    english: 'Location off · Using your stay',
                    korean: '위치 꺼짐 · 숙소를 출발지로 사용',
                    japanese: '位置情報オフ · 宿泊先を使用',
                  ),
                )
              else
                const _LocationLine(
                  label: '',
                  enabled: false,
                  disabledLabel: '현재 위치 확인은 연결 전이에요',
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
                            live == null
                                ? '${_travelCopy(language, english: 'NEXT STOP', korean: '다음 장소', japanese: '次の場所')} · ${modeLabel.toUpperCase()}'
                                : '${beforeTrip
                                      ? 'FIRST DAY'
                                      : afterTrip
                                      ? 'LAST DAY'
                                      : 'NEXT STOP'} · ${live.days.indexOf(liveDay!) + 1}일차',
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
                    Text(
                      live == null
                          ? 'MMCA Seoul'
                          : nextItem == null
                          ? liveItems.isEmpty
                                ? '예정된 장소가 없어요'
                                : '이날 일정을 모두 마쳤어요'
                          : live.placeName(nextItem),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      live == null
                          ? destinationName
                          : nextItem == null && liveItems.isNotEmpty
                          ? '다른 날짜의 일정은 전체 일정에서 확인하세요.'
                          : nextItem?['notes'] as String? ??
                                '일정에서 방문 장소를 추가해 주세요.',
                      style: const TextStyle(
                        color: Color(0xFFC7D8D0),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (live == null)
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
                    if (live != null)
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .11),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.route_rounded, color: AppColors.yellow),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '실시간 경로·출발 알림은 아직 연결되지 않았어요.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    if (live != null &&
                        nextItem != null &&
                        onAdvancePlace != null) ...[
                      _PrimaryAction(
                        label: advancingPlace ? '처리 중...' : '방문 완료 · 다음 장소',
                        icon: Icons.arrow_forward_rounded,
                        background: const Color(0xFFF7F0D5),
                        foreground: AppColors.ink,
                        onTap: () {
                          if (!advancingPlace) {
                            onAdvancePlace!(nextItem, 'completed');
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: advancingPlace
                                ? null
                                : () => onAdvancePlace!(nextItem, 'skipped'),
                            icon: const Icon(Icons.skip_next_rounded, size: 18),
                            label: const Text('건너뛰고 다음 장소'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: onViewTrip,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            child: const Text('전체 일정'),
                          ),
                        ],
                      ),
                    ] else
                      _PrimaryAction(
                        label: live == null ? primaryLabel : '전체 일정 보기',
                        icon: live == null
                            ? primaryIcon
                            : Icons.calendar_month_rounded,
                        background: const Color(0xFFF7F0D5),
                        foreground: AppColors.ink,
                        onTap: live == null
                            ? openPreferredMode
                            : onViewTrip ?? () {},
                      ),
                    if (live != null &&
                        nextItem != null &&
                        onComparePlace != null) ...[
                      const SizedBox(height: 9),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => onComparePlace!(nextItem),
                          icon: const Icon(Icons.compare_arrows_rounded),
                          label: const Text('이동수단 비교'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (live == null) ...[
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
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _travelCopy(
                        language,
                        english: live == null
                            ? 'Today'
                            : beforeTrip
                            ? 'First-day itinerary'
                            : afterTrip
                            ? 'Last-day itinerary'
                            : 'Today',
                        korean: live == null
                            ? '오늘 일정'
                            : beforeTrip
                            ? '첫날 일정'
                            : afterTrip
                            ? '마지막 날 일정'
                            : '오늘 일정',
                        japanese: live == null
                            ? '今日の予定'
                            : beforeTrip
                            ? '初日の予定'
                            : afterTrip
                            ? '最終日の予定'
                            : '今日の予定',
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
              if (live == null)
                const _MiniTimeline()
              else if (liveItems.isEmpty)
                const Text('이 날짜에 등록된 방문 장소가 없어요.')
              else
                for (var index = 0; index < liveItems.length; index++)
                  _TimelineRow(
                    time: '${index + 1}',
                    title: live.placeName(liveItems[index]),
                    subtitle: switch (liveItems[index]['progress_status']) {
                      'completed' => '방문 완료',
                      'skipped' => '건너뜀',
                      _ => liveItems[index]['notes'] as String? ?? '방문 예정',
                    },
                    state:
                        liveItems[index]['progress_status'] == 'completed' ||
                            liveItems[index]['progress_status'] == 'skipped'
                        ? _TimelineState.done
                        : liveItems[index] == nextItem
                        ? _TimelineState.current
                        : _TimelineState.upcoming,
                    drawLine: index < liveItems.length - 1,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

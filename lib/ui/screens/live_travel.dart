part of '../../main.dart';

/// Signed-in version of the existing four-tab design. Gallery screens keep
/// their sample data; this branch never shows another traveler's fake trip.
class _LiveTravelShell extends StatefulWidget {
  const _LiveTravelShell({
    required this.backend,
    this.accountEmail,
    this.onSignOut,
  });

  final NextMateBackend backend;
  final String? accountEmail;
  final Future<void> Function()? onSignOut;

  @override
  State<_LiveTravelShell> createState() => _LiveTravelShellState();
}

class _LiveTravelShellState extends State<_LiveTravelShell> {
  late Future<LiveTripData?> _tripFuture;
  String? _selectedTripId;
  int _tab = 0;
  bool _advancingPlace = false;
  TravelPreferences _preferences = const TravelPreferences();
  bool _preferencesReady = false;
  bool _preferencesFailed = false;

  @override
  void initState() {
    super.initState();
    _tripFuture = _loadInitialTrip();
    _loadPreferences();
  }

  String get _tripSelectionKey =>
      'selected_trip_${widget.backend.client.auth.currentUser?.id ?? 'unknown'}';

  Future<LiveTripData?> _loadInitialTrip() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _selectedTripId = preferences.getString(_tripSelectionKey);
    } catch (_) {
      // Trip loading still works when local preference storage is unavailable.
    }
    return LiveTripData.load(widget.backend, selectedTripId: _selectedTripId);
  }

  Future<void> _rememberTrip(String id) async {
    _selectedTripId = id;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tripSelectionKey, id);
    } catch (_) {
      // Keep the current selection for this session even if storage fails.
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final profile = await widget.backend.profile.getProfile();
      final settings = await widget.backend.profile.getPreferences();
      if (!mounted) return;
      setState(() {
        _preferences = TravelPreferences(
          userLanguage: switch (profile['user_language']) {
            'ko' => '한국어 · Korean',
            'ja' => '日本語 · Japanese',
            _ => 'English',
          },
          destinationLanguage: switch (settings['destination_language']) {
            'ja' => '日本語 · Japanese',
            'zh' => '中文 · Chinese',
            _ => '한국어 · Korean',
          },
          locationAllowed: {
            'while_in_use',
            'always',
          }.contains(settings['location_permission_status']),
          uberInstalled: settings['uber_install_status'] == 'installed',
          defaultMode: switch (settings['default_transport_mode']) {
            'walking' => DefaultTravelMode.walk,
            'uber' => DefaultTravelMode.uber,
            _ => DefaultTravelMode.transit,
          },
        );
        _preferencesReady = true;
        _preferencesFailed = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _preferencesReady = true;
          _preferencesFailed = true;
        });
      }
    }
  }

  Future<void> _savePreferences(TravelPreferences value) async {
    await widget.backend.profile.updateProfile({
      'user_language': value.userLanguage.startsWith('한국어')
          ? 'ko'
          : value.userLanguage.startsWith('日本語')
          ? 'ja'
          : 'en',
    });
    await widget.backend.profile.updatePreferences({
      'destination_language': value.destinationLanguage.startsWith('日本語')
          ? 'ja'
          : value.destinationLanguage.startsWith('中文')
          ? 'zh'
          : 'ko',
      'default_transport_mode': switch (value.defaultMode) {
        DefaultTravelMode.walk => 'walking',
        DefaultTravelMode.uber => 'uber',
        DefaultTravelMode.transit => 'transit',
      },
    });
    if (mounted) setState(() => _preferences = value);
  }

  Future<void> _refresh() async {
    final next = LiveTripData.load(
      widget.backend,
      selectedTripId: _selectedTripId,
    );
    setState(() {
      _tripFuture = next;
    });
    await next;
  }

  Future<void> _selectTrip(String id) async {
    await _rememberTrip(id);
    await _refresh();
  }

  Future<void> _compareCurrentPlace(Json item) async {
    final trip = await _tripFuture;
    if (trip == null || !mounted) return;
    final items = trip.itemsFor(trip.currentDay);
    final index = items.indexWhere((row) => row['id'] == item['id']);
    Json? originPlace;
    for (var position = index - 1; position >= 0; position--) {
      if (items[position]['progress_status'] == 'completed') {
        originPlace = trip.places[items[position]['place_id']];
        break;
      }
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiveRouteComparisonScreen(
          backend: widget.backend,
          data: trip,
          destinationItem: item,
          originPlace: originPlace,
          uberInstalled: _preferences.uberInstalled,
        ),
      ),
    );
  }

  Future<void> _advancePlace(Json item, String status) async {
    if (_advancingPlace) return;
    final itemId = item['id'] as String;
    final previousStatus = item['progress_status'] as String? ?? 'planned';
    setState(() => _advancingPlace = true);
    try {
      final trip = await _tripFuture;
      if (trip == null || !mounted) return;
      await widget.backend.itinerary.update(trip.trip.id, itemId, {
        'progress_status': status,
      });
      await _refresh();
      if (!mounted) return;
      Future<bool> undoAdvance() async {
        try {
          await widget.backend.itinerary.update(trip.trip.id, itemId, {
            'progress_status': previousStatus,
          });
          if (mounted) await _refresh();
          return true;
        } catch (_) {
          if (mounted) _liveNotice(context, '방문 상태를 되돌리지 못했어요.');
          return false;
        }
      }

      final currentDayItems = trip.itemsFor(trip.currentDay);
      final currentIndex = currentDayItems.indexWhere(
        (row) => row['id'] == itemId,
      );
      final nextItem = currentDayItems
          .skip(currentIndex + 1)
          .where(
            (row) =>
                row['progress_status'] != 'completed' &&
                row['progress_status'] != 'skipped',
          )
          .firstOrNull;
      if (nextItem != null) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LiveRouteComparisonScreen(
              backend: widget.backend,
              data: trip,
              destinationItem: nextItem,
              originPlace: status == 'completed'
                  ? trip.places[item['place_id']]
                  : null,
              uberInstalled: _preferences.uberInstalled,
              onUndo: undoAdvance,
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              status == 'completed' ? '방문 완료 · 다음 장소로 이동했어요.' : '이 장소를 건너뛰었어요.',
            ),
            action: SnackBarAction(label: '되돌리기', onPressed: undoAdvance),
          ),
        );
    } catch (_) {
      if (mounted) _liveNotice(context, '다음 장소로 이동하지 못했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _advancingPlace = false);
    }
  }

  Future<void> _editTrip([Trip? existing]) async {
    final input = await showDialog<TripInput>(
      context: context,
      builder: (_) => _LiveTripDialog(existing: existing),
    );
    if (input == null || !mounted) return;
    try {
      if (existing == null) {
        final created = await widget.backend.trips.create(input);
        await _rememberTrip(created.id);
      } else {
        await widget.backend.trips.update(existing.id, input);
      }
      await _refresh();
    } catch (_) {
      if (mounted) _liveNotice(context, '여행을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.');
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LiveTripData?>(
    future: _tripFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: _LiveMessage(
            title: '여행을 불러오지 못했어요',
            detail: '연결을 확인하고 다시 시도해 주세요.',
            button: '다시 시도',
            onPressed: _refresh,
          ),
        );
      }
      final data = snapshot.data;
      if (data == null) {
        return Scaffold(
          body: _LiveMessage(
            title: '첫 여행을 만들어 볼까요?',
            detail: '여행을 만들면 오늘과 일정 화면에 실제 데이터가 표시됩니다.',
            button: '새 여행 만들기',
            onPressed: _editTrip,
          ),
          floatingActionButton: widget.onSignOut == null
              ? null
              : FloatingActionButton.small(
                  onPressed: widget.onSignOut,
                  tooltip: '로그아웃',
                  child: const Icon(Icons.logout_rounded),
                ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: IndexedStack(
          index: _tab,
          children: [
            NextMoveHome(
              liveData: data,
              preferences: _preferences,
              onAdvancePlace: _advancePlace,
              onComparePlace: _compareCurrentPlace,
              advancingPlace: _advancingPlace,
              onViewTrip: () => setState(() => _tab = 1),
              onOpenProfile: () => setState(() => _tab = 3),
              onRefresh: _refresh,
            ),
            TripOverviewScreen(
              showBack: false,
              liveData: data,
              backend: widget.backend,
              onRefresh: _refresh,
              onNewTrip: _editTrip,
              onEditTrip: () => _editTrip(data.trip),
              onSelectTrip: _selectTrip,
            ),
            _LiveExplore(
              backend: widget.backend,
              data: data,
              onRefresh: _refresh,
              onDone: () => setState(() => _tab = 1),
            ),
            !_preferencesReady
                ? const Center(child: CircularProgressIndicator())
                : _preferencesFailed
                ? _LiveMessage(
                    title: '설정을 불러오지 못했어요',
                    detail: '연결을 확인하고 다시 시도해 주세요.',
                    button: '다시 시도',
                    onPressed: _loadPreferences,
                  )
                : ProfileSettingsScreen(
                    initialPreferences: _preferences,
                    onSaveAsync: _savePreferences,
                    liveMode: true,
                    accountEmail: widget.accountEmail,
                    onSignOut: widget.onSignOut,
                  ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          height: 68,
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.paleGreen,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: _travelCopy(
                _preferences.userLanguage,
                english: 'Today',
                korean: '오늘',
                japanese: '今日',
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: _travelCopy(
                _preferences.userLanguage,
                english: 'Trip',
                korean: '일정',
                japanese: '旅程',
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: _travelCopy(
                _preferences.userLanguage,
                english: 'Explore',
                korean: '장소',
                japanese: '探索',
              ),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: _travelCopy(
                _preferences.userLanguage,
                english: 'Profile',
                korean: '프로필',
                japanese: '設定',
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _LiveMessage extends StatelessWidget {
  const _LiveMessage({
    required this.title,
    required this.detail,
    this.button,
    this.onPressed,
  });
  final String title;
  final String detail;
  final String? button;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => _PhonePage(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.luggage_outlined, size: 52, color: AppColors.green),
          const SizedBox(height: 18),
          Text(title, style: _sectionTitle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(detail, textAlign: TextAlign.center),
          if (button != null) ...[
            const SizedBox(height: 22),
            FilledButton(onPressed: onPressed, child: Text(button!)),
          ],
        ],
      ),
    ),
  );
}

class _LiveExplore extends StatefulWidget {
  const _LiveExplore({
    required this.backend,
    required this.data,
    required this.onRefresh,
    required this.onDone,
  });

  final NextMateBackend backend;
  final LiveTripData data;
  final Future<void> Function() onRefresh;
  final VoidCallback onDone;

  @override
  State<_LiveExplore> createState() => _LiveExploreState();
}

class _LiveExploreState extends State<_LiveExplore> {
  String _language = 'en';
  late String _day = widget.data.currentDay;
  List<TourPlace> _results = const [];
  TourPlace? _selectedPlace;
  String? _addingContentId;
  bool _searchFocused = false;

  @override
  void didUpdateWidget(covariant _LiveExplore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.trip.id != widget.data.trip.id) {
      _day = widget.data.currentDay;
      _results = const [];
      _selectedPlace = null;
    } else if (!widget.data.days.contains(_day)) {
      _day = widget.data.currentDay;
    }
  }

  Future<void> _add(TourPlace place) async {
    if (_addingContentId != null) return;
    setState(() => _addingContentId = place.contentId);
    try {
      await widget.backend.itinerary.addTourPlace(
        widget.data.trip.id,
        _day,
        contentId: place.contentId,
        language: place.language,
        name: place.name,
        address: place.address,
        latitude: place.latitude,
        longitude: place.longitude,
      );
      await widget.onRefresh();
      if (mounted) _liveNotice(context, '${place.name}을(를) 일정에 추가했어요.');
    } catch (_) {
      if (mounted) _liveNotice(context, '일정에 추가하지 못했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _addingContentId = null);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final sheetHeight = (constraints.maxHeight * 0.62).clamp(280.0, 520.0);
      return Stack(
        children: [
          Positioned.fill(
            child: TourResultMap(
              places: _results,
              showFallbackHint: !_searchFocused,
              onSelected: (place) => setState(() => _selectedPlace = place),
            ),
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.white,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TourismAutocomplete(
                        tourism: widget.backend.tourism,
                        language: _language,
                        labelText:
                            'Search places in ${widget.data.trip.destinationName}',
                        floating: true,
                        onFocusChanged: (focused) =>
                            setState(() => _searchFocused = focused),
                        onResults: (results) => setState(() {
                          _results = results;
                          _selectedPlace = null;
                        }),
                        onSelected: (place) =>
                            setState(() => _selectedPlace = place),
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 7,
                    children: [
                      _ExploreCategoryChip(
                        label: 'English',
                        selected: _language == 'en',
                        onTap: () => setState(() => _language = 'en'),
                      ),
                      _ExploreCategoryChip(
                        label: '日本語',
                        selected: _language == 'ja',
                        onTap: () => setState(() => _language = 'ja'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!_searchFocused)
            Align(
              alignment: Alignment.bottomCenter,
              child: _resultsPanel(sheetHeight),
            ),
        ],
      );
    },
  );

  Widget _resultsPanel(double height) {
    final dayIndex = widget.data.days.indexOf(_day) + 1;
    final savedCount = _results.where((place) => _isAdded(place)).length;
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
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
            const SizedBox(height: 13),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Explore ${widget.data.trip.destinationName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: AppColors.green,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Add to day $dayIndex',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(width: 5),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _day,
                    isDense: true,
                    iconSize: 17,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.green,
                    ),
                    items: [
                      for (
                        var index = 0;
                        index < widget.data.days.length;
                        index++
                      )
                        DropdownMenuItem(
                          value: widget.data.days[index],
                          child: Text(
                            '${index + 1}일차 · ${widget.data.days[index].substring(5)}',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _day = value);
                    },
                  ),
                ),
              ],
            ),
            if (_selectedPlace case final place?)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _isAdded(place) ? null : () => _add(place),
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: const Text('일정에 추가'),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Text(
                        'Search a place to see official tourism results',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final place = _results[index];
                        return _ExplorePlaceCard(
                          place: _ExplorePlace(
                            id: index,
                            title: place.name,
                            local: place.address,
                            hours: '운영시간 정보 없음',
                            travel: '경로 연결 전',
                            note: '관광정보 검색 결과',
                            address: place.address,
                            entrance: '',
                            localEntrance: '',
                            reservation: '',
                            state: _ExplorePlaceState.open,
                            icon: Icons.place_rounded,
                          ),
                          added:
                              _isAdded(place) ||
                              _addingContentId == place.contentId,
                          onTap: () => setState(() => _selectedPlace = place),
                          onAdd: () => _add(place),
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
                    '$savedCount saved for day $dayIndex',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(onPressed: widget.onDone, child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isAdded(TourPlace place) => widget.data
      .itemsFor(_day)
      .any(
        (item) =>
            widget.data.places[item['place_id']]?['tour_api_content_id'] ==
            place.contentId,
      );
}

class _LiveDayPlan extends StatelessWidget {
  const _LiveDayPlan({
    required this.data,
    required this.day,
    required this.backend,
  });
  final LiveTripData data;
  final String day;
  final NextMateBackend backend;

  Future<void> _add(BuildContext context) async {
    final name = TextEditingController();
    final notes = TextEditingController();
    final draft = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('방문 장소 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: '장소명'),
            ),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: '메모 (선택)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, (name.text, notes.text));
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
    name.dispose();
    notes.dispose();
    if (draft == null || !context.mounted) return;
    try {
      await backend.itinerary.addDraftPlace(
        data.trip.id,
        day,
        draft.$1,
        notes: draft.$2,
      );
      if (context.mounted) Navigator.pop(context);
    } catch (_) {
      if (context.mounted) _liveNotice(context, '장소를 추가하지 못했어요.');
    }
  }

  Future<void> _status(BuildContext context, Json item, String status) async {
    try {
      await backend.itinerary.update(data.trip.id, item['id'] as String, {
        'progress_status': status,
      });
      if (context.mounted) Navigator.pop(context);
    } catch (_) {
      if (context.mounted) _liveNotice(context, '방문 상태를 저장하지 못했어요.');
    }
  }

  @override
  Widget build(BuildContext context) => _PhonePage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _MapCircleButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    data.trip.title,
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
        const SizedBox(height: 18),
        const Text(
          '오늘의 방문 장소',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          '시간표 없이 내 속도에 맞춰 이동하세요.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 17,
                color: AppColors.green,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '운영시간·추천 순서는 아직 연결 전이에요.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              if (data.itemsFor(day).isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('방문 장소를 추가해 주세요.'),
                ),
              for (final item in data.itemsFor(day))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DayPlaceCard(
                    index: item['position'] as int,
                    draggable: false,
                    place: _DayPlace(
                      id: item['position'] as int,
                      title: data.placeName(item),
                      local: item['notes'] as String? ?? '방문 예정',
                      hours: data.places[item['place_id']]?['latitude'] == null
                          ? '위치 미등록'
                          : '위치 등록됨',
                      note: switch (item['progress_status']) {
                        'completed' => '방문 완료',
                        'skipped' => '건너뜀',
                        _ => '방문 예정',
                      },
                      availability: _PlaceAvailability.open,
                      icon: Icons.place_rounded,
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: '방문 상태 변경',
                      onSelected: (value) => _status(context, item, value),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'planned', child: Text('방문 예정')),
                        PopupMenuItem(value: 'completed', child: Text('방문 완료')),
                        PopupMenuItem(value: 'skipped', child: Text('건너뛰기')),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        _PrimaryAction(
          label: '방문 장소 추가',
          icon: Icons.add_rounded,
          background: AppColors.deepGreen,
          foreground: Colors.white,
          onTap: () => _add(context),
        ),
      ],
    ),
  );
}

class _LiveTripDialog extends StatefulWidget {
  const _LiveTripDialog({this.existing});
  final Trip? existing;
  @override
  State<_LiveTripDialog> createState() => _LiveTripDialogState();
}

class _LiveTripDialogState extends State<_LiveTripDialog> {
  late final TextEditingController _title;
  late final TextEditingController _destination;
  late DateTimeRange _dates;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _destination = TextEditingController(
      text: widget.existing?.destinationName ?? '서울',
    );
    final now = DateTime.now();
    _dates = DateTimeRange(
      start: widget.existing == null
          ? now
          : DateTime.parse(widget.existing!.startDate),
      end: widget.existing == null
          ? now.add(const Duration(days: 1))
          : DateTime.parse(widget.existing!.endDate),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _destination.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? '새 여행' : '여행 수정'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: '여행 이름'),
        ),
        TextField(
          controller: _destination,
          decoration: const InputDecoration(labelText: '국내 여행지'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDateRange: _dates,
            );
            if (picked != null && mounted) setState(() => _dates = picked);
          },
          icon: const Icon(Icons.date_range_rounded),
          label: Text('${_liveDate(_dates.start)} ~ ${_liveDate(_dates.end)}'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: () {
          if (_title.text.trim().isEmpty || _destination.text.trim().isEmpty) {
            return;
          }
          Navigator.pop(
            context,
            TripInput(
              title: _title.text.trim(),
              destinationName: _destination.text.trim(),
              startDate: _liveDate(_dates.start),
              endDate: _liveDate(_dates.end),
              timeZoneId: 'Asia/Seoul',
            ),
          );
        },
        child: const Text('저장'),
      ),
    ],
  );
}

String _liveDate(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

void _liveNotice(BuildContext context, String message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message)));

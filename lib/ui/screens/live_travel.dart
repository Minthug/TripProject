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
  TravelPreferences _preferences = const TravelPreferences();
  bool _preferencesReady = false;
  bool _preferencesFailed = false;

  @override
  void initState() {
    super.initState();
    _tripFuture = LiveTripData.load(widget.backend);
    _loadPreferences();
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
    setState(() => _tripFuture = next);
    await next;
  }

  Future<void> _selectTrip(String id) async {
    _selectedTripId = id;
    await _refresh();
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
        _selectedTripId = created.id;
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
            _LiveToday(
              data: data,
              onViewTrip: () => setState(() => _tab = 1),
              onOpenProfile: () => setState(() => _tab = 3),
              onRefresh: _refresh,
            ),
            _LiveTripOverview(
              data: data,
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
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: '오늘'),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              label: '일정',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              label: '장소',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              label: '프로필',
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

class _LiveToday extends StatelessWidget {
  const _LiveToday({
    required this.data,
    required this.onViewTrip,
    required this.onOpenProfile,
    required this.onRefresh,
  });
  final LiveTripData data;
  final VoidCallback onViewTrip;
  final VoidCallback onOpenProfile;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final day = data.currentDay;
    final today = _liveDate(DateTime.now());
    final beforeTrip = today.compareTo(data.trip.startDate) < 0;
    final afterTrip = today.compareTo(data.trip.endDate) > 0;
    final dayLabel = beforeTrip
        ? '여행 시작 전'
        : afterTrip
        ? '지난 여행'
        : '${data.days.indexOf(day) + 1}일차';
    final sectionLabel = beforeTrip
        ? '첫날 일정'
        : afterTrip
        ? '마지막 날 일정'
        : '오늘 일정';
    final items = data.itemsFor(day);
    final upcoming = afterTrip
        ? items.lastOrNull
        : items
              .where(
                (item) =>
                    item['progress_status'] != 'completed' &&
                    item['progress_status'] != 'skipped',
              )
              .firstOrNull;
    return _PhonePage(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            _AppHeader(
              title: '${data.trip.destinationName} · $dayLabel',
              subtitle: '${data.trip.title} · $day',
              onProfileTap: onOpenProfile,
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    afterTrip
                        ? '마지막 일정'
                        : beforeTrip
                        ? '첫날 방문 장소'
                        : '다음 장소',
                    style: const TextStyle(
                      color: Color(0xFFAED8C4),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    upcoming == null ? '예정된 장소가 없어요' : data.placeName(upcoming),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (upcoming?['notes'] case final String notes) ...[
                    const SizedBox(height: 5),
                    Text(
                      notes,
                      style: const TextStyle(color: Color(0xFFC7D8D0)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    '실시간 위치·이동 경로는 아직 연결되지 않았어요.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAction(
                    label: '전체 일정 보기',
                    icon: Icons.calendar_month_rounded,
                    background: const Color(0xFFF7F0D5),
                    foreground: AppColors.ink,
                    onTap: onViewTrip,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Text(sectionLabel, style: _sectionTitle)),
                TextButton(onPressed: onViewTrip, child: const Text('전체 일정')),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty) const Text('이 날짜에 등록된 방문 장소가 없어요.'),
            for (final item in items)
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${(item['position'] as int) + 1}'),
                  ),
                  title: Text(data.placeName(item)),
                  subtitle: Text(item['notes'] as String? ?? '방문 예정'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LiveTripOverview extends StatelessWidget {
  const _LiveTripOverview({
    required this.data,
    required this.backend,
    required this.onRefresh,
    required this.onNewTrip,
    required this.onEditTrip,
    required this.onSelectTrip,
  });
  final LiveTripData data;
  final NextMateBackend backend;
  final Future<void> Function() onRefresh;
  final VoidCallback onNewTrip;
  final VoidCallback onEditTrip;
  final ValueChanged<String> onSelectTrip;

  @override
  Widget build(BuildContext context) {
    final days = <_OverviewDay>[
      for (var index = 0; index < data.days.length; index++)
        _OverviewDay(
          day: const [
            'MON',
            'TUE',
            'WED',
            'THU',
            'FRI',
            'SAT',
            'SUN',
          ][DateTime.parse(data.days[index]).weekday - 1],
          date: data.days[index].substring(8),
          title: '${index + 1}일차 · ${data.itemsFor(data.days[index]).length}곳',
          stay: '',
          items: [
            for (final item in data.itemsFor(data.days[index]))
              data.placeName(item),
          ],
          openTime: '',
        ),
    ];
    final count = data.itemsByDay.values.fold<int>(
      0,
      (sum, items) => sum + items.length,
    );
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _AppHeader(
                  title: data.trip.title,
                  subtitle: '${data.trip.startDate} ~ ${data.trip.endDate}',
                  showProfile: false,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: '여행 관리',
                onSelected: (action) =>
                    action == 'new' ? onNewTrip() : onEditTrip(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('여행 수정')),
                  PopupMenuItem(value: 'new', child: Text('새 여행')),
                ],
              ),
            ],
          ),
          if (data.trips.length > 1) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(data.trip.id),
              initialValue: data.trip.id,
              decoration: const InputDecoration(labelText: '여행 선택'),
              items: [
                for (final trip in data.trips)
                  DropdownMenuItem(value: trip.id, child: Text(trip.title)),
              ],
              onChanged: (id) {
                if (id != null) onSelectTrip(id);
              },
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            '전체 일정',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            '저장된 방문 장소를 날짜별로 확인하고 편집하세요.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _OverviewStat(value: '${days.length}', label: 'DAYS'),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _OverviewStat(value: '$count', label: 'PLACES'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                itemCount: days.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, index) => _OverviewDayCard(
                  day: days[index],
                  onOpen: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          body: _LiveDayPlan(
                            data: data,
                            day: data.days[index],
                            backend: backend,
                          ),
                        ),
                      ),
                    );
                    await onRefresh();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveExplore extends StatefulWidget {
  const _LiveExplore({
    required this.backend,
    required this.data,
    required this.onRefresh,
  });

  final NextMateBackend backend;
  final LiveTripData data;
  final Future<void> Function() onRefresh;

  @override
  State<_LiveExplore> createState() => _LiveExploreState();
}

class _LiveExploreState extends State<_LiveExplore> {
  final _keyword = TextEditingController();
  String _language = 'en';
  late String _day = widget.data.currentDay;
  List<TourPlace> _results = const [];
  String? _message;
  bool _searching = false;
  String? _addingContentId;

  @override
  void didUpdateWidget(covariant _LiveExplore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.trip.id != widget.data.trip.id) {
      _day = widget.data.currentDay;
      _results = const [];
      _message = null;
    } else if (!widget.data.days.contains(_day)) {
      _day = widget.data.currentDay;
    }
  }

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_searching) return;
    if (_keyword.text.trim().length < 2) {
      setState(() => _message = '검색어를 두 글자 이상 입력해 주세요.');
      return;
    }
    setState(() {
      _searching = true;
      _message = null;
      _results = const [];
    });
    try {
      final results = await widget.backend.tourism.search(
        _keyword.text,
        language: _language,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        if (results.isEmpty) _message = '검색 결과가 없어요.';
      });
    } catch (_) {
      if (mounted) {
        setState(() => _message = '관광정보를 불러오지 못했어요. 검색 서비스 연결을 확인해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _searching = false);
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
  Widget build(BuildContext context) => _PhonePage(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AppHeader(
          title: '장소 탐색',
          subtitle: '한국관광공사 관광정보에서 장소 찾기',
          showProfile: false,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _keyword,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            labelText: '관광지 이름 검색',
            hintText: '예: Gyeongbokgung',
            suffixIcon: IconButton(
              tooltip: '검색',
              onPressed: _searching ? null : _search,
              icon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(labelText: '검색 언어'),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _language = value);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                key: ValueKey('${widget.data.trip.id}:$_day'),
                initialValue: _day,
                decoration: const InputDecoration(labelText: '추가할 날짜'),
                items: [
                  for (var index = 0; index < widget.data.days.length; index++)
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
        const SizedBox(height: 12),
        if (_searching) const LinearProgressIndicator(),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(_message!),
          ),
        Expanded(
          child: ListView.separated(
            itemCount: _results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final place = _results[index];
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  trailing: IconButton(
                    tooltip: '일정에 추가',
                    onPressed: _addingContentId == null
                        ? () => _add(place)
                        : null,
                    icon: _addingContentId == place.contentId
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline_rounded),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
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
        _AppHeader(
          title: '$day 일정',
          subtitle: data.trip.title,
          showProfile: false,
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('전체 일정'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final item in data.itemsFor(day))
                Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${(item['position'] as int) + 1}'),
                    ),
                    title: Text(data.placeName(item)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['notes'] as String? ?? '방문 예정'),
                        if (data.places[item['place_id']]?['latitude'] == null)
                          const Text(
                            '위치 미등록 · 경로 안내 불가',
                            style: TextStyle(fontSize: 11),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
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
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _add(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('장소 직접 추가'),
          ),
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

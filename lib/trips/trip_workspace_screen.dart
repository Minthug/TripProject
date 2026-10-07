import 'package:flutter/material.dart';

import '../backend/backend.dart';
import '../backend/repositories.dart';
import '../backend/tourism_repository.dart';

part 'trip_workspace_forms.dart';

/// The signed-in trip experience. The public design gallery remains separate.
class TripWorkspaceScreen extends StatefulWidget {
  const TripWorkspaceScreen({
    super.key,
    required this.backend,
    this.accountEmail,
    this.onSignOut,
  });

  final NextMateBackend backend;
  final String? accountEmail;
  final Future<void> Function()? onSignOut;

  @override
  State<TripWorkspaceScreen> createState() => _TripWorkspaceScreenState();
}

class _TripWorkspaceScreenState extends State<TripWorkspaceScreen> {
  List<Trip> _trips = [];
  Trip? _trip;
  String? _day;
  List<Json> _items = [];
  Map<String, Json> _places = {};
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<List<Json>> _allPlaces(String tripId) async {
    final result = <Json>[];
    while (true) {
      final page = await widget.backend.places.list(
        tripId,
        offset: result.length,
        limit: 100,
      );
      result.addAll(page);
      if (page.length < 100) return result;
    }
  }

  Future<void> _reload({String? selectTripId, String? selectDay}) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final trips = await widget.backend.trips.list(limit: 100);
      final wanted = selectTripId ?? _trip?.id;
      Trip? selected;
      for (final candidate in trips) {
        if (candidate.id == wanted) selected = candidate;
      }
      if (selected == null && trips.isNotEmpty) {
        final today = _date(DateTime.now());
        selected =
            trips
                .where((trip) => trip.endDate.compareTo(today) >= 0)
                .firstOrNull ??
            trips.last;
      }

      final day = selected == null
          ? null
          : (selectDay != null &&
                selectDay.compareTo(selected.startDate) >= 0 &&
                selectDay.compareTo(selected.endDate) <= 0)
          ? selectDay
          : (_trip?.id == selected.id &&
                _day != null &&
                _day!.compareTo(selected.startDate) >= 0 &&
                _day!.compareTo(selected.endDate) <= 0)
          ? _day
          : selected.startDate;

      final items = selected == null
          ? <Json>[]
          : await widget.backend.itinerary.day(selected.id, day!);
      final places = selected == null
          ? <Json>[]
          : await _allPlaces(selected.id);
      if (!mounted) return;
      setState(() {
        _trips = trips;
        _trip = selected;
        _day = day;
        _items = items;
        _places = {for (final place in places) place['id'] as String: place};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '여행 일정을 불러오지 못했어요. 연결을 확인하고 다시 시도해 주세요.';
        _loading = false;
      });
    }
  }

  Future<void> _perform(
    Future<void> Function() action, {
    String? selectTripId,
    String? selectDay,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _reload(selectTripId: selectTripId, selectDay: selectDay);
    } on RepositoryException catch (error) {
      _notice(_failureText(error.kind));
    } catch (_) {
      _notice('저장하지 못했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editTrip([Trip? existing]) async {
    final input = await showDialog<TripInput>(
      context: context,
      builder: (context) => _TripEditorDialog(existing: existing),
    );
    if (input == null) return;
    if (existing == null) {
      String? createdId;
      await _perform(() async {
        final created = await widget.backend.trips.create(input);
        createdId = created.id;
      });
      if (createdId != null) await _reload(selectTripId: createdId);
    } else {
      await _perform(
        () async => widget.backend.trips.update(existing.id, input),
        selectTripId: existing.id,
      );
    }
  }

  Future<void> _deleteTrip(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행을 삭제할까요?'),
        content: Text('「${trip.title}」의 일정과 저장된 장소도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _perform(() async => widget.backend.trips.delete(trip.id));
  }

  Future<void> _addPlace() async {
    final trip = _trip;
    final day = _day;
    if (trip == null || day == null) return;
    final draft = await showDialog<_DraftPlaceInput>(
      context: context,
      builder: (context) => const _DraftPlaceDialog(),
    );
    if (draft == null) return;
    await _perform(
      () async => widget.backend.itinerary.addDraftPlace(
        trip.id,
        day,
        draft.name,
        notes: draft.notes,
      ),
      selectTripId: trip.id,
      selectDay: day,
    );
  }

  Future<void> _addTourPlace() async {
    final trip = _trip;
    final day = _day;
    if (trip == null || day == null) return;
    final place = await showDialog<TourPlace>(
      context: context,
      builder: (context) =>
          _TourPlaceSearchDialog(tourism: widget.backend.tourism),
    );
    if (place == null) return;
    await _perform(
      () async => widget.backend.itinerary.addTourPlace(
        trip.id,
        day,
        contentId: place.contentId,
        language: place.language,
        name: place.name,
        address: place.address,
        latitude: place.latitude,
        longitude: place.longitude,
      ),
      selectTripId: trip.id,
      selectDay: day,
    );
  }

  Future<void> _changeItem(Json item, String action) async {
    final trip = _trip!;
    final day = _day!;
    final id = item['id'] as String;
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('일정에서 삭제할까요?'),
          content: const Text('이 날짜의 방문 일정이 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await _perform(
        () async => widget.backend.itinerary.delete(trip.id, id),
        selectTripId: trip.id,
        selectDay: day,
      );
    } else if (action == 'notes') {
      final notes = await showDialog<String>(
        context: context,
        builder: (context) =>
            _NotesDialog(initial: item['notes'] as String? ?? ''),
      );
      if (notes == null) return;
      await _perform(
        () async =>
            widget.backend.itinerary.update(trip.id, id, {'notes': notes}),
        selectTripId: trip.id,
        selectDay: day,
      );
    } else if (action == 'move') {
      final target = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(day),
        firstDate: DateTime.parse(trip.startDate),
        lastDate: DateTime.parse(trip.endDate),
        helpText: '이동할 날짜 선택',
      );
      if (target == null || _date(target) == day) return;
      final targetDay = _date(target);
      await _perform(
        () async {
          final targetItems = await widget.backend.itinerary.day(
            trip.id,
            targetDay,
          );
          final nextPosition = targetItems.fold<int>(
            0,
            (max, row) => (row['position'] as int) >= max
                ? (row['position'] as int) + 1
                : max,
          );
          await widget.backend.itinerary.move(
            trip.id,
            id,
            targetDay,
            nextPosition,
          );
        },
        selectTripId: trip.id,
        selectDay: targetDay,
      );
    } else {
      await _perform(
        () async => widget.backend.itinerary.update(trip.id, id, {
          'progress_status': action,
        }),
        selectTripId: trip.id,
        selectDay: day,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    return Scaffold(
      appBar: AppBar(
        title: const Text('NextMate · 내 여행'),
        actions: [
          if (widget.onSignOut != null)
            IconButton(
              tooltip: '로그아웃',
              onPressed: _busy ? null : widget.onSignOut,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          children: [
            if (widget.accountEmail != null)
              Text(
                widget.accountEmail!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 14),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              TextButton(onPressed: _reload, child: const Text('다시 시도')),
            ] else if (!_loading && trip == null) ...[
              const SizedBox(height: 80),
              const Icon(Icons.luggage_outlined, size: 56),
              const SizedBox(height: 12),
              const Center(child: Text('아직 저장한 여행이 없어요.')),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _busy ? null : () => _editTrip(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('첫 여행 만들기'),
              ),
            ] else if (!_loading && trip != null) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      key: ValueKey(trip.id),
                      initialValue: trip.id,
                      decoration: const InputDecoration(
                        labelText: '여행',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final entry in _trips)
                          DropdownMenuItem(
                            value: entry.id,
                            child: Text(entry.title),
                          ),
                      ],
                      onChanged: _busy
                          ? null
                          : (id) => _reload(selectTripId: id),
                    ),
                  ),
                  IconButton(
                    tooltip: '새 여행',
                    onPressed: _busy ? null : () => _editTrip(),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  PopupMenuButton<String>(
                    tooltip: '여행 관리',
                    enabled: !_busy,
                    onSelected: (value) {
                      if (value == 'edit') _editTrip(trip);
                      if (value == 'delete') _deleteTrip(trip);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('여행 수정')),
                      if (trip.ownerId ==
                          widget.backend.client.auth.currentUser?.id)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('여행 삭제'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                trip.destinationName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text('${trip.startDate} ~ ${trip.endDate}'),
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final day in _days(trip)) ...[
                      ChoiceChip(
                        label: Text(day.substring(5)),
                        selected: day == _day,
                        onSelected: _busy
                            ? null
                            : (_) => _reload(
                                selectTripId: trip.id,
                                selectDay: day,
                              ),
                      ),
                      const SizedBox(width: 7),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_day 일정',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _addPlace,
                    child: const Text('직접 입력'),
                  ),
                  FilledButton.icon(
                    onPressed: _busy ? null : _addTourPlace,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('관광지 검색'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('이 날짜의 방문 장소가 없어요. 관광지를 검색하거나 직접 입력해 주세요.'),
                  ),
                ),
              for (final item in _items) _itemCard(item),
              const SizedBox(height: 10),
              const Text(
                '공식 관광정보의 위치는 저장됩니다. 영업시간·경로는 아직 연결되지 않았으며, 직접 입력한 위치 미등록 장소는 경로에 사용하지 않습니다.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemCard(Json item) {
    final place = _places[item['place_id'] as String];
    final status = item['progress_status'] as String? ?? 'planned';
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${(item['position'] as int) + 1}')),
        title: Text(place?['display_name'] as String? ?? '삭제된 장소'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(switch (status) {
              'completed' => '방문 완료',
              'skipped' => '건너뜀',
              _ => '방문 예정',
            }),
            if ((item['notes'] as String?)?.isNotEmpty == true)
              Text(item['notes'] as String),
            if (place?['location_source'] == 'tour_api')
              Text(place?['formatted_address'] as String? ?? ''),
            if (place?['latitude'] == null) const Text('위치 미등록 · 경로 안내 불가'),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          enabled: !_busy,
          onSelected: (action) => _changeItem(item, action),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'completed', child: Text('방문 완료')),
            PopupMenuItem(value: 'planned', child: Text('방문 예정으로 변경')),
            PopupMenuItem(value: 'skipped', child: Text('건너뛰기')),
            PopupMenuItem(value: 'notes', child: Text('메모 수정')),
            PopupMenuItem(value: 'move', child: Text('날짜 이동')),
            PopupMenuItem(value: 'delete', child: Text('일정에서 삭제')),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

Iterable<String> _days(Trip trip) sync* {
  var day = DateTime.parse(trip.startDate);
  final end = DateTime.parse(trip.endDate);
  while (!day.isAfter(end)) {
    yield _date(day);
    day = DateTime(day.year, day.month, day.day + 1);
  }
}

String _failureText(FailureKind kind) => switch (kind) {
  FailureKind.forbidden || FailureKind.unauthenticated => '이 여행을 변경할 권한이 없어요.',
  FailureKind.conflict => '동시에 변경된 일정이 있어요. 새로고침 후 다시 시도해 주세요.',
  FailureKind.invalid => '입력값이나 여행 날짜를 확인해 주세요.',
  FailureKind.unavailable => '서버에 저장하지 못했어요. 잠시 후 다시 시도해 주세요.',
};

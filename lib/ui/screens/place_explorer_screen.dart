part of '../../main.dart';

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
        final removedDay = scheduledDay;
        onRemove();
        Navigator.pop(sheetContext);
        if (removedDay != null) {
          Future<void>.delayed(Duration.zero, () {
            if (!context.mounted) return;
            _showUndoMessage(
              context,
              message: '${place.title} removed from your itinerary.',
              onUndo: () => onSave(removedDay),
            );
          });
        }
      },
    ),
  );
}

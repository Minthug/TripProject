part of '../../main.dart';

class AttractionDetailScreen extends StatefulWidget {
  const AttractionDetailScreen({super.key});

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  String? scheduledDay = 'Tuesday, Sep 15';

  void _removePlace() {
    final removedDay = scheduledDay;
    setState(() => scheduledDay = null);
    if (removedDay == null) return;
    _showUndoMessage(
      context,
      message: 'Myeongdong Cathedral removed from your itinerary.',
      onUndo: () => setState(() => scheduledDay = removedDay),
    );
  }

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
          onRemove: _removePlace,
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

  Future<void> _save() async {
    if (!editing || selectedDay == widget.scheduledDay) {
      widget.onSave(selectedDay);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Move ${widget.place.title}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review the date change before updating your itinerary.',
            ),
            const SizedBox(height: 14),
            _DateChangeRow(
              label: 'CURRENT',
              value: widget.scheduledDay!,
              muted: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 7),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 18,
                color: AppColors.muted,
              ),
            ),
            _DateChangeRow(label: 'NEW DATE', value: selectedDay),
            const SizedBox(height: 13),
            const Text(
              'Other places keep their current order.',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep current date'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm date change'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) widget.onSave(selectedDay);
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
                  onTap: closed ? () {} : _save,
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

class _DateChangeRow extends StatelessWidget {
  const _DateChangeRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF3F5F2) : AppColors.paleGreen,
        borderRadius: BorderRadius.circular(12),
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
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
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

part of 'trip_workspace_screen.dart';

class _TripEditorDialog extends StatefulWidget {
  const _TripEditorDialog({this.existing});
  final Trip? existing;

  @override
  State<_TripEditorDialog> createState() => _TripEditorDialogState();
}

class _TripEditorDialogState extends State<_TripEditorDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _destination;
  late DateTimeRange _range;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _destination = TextEditingController(
      text: widget.existing?.destinationName ?? '서울',
    );
    final today = DateTime.now();
    _range = DateTimeRange(
      start: widget.existing == null
          ? today
          : DateTime.parse(widget.existing!.startDate),
      end: widget.existing == null
          ? today.add(const Duration(days: 1))
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
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: '여행 이름'),
            validator: (value) =>
                value?.trim().isNotEmpty == true ? null : '여행 이름을 입력해 주세요.',
          ),
          TextFormField(
            controller: _destination,
            decoration: const InputDecoration(labelText: '국내 여행지'),
            validator: (value) =>
                value?.trim().isNotEmpty == true ? null : '여행지를 입력해 주세요.',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: _range,
                helpText: '여행 날짜 선택',
              );
              if (picked != null && mounted) setState(() => _range = picked);
            },
            icon: const Icon(Icons.date_range_rounded),
            label: Text('${_date(_range.start)} ~ ${_date(_range.end)}'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(
            context,
            TripInput(
              title: _title.text,
              destinationName: _destination.text,
              startDate: _date(_range.start),
              endDate: _date(_range.end),
              timeZoneId: 'Asia/Seoul',
            ),
          );
        },
        child: const Text('저장'),
      ),
    ],
  );
}

class _DraftPlaceInput {
  const _DraftPlaceInput(this.name, this.notes);
  final String name;
  final String notes;
}

class _DraftPlaceDialog extends StatefulWidget {
  const _DraftPlaceDialog();
  @override
  State<_DraftPlaceDialog> createState() => _DraftPlaceDialogState();
}

class _DraftPlaceDialogState extends State<_DraftPlaceDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('방문 장소 추가'),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _name,
            maxLength: 120,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '장소명',
              hintText: '예: 경복궁',
            ),
            validator: (value) =>
                value?.trim().isNotEmpty == true ? null : '장소명을 입력해 주세요.',
          ),
          TextFormField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: '메모 (선택)'),
          ),
          const SizedBox(height: 8),
          const Text('위치 정보는 장소 API 연결 후 확인할 수 있어요.'),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(
              context,
              _DraftPlaceInput(_name.text.trim(), _notes.text.trim()),
            );
          }
        },
        child: const Text('일정에 추가'),
      ),
    ],
  );
}

class _NotesDialog extends StatefulWidget {
  const _NotesDialog({required this.initial});
  final String initial;
  @override
  State<_NotesDialog> createState() => _NotesDialogState();
}

class _NotesDialogState extends State<_NotesDialog> {
  late final TextEditingController _notes;
  @override
  void initState() {
    super.initState();
    _notes = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('일정 메모'),
    content: TextField(controller: _notes, maxLines: 4, autofocus: true),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _notes.text.trim()),
        child: const Text('저장'),
      ),
    ],
  );
}

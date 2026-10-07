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
          const Text('직접 입력한 장소는 위치 정보가 없어 경로 안내에 사용할 수 없어요.'),
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

class _TourPlaceSearchDialog extends StatefulWidget {
  const _TourPlaceSearchDialog({required this.tourism});
  final TourismRepository tourism;

  @override
  State<_TourPlaceSearchDialog> createState() => _TourPlaceSearchDialogState();
}

class _TourPlaceSearchDialogState extends State<_TourPlaceSearchDialog> {
  final _keyword = TextEditingController();
  String _language = 'en';
  List<TourPlace> _results = [];
  String? _message;
  bool _searching = false;

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
      _results = [];
    });
    try {
      final found = await widget.tourism.search(
        _keyword.text,
        language: _language,
      );
      if (!mounted) return;
      setState(() {
        _results = found;
        _message = found.isEmpty ? '검색 결과가 없어요. 다른 이름으로 검색해 보세요.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = '관광정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('공식 관광지 검색'),
    content: SizedBox(
      width: 500,
      height: 430,
      child: Column(
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                ],
                onChanged: _searching
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _language = value;
                          _results = [];
                          _message = null;
                        });
                      },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _keyword,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: const InputDecoration(
                    labelText: '관광지 이름',
                    hintText: 'Gyeongbokgung Palace',
                  ),
                ),
              ),
              IconButton(
                tooltip: '검색',
                onPressed: _searching ? null : _search,
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          if (_searching) const LinearProgressIndicator(),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(_message!),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final place = _results[index];
                return ListTile(
                  title: Text(place.name),
                  subtitle: Text(place.address),
                  onTap: () => Navigator.pop(context, place),
                );
              },
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('취소'),
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

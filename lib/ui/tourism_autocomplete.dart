import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/tourism_repository.dart';

/// Searches official tourism data as the traveler types and keeps stale
/// responses from replacing results for a newer query.
class TourismAutocomplete extends StatefulWidget {
  const TourismAutocomplete({
    super.key,
    required this.tourism,
    required this.language,
    required this.onResults,
    required this.onSelected,
    this.onFocusChanged,
    this.labelText = '관광지 이름 검색',
    this.hintText = '예: Gyeongbokgung',
    this.autofocus = false,
    this.floating = false,
  });

  final TourismRepository tourism;
  final String language;
  final ValueChanged<List<TourPlace>> onResults;
  final ValueChanged<TourPlace> onSelected;
  final ValueChanged<bool>? onFocusChanged;
  final String labelText;
  final String hintText;
  final bool autofocus;
  final bool floating;

  @override
  State<TourismAutocomplete> createState() => _TourismAutocompleteState();
}

class _TourismAutocompleteState extends State<TourismAutocomplete> {
  final _keyword = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  int _requestVersion = 0;
  bool _searching = false;
  bool _showSuggestions = false;
  List<TourPlace> _results = const [];
  String? _message;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => widget.onFocusChanged?.call(_focus.hasFocus));
  }

  @override
  void didUpdateWidget(covariant TourismAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language ||
        oldWidget.tourism != widget.tourism) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _queueSearch();
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _requestVersion++;
    _keyword.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _queueSearch() {
    _debounce?.cancel();
    _requestVersion++;
    final query = _keyword.text.trim();
    setState(() {
      _results = const [];
      _message = null;
      _searching = false;
      _showSuggestions = query.length >= 2;
    });
    widget.onResults(const []);
    if (query.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 400), _search);
    }
  }

  Future<void> _search({bool explicit = false}) async {
    _debounce?.cancel();
    final query = _keyword.text.trim();
    if (query.length < 2) {
      if (explicit) setState(() => _message = '검색어를 두 글자 이상 입력해 주세요.');
      return;
    }
    final version = ++_requestVersion;
    final language = widget.language;
    setState(() {
      _searching = true;
      _message = null;
      if (explicit) {
        _showSuggestions = false;
        _focus.unfocus();
      }
    });
    try {
      final results = await widget.tourism.search(query, language: language);
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _results = results;
        _message = results.isEmpty ? '검색 결과가 없어요. 다른 이름으로 검색해 보세요.' : null;
      });
      widget.onResults(results);
    } catch (_) {
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _results = const [];
        _message = '관광정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';
      });
      widget.onResults(const []);
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() => _searching = false);
      }
    }
  }

  void _select(TourPlace place) {
    _debounce?.cancel();
    _requestVersion++;
    _keyword.text = place.name;
    _keyword.selection = TextSelection.collapsed(offset: place.name.length);
    _focus.unfocus();
    setState(() => _showSuggestions = false);
    widget.onSelected(place);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: _keyword,
        focusNode: _focus,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onTapOutside: (_) => _focus.unfocus(),
        onChanged: (_) => _queueSearch(),
        onSubmitted: (_) => _search(explicit: true),
        decoration: InputDecoration(
          labelText: widget.floating ? null : widget.labelText,
          hintText: widget.floating ? widget.labelText : widget.hintText,
          border: widget.floating ? InputBorder.none : null,
          isDense: widget.floating,
          prefixIcon: widget.floating
              ? const Icon(Icons.search_rounded, color: Color(0xFF217556))
              : null,
          suffixIcon: IconButton(
            tooltip: '검색',
            onPressed: () => _search(explicit: true),
            icon: const Icon(Icons.search_rounded),
          ),
        ),
      ),
      if (_searching) const LinearProgressIndicator(),
      if (_message != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(_message!),
        ),
      if (_showSuggestions && _results.isNotEmpty)
        Card(
          margin: const EdgeInsets.only(top: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final place in _results.take(3))
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.place_outlined, size: 19),
                  title: Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _select(place),
                ),
            ],
          ),
        ),
    ],
  );
}

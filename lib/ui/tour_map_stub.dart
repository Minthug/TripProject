import 'package:flutter/material.dart';

import '../backend/tourism_repository.dart';
import 'tour_map_fallback.dart';

Future<void> initializeTourMap() async {}

class TourResultMap extends StatelessWidget {
  const TourResultMap({
    super.key,
    required this.places,
    required this.onSelected,
    this.showFallbackHint = true,
  });

  final List<TourPlace> places;
  final ValueChanged<TourPlace> onSelected;
  final bool showFallbackHint;

  @override
  Widget build(BuildContext context) => TourMapFallback(
    message: '웹 미리보기 · 지도는 Android 앱에서 표시됩니다',
    showMessage: showFallbackHint,
  );
}

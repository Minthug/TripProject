import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../backend/tourism_repository.dart';
import 'tour_map_fallback.dart';

const _clientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
bool _mapInitialized = false;

Future<void> initializeTourMap() async {
  if (!(Platform.isAndroid || Platform.isIOS) || _clientId.isEmpty) return;
  try {
    await FlutterNaverMap().init(clientId: _clientId);
    _mapInitialized = true;
  } catch (_) {
    // A missing or invalid mobile map configuration must not block sign-in.
    _mapInitialized = false;
  }
}

class TourResultMap extends StatefulWidget {
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
  State<TourResultMap> createState() => _TourResultMapState();
}

class _TourResultMapState extends State<TourResultMap> {
  NaverMapController? _controller;
  int _updateId = 0;

  @override
  void didUpdateWidget(covariant TourResultMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.places, widget.places)) {
      _syncMarkers();
    }
  }

  Future<void> _syncMarkers() async {
    final controller = _controller;
    if (controller == null) return;
    final updateId = ++_updateId;
    final places = widget.places;
    try {
      await controller.clearOverlays(type: NOverlayType.marker);
      if (!mounted || updateId != _updateId || places.isEmpty) return;
      final markers = <NMarker>{
        for (final place in places)
          NMarker(
            id: 'tour-${place.contentId}',
            position: NLatLng(place.latitude, place.longitude),
            caption: NOverlayCaption(text: place.name),
          )..setOnTapListener((_) => widget.onSelected(place)),
      };
      await controller.addOverlayAll(markers);
      if (!mounted || updateId != _updateId) return;
      if (places.length == 1) {
        await controller.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(places.first.latitude, places.first.longitude),
            zoom: 15,
          ),
        );
      } else {
        await controller.updateCamera(
          NCameraUpdate.fitBounds(
            NLatLngBounds.from([
              for (final place in places)
                NLatLng(place.latitude, place.longitude),
            ]),
            padding: const EdgeInsets.all(28),
          ),
        );
      }
    } catch (_) {
      // Search results remain usable as a list if the native map fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_mapInitialized || !(Platform.isAndroid || Platform.isIOS)) {
      return TourMapFallback(
        message: '지도 연결 전 · 장소 위치는 목록에서 확인하세요',
        showMessage: widget.showFallbackHint,
      );
    }
    return NaverMap(
      options: const NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: NLatLng(37.5666, 126.9790),
          zoom: 12,
        ),
        locationButtonEnable: false,
      ),
      onMapReady: (controller) {
        _controller = controller;
        _syncMarkers();
      },
    );
  }
}

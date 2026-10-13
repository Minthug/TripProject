import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trip_project/backend/backend.dart';
import 'package:trip_project/backend/tourism_repository.dart';
import 'package:trip_project/main.dart';
import 'package:trip_project/ui/live_trip_data.dart';
import 'package:trip_project/ui/route_links.dart';
import 'package:trip_project/ui/tourism_autocomplete.dart';

void main() {
  late SupabaseClient client;
  late NextMateBackend backend;
  late List<http.Request> writes;
  late List<http.Request> posts;
  late Map<String, String> itemStatuses;
  late bool includeSecondTrip;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    writes = [];
    posts = [];
    itemStatuses = {'item-1': 'planned', 'item-2': 'planned'};
    includeSecondTrip = false;
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        if (request.method == 'PATCH') writes.add(request);
        if (request.method == 'POST') posts.add(request);
        if (request.method == 'PATCH' &&
            request.url.path == '/rest/v1/itinerary_items') {
          final id = request.url.queryParameters['id']!.substring(3);
          final status = jsonDecode(request.body)['progress_status'] as String;
          itemStatuses[id] = status;
          return http.Response(
            jsonEncode({'id': id, 'progress_status': status}),
            200,
            request: request,
            headers: {'content-type': 'application/json'},
          );
        }
        final data = switch (request.url.path) {
          '/functions/v1/tourism-search' => {
            'places': [
              {
                'contentId': '12345',
                'language': 'en',
                'name': 'Gyeongbokgung Palace',
                'address': 'Seoul',
                'latitude': 37.5796,
                'longitude': 126.9770,
              },
            ],
          },
          '/rest/v1/rpc/add_tour_itinerary_item' => {'id': 'new-item'},
          '/rest/v1/trips' => [
            {
              'id': 'trip-1',
              'owner_id': 'user-1',
              'title': '서울 샘플',
              'destination_name': '서울',
              'start_date': '2026-10-15',
              'end_date': '2026-10-18',
              'time_zone_id': 'Asia/Seoul',
            },
            if (includeSecondTrip)
              {
                'id': 'trip-2',
                'owner_id': 'user-1',
                'title': '서울 두 번째',
                'destination_name': '서울',
                'start_date': '2026-10-19',
                'end_date': '2026-10-20',
                'time_zone_id': 'Asia/Seoul',
              },
          ],
          '/rest/v1/itinerary_items' => [
            {
              'id': 'item-2',
              'trip_id': 'trip-1',
              'place_id': 'place-2',
              'scheduled_date': '2026-10-15',
              'position': 1,
              'progress_status': itemStatuses['item-2'],
              'notes': '13:00 · 방문',
            },
            {
              'id': 'item-1',
              'trip_id': 'trip-1',
              'place_id': 'place-1',
              'scheduled_date': '2026-10-15',
              'position': 0,
              'progress_status': itemStatuses['item-1'],
              'notes': '10:00 · 산책',
            },
          ],
          '/rest/v1/places' => [
            {'id': 'place-1', 'display_name': '광화문광장', 'latitude': null},
            {'id': 'place-2', 'display_name': '경복궁', 'latitude': null},
          ],
          '/rest/v1/profiles' => {'id': 'user-1', 'user_language': 'ja'},
          '/rest/v1/user_preferences' => {
            'user_id': 'user-1',
            'destination_language': 'ko',
            'location_permission_status': 'unknown',
            'uber_install_status': 'unknown',
            'default_transport_mode': 'walking',
          },
          _ => <Object>[],
        };
        return http.Response(
          jsonEncode(data),
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    await client.auth.setInitialSession(
      jsonEncode({
        'access_token': 'test-token',
        'refresh_token': 'test-refresh',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': {
          'id': 'user-1',
          'aud': 'authenticated',
          'app_metadata': {},
          'user_metadata': {},
          'created_at': '2026-10-01T00:00:00Z',
        },
      }),
    );
    backend = NextMateBackend(client);
  });

  tearDown(() async => client.dispose());

  test('live trip groups four days and orders visits by position', () async {
    final data = (await LiveTripData.load(backend))!;
    expect(data.days, ['2026-10-15', '2026-10-16', '2026-10-17', '2026-10-18']);
    expect(data.itemsFor('2026-10-15').map(data.placeName), ['광화문광장', '경복궁']);
  });

  test('Uber route link carries the real destination', () {
    final taxi = uberRideRequestUri(
      destinationName: '인사동',
      destinationLatitude: 37.5740,
      destinationLongitude: 126.9849,
    );
    expect(taxi.scheme, 'uber');
    expect(taxi.queryParameters['pickup'], 'my_location');
    expect(taxi.queryParameters['dropoff[nickname]'], '인사동');
    expect(uberAppUri.scheme, 'uber');
  });

  testWidgets('signed-in shell shows real trip instead of gallery sample', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('서울 샘플'), findsWidgets);
    expect(find.text('MMCA Seoul'), findsNothing);

    expect(find.byType(NextMoveHome), findsOneWidget);
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(TripOverviewScreen), findsOneWidget);
    expect(find.text('전체 일정'), findsOneWidget);
    expect(find.text('PLACES'), findsOneWidget);
    expect(find.text('STAYS'), findsNothing);
    await tester.tap(find.text('1일차 · 2곳'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 방문 장소'), findsOneWidget);
    expect(find.byTooltip('방문 상태 변경'), findsNWidgets(2));
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('日本語 · Japanese'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);

    await tester.ensureVisible(find.text('Save settings'));
    await tester.tap(find.text('Save settings'));
    await tester.pumpAndSettle();
    expect(writes.map((request) => request.url.path), [
      '/rest/v1/profiles',
      '/rest/v1/user_preferences',
    ]);
  });

  testWidgets('manual next place advances immediately and can be undone', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();

    expect(find.text('광화문광장'), findsWidgets);
    await tester.tap(find.text('방문 완료 · 다음 장소'));
    await tester.pumpAndSettle();

    expect(itemStatuses['item-1'], 'completed');
    expect(find.byType(LiveRouteComparisonScreen), findsOneWidget);
    expect(find.textContaining('경복궁'), findsWidgets);
    expect(find.text('대중교통'), findsOneWidget);
    expect(find.text('택시 / Uber'), findsOneWidget);
    expect(find.textContaining('대중교통 카드를 누르면 앱 안에서 경로를 조회해요'), findsOneWidget);
    expect(find.text('17–22 min'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('transit-mode-card')));
    await tester.pumpAndSettle();
    expect(find.text('대중교통 경로'), findsOneWidget);
    expect(find.textContaining('위치가 등록되지 않았어요'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('taxi-mode-card')));
    await tester.pumpAndSettle();
    expect(find.text('Uber 열기 / 설치 안내'), findsOneWidget);
    expect(find.textContaining('직접 검색해 주세요'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('방문 상태 되돌리기'));
    await tester.pumpAndSettle();
    expect(itemStatuses['item-1'], 'planned');
    expect(find.text('광화문광장'), findsWidgets);
  });

  testWidgets('current place can open transport comparison without advancing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('이동수단 비교'));
    await tester.pumpAndSettle();

    expect(itemStatuses['item-1'], 'planned');
    expect(find.byType(LiveRouteComparisonScreen), findsOneWidget);
    expect(find.text('방문 상태 되돌리기'), findsNothing);
    expect(find.text('대중교통'), findsOneWidget);
    expect(find.text('택시 / Uber'), findsOneWidget);
  });

  testWidgets('selected trip is remembered for the signed-in account', (
    tester,
  ) async {
    includeSecondTrip = true;
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('서울 샘플').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('서울 두 번째').last);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('selected_trip_user-1'), 'trip-2');
  });

  testWidgets('skip moves to the next place without marking a visit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('건너뛰고 다음 장소'));
    await tester.pumpAndSettle();

    expect(itemStatuses['item-1'], 'skipped');
    expect(find.byType(LiveRouteComparisonScreen), findsOneWidget);
    expect(find.textContaining('경복궁'), findsWidgets);
  });

  testWidgets('tourism search adds the selected result to the itinerary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();
    expect(find.textContaining('지도 연결 전'), findsOneWidget);
    expect(find.textContaining('Search places in 서울'), findsOneWidget);
    expect(find.text('Explore 서울'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'palace');
    await tester.tap(find.byTooltip('검색'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(
      posts.map((request) => request.url.path),
      contains('/functions/v1/tourism-search'),
    );
    expect(find.text('Gyeongbokgung Palace'), findsOneWidget);

    await tester.tap(find.text('+ Add'));
    await tester.pumpAndSettle();
    expect(
      posts.map((request) => request.url.path),
      contains('/rest/v1/rpc/add_tour_itinerary_item'),
    );
  });

  testWidgets('tourism suggestions appear after typing pauses', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'pal');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField), 'palace');
    await tester.pump(const Duration(milliseconds: 399));
    expect(
      posts.where(
        (request) => request.url.path == '/functions/v1/tourism-search',
      ),
      isEmpty,
    );

    await tester.pump(const Duration(milliseconds: 1));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    final searches = posts.where(
      (request) => request.url.path == '/functions/v1/tourism-search',
    );
    expect(searches, hasLength(1));
    expect(jsonDecode(searches.single.body)['keyword'], 'palace');
    expect(
      find.widgetWithText(ListTile, 'Gyeongbokgung Palace'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ListTile, 'Gyeongbokgung Palace'));
    await tester.pumpAndSettle();
    expect(find.text('일정에 추가'), findsOneWidget);
  });

  testWidgets('explore results panel folds while the search field is focused', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('Done'), findsNothing);

    await tester.tapAt(const Offset(400, 400));
    await tester.pump();
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.byType(TextField));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'palace');
    await tester.tap(find.byTooltip('검색'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('older tourism responses cannot replace a newer suggestion', (
    tester,
  ) async {
    final tourism = _DelayedTourismRepository(client);
    List<TourPlace> visible = const [];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TourismAutocomplete(
            tourism: tourism,
            language: 'en',
            onResults: (places) => visible = places,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'palace');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'museum');
    await tester.pump(const Duration(milliseconds: 400));
    tourism.complete('museum', 'Seoul Museum');
    await tester.pump();
    tourism.complete('palace', 'Old Palace');
    await tester.pump();

    expect(visible.single.name, 'Seoul Museum');
    expect(find.text('Old Palace'), findsNothing);
  });
}

class _DelayedTourismRepository extends TourismRepository {
  _DelayedTourismRepository(super.client);

  final Map<String, Completer<List<TourPlace>>> _pending = {};

  @override
  Future<List<TourPlace>> search(String keyword, {String language = 'en'}) {
    final completer = Completer<List<TourPlace>>();
    _pending[keyword] = completer;
    return completer.future;
  }

  void complete(String keyword, String name) {
    _pending[keyword]!.complete([
      TourPlace(
        contentId: keyword,
        language: 'en',
        name: name,
        address: 'Seoul',
        latitude: 37.5,
        longitude: 127,
      ),
    ]);
  }
}

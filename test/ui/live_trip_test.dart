import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trip_project/backend/backend.dart';
import 'package:trip_project/main.dart';
import 'package:trip_project/ui/live_trip_data.dart';

void main() {
  late SupabaseClient client;
  late NextMateBackend backend;
  late List<http.Request> writes;
  late List<http.Request> posts;

  setUp(() async {
    writes = [];
    posts = [];
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        if (request.method == 'PATCH') writes.add(request);
        if (request.method == 'POST') posts.add(request);
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
          ],
          '/rest/v1/itinerary_items' => [
            {
              'id': 'item-2',
              'trip_id': 'trip-1',
              'place_id': 'place-2',
              'scheduled_date': '2026-10-15',
              'position': 1,
              'progress_status': 'planned',
              'notes': '13:00 · 방문',
            },
            {
              'id': 'item-1',
              'trip_id': 'trip-1',
              'place_id': 'place-1',
              'scheduled_date': '2026-10-15',
              'position': 0,
              'progress_status': 'planned',
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

  testWidgets('signed-in shell shows real trip instead of gallery sample', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('서울 샘플'), findsWidgets);
    expect(find.text('MMCA Seoul'), findsNothing);

    await tester.tap(find.text('일정').last);
    await tester.pumpAndSettle();
    expect(find.text('전체 일정'), findsOneWidget);
    expect(find.text('PLACES'), findsOneWidget);
    expect(find.text('STAYS'), findsNothing);

    await tester.tap(find.text('프로필').last);
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

  testWidgets('tourism search adds the selected result to the itinerary', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TravelAppShell(backend: backend)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('장소').last);
    await tester.pumpAndSettle();
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

    await tester.tap(find.byTooltip('일정에 추가'));
    await tester.pumpAndSettle();
    expect(
      posts.map((request) => request.url.path),
      contains('/rest/v1/rpc/add_tour_itinerary_item'),
    );
  });
}

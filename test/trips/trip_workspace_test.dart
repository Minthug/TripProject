import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trip_project/backend/backend.dart';
import 'package:trip_project/trips/trip_workspace_screen.dart';

void main() {
  late SupabaseClient client;

  testWidgets('signed-in traveler creates a trip and a day-plan draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final trips = <Map<String, dynamic>>[];
    final places = <Map<String, dynamic>>[];
    final items = <Map<String, dynamic>>[];
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((request) async {
        final path = request.url.path;
        Object body;
        if (path.endsWith('/trips')) {
          if (request.method == 'POST') {
            final input = jsonDecode(request.body) as Map<String, dynamic>;
            final trip = {'id': 'trip-1', ...input};
            trips.add(trip);
            body = trip;
          } else {
            body = trips;
          }
        } else if (path.endsWith('/places')) {
          body = places;
        } else if (path.endsWith('/itinerary_items')) {
          body = items;
        } else if (path.endsWith('/rpc/add_draft_itinerary_item')) {
          final input = jsonDecode(request.body) as Map<String, dynamic>;
          places.add({
            'id': 'place-1',
            'trip_id': 'trip-1',
            'display_name': input['p_display_name'],
            'latitude': null,
          });
          final item = {
            'id': 'item-1',
            'trip_id': 'trip-1',
            'place_id': 'place-1',
            'scheduled_date': input['p_scheduled_date'],
            'position': 0,
            'progress_status': 'planned',
            'notes': input['p_notes'],
          };
          items.add(item);
          body = item;
        } else {
          return http.Response('not found', 404, request: request);
        }
        return http.Response(
          jsonEncode(body),
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
          'email': 'traveler@example.com',
          'app_metadata': {},
          'user_metadata': {},
          'created_at': '2026-10-01T00:00:00Z',
        },
      }),
    );

    await tester.pumpWidget(
      MaterialApp(home: TripWorkspaceScreen(backend: NextMateBackend(client))),
    );
    await tester.pumpAndSettle();
    expect(find.text('아직 저장한 여행이 없어요.'), findsOneWidget);

    await tester.tap(find.text('첫 여행 만들기'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '서울 주말 여행');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(trips, hasLength(1));
    expect(find.text('서울 주말 여행'), findsOneWidget);

    await tester.tap(find.text('장소 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '경복궁');
    await tester.tap(find.text('일정에 추가'));
    await tester.pumpAndSettle();
    expect(items, hasLength(1));
    expect(find.text('경복궁'), findsOneWidget);
    expect(find.text('위치 미등록 · 경로 안내 불가'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

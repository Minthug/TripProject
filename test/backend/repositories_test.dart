import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trip_project/backend/backend.dart';
import 'package:trip_project/backend/repositories.dart';

void main() {
  late SupabaseClient client;
  late NextMateBackend backend;
  late List<http.Request> requests;
  late int status;
  late Object response;
  const trip = {
    'id': 'trip-1',
    'owner_id': 'user-1',
    'title': 'Seoul',
    'destination_name': 'Seoul',
    'start_date': '2026-10-10',
    'end_date': '2026-10-12',
    'time_zone_id': 'Asia/Seoul',
  };
  const input = TripInput(
    title: 'Seoul',
    destinationName: 'Seoul',
    startDate: '2026-10-10',
    endDate: '2026-10-12',
    timeZoneId: 'Asia/Seoul',
  );

  setUp(() async {
    requests = [];
    status = 200;
    response = trip;
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient((req) async {
        requests.add(req);
        return http.Response(
          jsonEncode(response),
          status,
          request: req,
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
  tearDown(() async => await client.dispose());

  test('configuration rejects secret keys and incomplete settings', () {
    expect(
      () => const BackendConfig(
        'https://example.com',
        'sb_secret_bad',
      ).validate(),
      throwsArgumentError,
    );
    expect(
      () => const BackendConfig('https://example.com', '').validate(),
      throwsArgumentError,
    );
    const BackendConfig(
      'http://127.0.0.1:54321',
      'sb_publishable_local',
    ).validate();
  });
  test(
    'trip creation binds owner to session and sends date-only values',
    () async {
      final created = await backend.trips.create(input);
      expect(created.id, 'trip-1');
      final body = jsonDecode(requests.single.body) as Map;
      expect(body['owner_id'], 'user-1');
      expect(body['start_date'], '2026-10-10');
      expect(requests.single.method, 'POST');
      expect(requests.single.headers['Authorization'], 'Bearer test-token');
    },
  );
  test('trip list uses bounded pagination and decodes models', () async {
    response = [trip];
    expect((await backend.trips.list(limit: 10)).single.title, 'Seoul');
    expect(requests.single.url.queryParameters['limit'], '10');
  });
  test('trip update and delete target only requested ID', () async {
    await backend.trips.update('trip-1', input);
    expect(requests.last.method, 'PATCH');
    expect(requests.last.url.queryParameters['id'], 'eq.trip-1');
    response = [];
    expect(await backend.trips.delete('hidden-trip'), isFalse);
    expect(requests.last.method, 'DELETE');
  });
  test('invalid dates fail before any request', () async {
    await expectLater(
      backend.trips.create(
        const TripInput(
          title: 'x',
          destinationName: 'x',
          startDate: '2026-02-30',
          endDate: '2026-03-02',
          timeZoneId: 'Asia/Seoul',
        ),
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(requests, isEmpty);
  });
  test('unauthenticated reads fail without issuing a query', () async {
    final anonymous = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
    );
    expect(
      () => TripRepository(anonymous).list(),
      throwsA(isA<RepositoryException>()),
    );
    await anonymous.dispose();
  });
  test('itinerary updates are scoped to both trip and item', () async {
    response = {'id': 'item-1', 'progress_status': 'skipped'};
    await backend.itinerary.skip('trip-1', 'item-1');
    expect(requests.single.url.queryParameters['trip_id'], 'eq.trip-1');
    expect(requests.single.url.queryParameters['id'], 'eq.item-1');
    expect(jsonDecode(requests.single.body)['progress_status'], 'skipped');
  });
  test('draft place and itinerary are created through one RPC', () async {
    response = {
      'id': 'item-1',
      'trip_id': 'trip-1',
      'place_id': 'place-1',
      'scheduled_date': '2026-10-11',
      'position': 0,
    };
    final created = await backend.itinerary.addDraftPlace(
      'trip-1',
      '2026-10-11',
      ' 경복궁 ',
      notes: ' 오전 방문 ',
    );
    expect(created['place_id'], 'place-1');
    expect(requests, hasLength(1));
    expect(requests.single.url.path, '/rest/v1/rpc/add_draft_itinerary_item');
    final body = jsonDecode(requests.single.body) as Map;
    expect(body['p_trip_id'], 'trip-1');
    expect(body['p_display_name'], '경복궁');
    expect(body['p_notes'], '오전 방문');
  });
  test('empty draft place name is rejected before request', () async {
    expect(
      () => backend.itinerary.addDraftPlace('trip-1', '2026-10-11', '  '),
      throwsA(isA<RepositoryException>()),
    );
    expect(requests, isEmpty);
  });
  test('invalid draft itinerary date is rejected before request', () async {
    expect(
      () => backend.itinerary.addDraftPlace('trip-1', '2026-02-30', '경복궁'),
      throwsA(isA<RepositoryException>()),
    );
    expect(requests, isEmpty);
  });
  test('caller cannot rewrite row ownership', () async {
    await expectLater(
      backend.places.create('trip-1', {'created_by': 'other'}),
      throwsA(isA<RepositoryException>()),
    );
    expect(requests, isEmpty);
  });
  test('personal alerts filter by current user as well as trip', () async {
    response = [];
    await backend.alerts.list('trip-1');
    expect(requests.single.url.queryParameters['user_id'], 'eq.user-1');
    expect(requests.single.url.queryParameters['trip_id'], 'eq.trip-1');
  });
  test('invitations never request token hashes', () async {
    response = [];
    await backend.members.invitations('trip-1');
    expect(
      requests.single.url.queryParameters['select'],
      isNot(contains('token_hash')),
    );
  });
  test('RLS errors become stable failures without database detail', () async {
    status = 403;
    response = {'code': '42501', 'message': 'internal database detail'};
    await expectLater(
      backend.trips.create(input),
      throwsA(
        isA<RepositoryException>().having(
          (e) => e.kind,
          'kind',
          FailureKind.forbidden,
        ),
      ),
    );
  });
}

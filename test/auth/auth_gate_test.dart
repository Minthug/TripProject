import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trip_project/auth/auth_gate.dart';
import 'package:trip_project/auth/auth_screen.dart';
import 'package:trip_project/backend/auth_redirect.dart';
import 'package:trip_project/backend/backend.dart';
import 'package:trip_project/main.dart';

void main() {
  test('only the registered callback URI is accepted', () {
    expect(
      isAuthCallbackUri(
        Uri.parse('com.minthug.nextmate://login-callback/?code=abc'),
      ),
      isTrue,
    );
    expect(
      isAuthCallbackUri(Uri.parse('com.minthug.nextmate://other/?code=abc')),
      isFalse,
    );
    expect(isAuthCallbackUri(Uri.parse(mobileAuthRedirectUrl)), isFalse);
  });

  late SupabaseClient client;
  late NextMateBackend backend;

  setUp(() {
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
      httpClient: MockClient(
        (request) async => http.Response(
          '{}',
          200,
          request: request,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    backend = NextMateBackend(client);
  });
  tearDown(() async => client.dispose());

  Future<void> setSession() => client.auth.setInitialSession(
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

  Widget app() => MaterialApp(
    home: AuthGate(
      backend: backend,
      authenticatedBuilder: (context, session, signOut) => Scaffold(
        body: Column(
          children: [
            Text(session.user.email ?? ''),
            TextButton(onPressed: signOut, child: const Text('로그아웃')),
          ],
        ),
      ),
    ),
  );

  testWidgets('unauthenticated users see the provider choice', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('Google로 계속'), findsOneWidget);
    expect(find.text('Apple로 계속'), findsOneWidget);
    expect(find.text('traveler@example.com'), findsNothing);
  });

  testWidgets('configured app opens authentication instead of gallery', (
    tester,
  ) async {
    await tester.pumpWidget(
      BackendScope(backend: backend, child: const TripProjectApp()),
    );
    expect(find.text('Google로 계속'), findsOneWidget);
    expect(find.text('NextMate · UI Gallery'), findsNothing);
  });

  testWidgets('a new session replaces the sign-in choice', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('Google로 계속'), findsOneWidget);

    await setSession();
    await tester.pumpAndSettle();
    expect(find.text('traveler@example.com'), findsOneWidget);
    expect(find.text('Google로 계속'), findsNothing);
  });

  testWidgets('restored session skips login and logout returns to it', (
    tester,
  ) async {
    await setSession();
    await tester.pumpWidget(app());
    expect(find.text('traveler@example.com'), findsOneWidget);
    expect(find.text('Google로 계속'), findsNothing);

    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    expect(find.text('Google로 계속'), findsOneWidget);
  });

  testWidgets('gallery preview exposes email login and signup validation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.tap(find.text('이메일로 계속'));
    await tester.pump();
    expect(find.text('이메일로 로그인'), findsOneWidget);

    await tester.tap(find.text('회원가입'));
    await tester.pump();
    expect(find.text('이메일로 가입'), findsOneWidget);
    await tester.ensureVisible(find.text('가입하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('가입하기'));
    await tester.pump();
    expect(find.text('올바른 이메일을 입력해 주세요.'), findsOneWidget);
    expect(find.text('비밀번호를 입력해 주세요.'), findsOneWidget);
  });

  testWidgets('email signup rejects a password shorter than eight characters', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    await tester.tap(find.text('이메일로 계속'));
    await tester.pump();
    await tester.tap(find.text('회원가입'));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, 'a@example.com');
    await tester.enterText(find.byType(TextFormField).last, '1234567');
    await tester.ensureVisible(find.text('가입하기'));
    await tester.tap(find.text('가입하기'));
    await tester.pump();
    expect(find.text('비밀번호는 8자 이상 입력해 주세요.'), findsOneWidget);
  });
}

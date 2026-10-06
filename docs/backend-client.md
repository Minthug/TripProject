# Flutter Repository 사용

`lib/backend/backend.dart`의 `NextMateBackend`가 동일 SupabaseClient를 모든
Repository에 주입한다. 앱 시작 시 URL/key가 모두 없으면 UI 갤러리 모드로 실행한다.
일부만 제공하거나 secret key를 제공하면 초기화를 실패시킨다.

```sh
flutter run -d chrome --dart-define-from-file=config/backend.local.json
```

Git에 포함하지 않는 위 파일에 다음 빌드 설정을 넣는다.

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_YOUR_KEY"
}
```

화면에서는 `BackendScope.of(context)`로 Repository 모음에 접근한다.
설정이 있는 빌드는 로그인 후 실제 DB 기반 내 여행 화면으로 진입한다.
여행 생성·수정·삭제, 날짜별 방문 장소 초안·메모·진행 상태를 저장할 수 있다.
장소 위치와 경로는 외부 API가 아직 연결되지 않아 표시하지 않는다.
설정이 없는 빌드는 기존 샘플 UI 갤러리로 시작한다. OAuth 공급자 설정은
[auth-setup.md](auth-setup.md)를 참고한다.

```dart
final backend = BackendScope.of(context)!;
await backend.auth.signIn(email, password);
final trip = await backend.trips.create(const TripInput(
  title: '서울 여행', destinationName: 'Seoul',
  startDate: '2026-10-10', endDate: '2026-10-12', timeZoneId: 'Asia/Seoul',
));
final trips = await backend.trips.list();
```

- `auth`: 가입, 로그인, 로그아웃, 비밀번호 재설정, 세션 변경 스트림.
  이메일 인증이 켜져 있으면 가입 성공 시에도 session이 null일 수 있다.
- `trips`: 타입 지정 Trip/TripInput과 생성·목록·상세·수정·삭제.
- `profile`: 본인 프로필·환경설정 조회와 수정. 생성은 DB 트리거 담당.
- `stays`, `places`, `itinerary`, `reservations`, `routes`: 여행 범위 CRUD.
- `transit`, `alerts`: 여행과 현재 사용자 범위 CRUD.
- `devices`: 본인 기기 조회, 식별자 기반 등록/갱신, 삭제.
- `members`: 멤버 조회·권한 변경·제거, 초대 목록 조회.
- `notifications`: 본인 발송 기록 조회만 제공.

여행 이외 행 payload는 마이그레이션의 snake_case 열 이름을 사용하는 Json이다.
생성 열·소유자·생성자·ID는 호출자가 변경할 수 없다. RLS가 최종 권한을 판단한다.
빈 조회/삭제 결과는 존재하지 않거나 권한이 없는 행일 수 있다.
DB/Auth 오류는 RepositoryException으로 전달하며 원본 서버 메시지는 노출하지 않는다.
네트워크 예외는 호출자가 재시도 UI에서 처리한다. 변경 요청은 자동 재시도하지 않는다.

초대 토큰 발행/검증·수락, 푸시 발송, 경로 비교 API는 아직 서버 기능 구현이 필요하다.
일정 전체 재정렬과 경로 선택 교체는 여러 행 트랜잭션 RPC가 필요하며 현재 제공하지 않는다.
단일 일정 move는 새 순서가 비어 있을 때 사용하며 충돌은 DB 제약조건으로 거부된다.

검증: `flutter test test/backend`는 실제 Supabase SDK의 HTTP 요청을 가짜 서버로 검증한다.
운영 계정이나 실제 데이터는 생성하지 않는다. 기존 SQL RLS 테스트는 `supabase test db`로 실행한다.

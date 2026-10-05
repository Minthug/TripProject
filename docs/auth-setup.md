# NextMate 로그인 설정

앱은 Supabase 설정이 있으면 로그인 상태를 확인하고, 세션이 없을 때만 로그인 화면을
보여준다. Google·Apple OAuth는 첫 성공 시 계정을 만들고 이후에는 저장된 세션으로
바로 여행 화면에 진입한다. 로그인 후 보이는 여행 화면의 일정 데이터는 아직 UI 샘플이다.
Supabase 설정이 없는 빌드(GitHub Pages 포함)는 기존 UI 갤러리로 시작한다.

## 지금 준비된 것

- 로그인·회원가입·비밀번호 재설정 화면, 세션 복원과 로그아웃 흐름
- Android/iOS 앱 복귀 링크 `com.minthug.nextmate://login-callback/`
- 로컬 Supabase의 앱 복귀 링크와 고정 웹 테스트 주소 허용 설정
- GitHub Pages 배포 전 Flutter 분석·테스트

OAuth 클라이언트 자격 증명은 아직 등록하지 않았으므로 Google·Apple 실제 로그인은
동작한다고 검증할 수 없다. `supabase/config.toml`의 공급자도 의도적으로 꺼져 있다.

## 1. 앱 연결

`config/backend.local.json`을 만들고 프로젝트의 URL과 **publishable key**를 넣는다.
이 파일은 Git에서 제외된다. 실행 예:

```sh
flutter run -d chrome --web-hostname 127.0.0.1 --web-port 7357 --dart-define-from-file=config/backend.local.json
```

필드 형식은 [backend-client.md](backend-client.md)를 참고한다. 운영용 secret key나
OAuth client secret은 Flutter에 넣지 않는다.

로컬 Supabase를 연결할 때는 `SUPABASE_URL`에 `http://127.0.0.1:54321`을
사용할 수 있다. 실제 Supabase 프로젝트에서는 프로젝트 URL과 해당 프로젝트의
publishable key를 쓴다. 공개 GitHub Pages 빌드에는 이 설정을 넣지 않아 계속
UI 갤러리로 열린다.
앱은 OAuth에 PKCE를 사용하고 지정된 복귀 주소의 인증 응답만 처리한다.
이메일 비밀번호는 앱과 로컬 Supabase에서 최소 8자이며, 클라우드 프로젝트의
최소 길이도 Authentication 설정에서 8자 이상으로 맞춰야 한다.

## 2. 나중에 OAuth 클라이언트를 만들 때

Google/Apple의 Client ID와 Secret은 Flutter 앱이나 Git 저장소가 아니라
Supabase Auth 공급자 설정에 넣는다. 공급자를 실제로 사용할 때만 활성화한다.
Google 콘솔의 승인된 리디렉션 URI는 Supabase Dashboard의 Google 공급자 화면에
표시된 Auth callback URL이다. 로컬 Supabase의 Google callback URL은
`http://127.0.0.1:54321/auth/v1/callback`이다. Apple은 Services ID와 signing
key/secret 설정이 추가로 필요하고, OAuth secret은 주기적으로 갱신해야 한다.

로컬 OAuth까지 테스트하려면 `supabase/config.toml`의 해당
`[auth.external.google]`/`[auth.external.apple]`에 Client ID를 채우고
`enabled = true`로 바꾼다. Secret은 각각
`SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET`,
`SUPABASE_AUTH_EXTERNAL_APPLE_SECRET` 환경변수로 주입한다. 실제 클라우드
프로젝트는 Dashboard → Authentication → Providers에서 등록·활성화한다.
이메일 가입·로그인도 사용할 경우 클라우드 프로젝트에서 Email 공급자를 확인한다.

## 3. 로그인 후 앱으로 복귀

클라우드 Supabase 프로젝트의 Dashboard → Authentication → URL Configuration
→ Redirect URLs에 아래 주소를 추가한다. 로컬 Supabase에는 이미
`supabase/config.toml`로 설정했지만 이 파일은 클라우드 프로젝트의 URL 설정을
자동으로 바꾸지 않는다.

```text
com.minthug.nextmate://login-callback/
http://127.0.0.1:7357/
http://localhost:7357/
```

Android `AndroidManifest.xml`과 iOS `Info.plist`에는 같은 스킴이 등록돼 있다.
Supabase Flutter가 사용하는 `app_links`가 복귀 링크를 받도록 Flutter 기본 딥링크
처리는 두 플랫폼에서 꺼뒀다.
실제로 배포한 웹 앱을 인증에 사용할 경우 그 배포 주소도 정확히 추가한다.
웹에서는 현재 페이지의 쿼리와 해시를 제외한 주소로 복귀한다. 포트를 바꿔
실행하면 허용 주소도 그 포트에 맞게 변경해야 한다.

이메일 가입 확인과 비밀번호 재설정 메일에도 같은 복귀 주소가 사용된다. 재설정
링크로 돌아오면 새 비밀번호 입력 화면이 열린다.

## 확인할 흐름

1. 로그아웃 상태에서 Google 또는 Apple로 로그인한다.
2. 앱으로 복귀해 여행 화면으로 들어가는지 확인한다.
3. 앱을 완전히 종료하고 다시 열어 로그인 화면이 건너뛰어지는지 확인한다.
4. 프로필 화면의 로그아웃을 누르면 로그인 화면으로 돌아오는지 확인한다.

클라이언트 등록 뒤에는 위 URL 허용 목록, 공급자 활성화, 실제 로그인·앱 복귀를
함께 확인해야 한다. 자격 증명 없이 자동 테스트로 확인한 것은 화면·세션 흐름까지다.

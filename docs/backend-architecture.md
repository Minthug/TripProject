# NextMate 백엔드 아키텍처

## 기본 구성

- 모바일 앱: Flutter
- 백엔드 플랫폼: Supabase
- 데이터베이스: PostgreSQL 17 + PostGIS
- 인증: Supabase Auth
- 서버 로직: Supabase Edge Functions
- 외부 지도·장소·경로: Google Maps Platform
- 푸시 알림: FCM/APNs

Flutter는 공개 가능한 Supabase URL과 publishable key만 사용한다. Google API 비밀 키,
Supabase secret key와 외부 서비스 인증 정보는 앱이나 Git 저장소에 포함하지 않고 Edge
Function secrets에 저장한다.

## 첫 번째 데이터 모델

| 테이블 | 역할 |
|---|---|
| `profiles` | 사용자 표시 정보와 앱 언어 |
| `user_preferences` | 여행지 언어, 위치 권한 상태, Uber 상태, 기본 이동수단 |
| `trips` | 여행 기간, 목적지와 현지 시간대 |
| `trip_members` | 여행 소유자, 편집자, 조회자 권한 |
| `stays` | 숙소와 실제 승하차 입구 좌표 |
| `places` | 관광지와 실제 방문객 입구 좌표 |
| `itinerary_items` | 날짜별 장소 순서, 예약과 진행 상태 |

장소 중심 좌표와 실제 입구 좌표는 분리해 저장한다. 위·경도는 Flutter에서 쉽게
사용할 수 있도록 숫자 필드로 제공하고, 거리 검색을 위해 동일 좌표를 PostGIS
`geography(Point, 4326)` 생성 열과 공간 인덱스로 관리한다.

## 접근 권한

모든 사용자 데이터 테이블에 RLS를 사용한다.

- 사용자는 자신의 프로필과 설정만 조회·수정한다.
- 여행 소유자와 초대된 멤버만 해당 여행을 조회한다.
- `owner`와 `editor`만 여행 내용, 숙소, 장소와 일정을 변경한다.
- 멤버 초대와 권한 변경, 여행 삭제는 `owner`만 수행한다.
- 앱이 다른 사용자의 여행 UUID를 알게 되더라도 RLS가 접근을 차단한다.

## 배포 방식

DB 변경은 Supabase 대시보드에서 직접 만드는 대신 `supabase/migrations/`의 SQL로
관리한다. GitHub에 연결된 Supabase는 커밋된 마이그레이션과 Edge Functions를 읽어
배포한다. 개발용 샘플 데이터는 `supabase/seed.sql`에만 두고 운영 데이터나 개인
정보는 커밋하지 않는다.

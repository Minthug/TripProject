# 한국관광공사 관광정보 연동

현재 실제 여행 화면은 한국관광공사 TourAPI의 **영문·일문 관광지 검색**을
Supabase Edge Function `tourism-search`를 통해 호출한다. 앱에는 공공데이터
인증키를 넣지 않는다. 검색 결과 중 주소와 좌표가 있는 장소를 선택하면
`add_tour_itinerary_item` RPC가 `places`와 `itinerary_items`를 한 트랜잭션에 저장한다.
검색어는 선택한 언어로 입력해야 한다. 결과가 없거나 외부 API가 실패하면
기존 `직접 입력`으로 이름만 저장할 수 있고, 이 경우 경로 안내에는 쓰지 않는다.

## 운영 설정

1. 공공데이터포털에서 영문·일문 관광정보 서비스 활용신청 상태를 확인한다.
2. 채팅에 노출된 기존 인증키는 가능하면 재발급해 교체한다.
3. Supabase Dashboard → Edge Functions → Secrets에
   `TOUR_API_SERVICE_KEY` 이름으로 **새 인증키**를 등록한다.
   값을 소스코드, Flutter 빌드 설정, Git, 명령행 인수에 넣지 않는다.
4. `supabase db push`로 새 마이그레이션을 적용하고,
   `supabase functions deploy tourism-search`로 함수를 배포한다.
5. 실제 계정으로 로그인한 앱에서 영어·일본어 검색 및 일정 저장을 각각 검증한다.

로컬 함수 테스트에 키가 필요하면 `supabase/functions/.env`에 같은 이름으로
설정한다. 이 파일은 Git에서 제외된다. 키 없이 실행하면 함수는
`service_unavailable`을 반환한다.

국문 정보는 이번 단계에서 연결하지 않았다. TourAPI의 어권별 콘텐츠가
완전히 동일하다고 가정하지 않으며, 영업시간·입구·경로는 별도 제공자/검증 후 연결한다.

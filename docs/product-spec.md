# NextMate 기본 제품 스펙

## 제품 정의

NextMate는 여행자의 일정, 숙소, 현재 위치를 기준으로 다음 목적지와 이동
방법을 안내하는 Flutter 기반 iOS·Android 여행 도우미다.

일정 설계의 기본 기준점은 숙소다. 여행 중에는 현재 위치를 우선하고, 하루의
첫 출발지와 마지막 귀가 지점에는 해당 날짜의 숙소를 사용한다.

## 지도 플랫폼 결정

지도와 장소 데이터의 기본 플랫폼은 **Google Maps Platform**으로 고정한다.

| 기능 | 기본 기술 |
|---|---|
| iOS·Android 지도 표시 | Google Maps SDK (`google_maps_flutter`) |
| 호텔·관광지 이름 검색 및 자동완성 | Google Places API |
| 장소 상세 정보와 공식 주소 확인 | Google Places API Place Details |
| 좌표와 현지 주소 변환 | Google Geocoding API |
| 자동차·도보·대중교통 경로와 예상 시간 | Google Maps 경로 API 계열 |
| 택시 호출 연결 | Uber 딥링크 |

현재 프로토타입의 지도와 검색 결과는 UI 검증용 샘플이다. 실제 지도 구현 시
직접 그린 지도 배경을 Google Maps 위젯으로 교체한다.

## 숙소 추가 흐름

1. Stay Planner에서 `+ Stay`를 누른다.
2. Google Places 자동완성으로 호텔명 또는 주소를 검색한다.
3. 선택한 장소를 Google Maps에 표시한다.
4. 사용자가 지도를 움직여 실제 승하차 입구 핀을 확인하거나 조정한다.
5. 체크인·체크아웃 날짜와 시간을 정한다.
6. 기존 숙박 구간과 겹치거나 비는 날짜를 검사한다.
7. 숙소를 여행 일정에 저장한다.

검색에 없는 숙소, 숙박 공유 서비스, 개인 주소도 중앙 고정 핀을 이용해 직접
등록할 수 있어야 한다.

## 숙소 데이터 규격

장소 중심 좌표와 실제 승하차 입구 좌표를 분리해 저장한다.

| 필드 | 설명 |
|---|---|
| `placeId` | Google Places 장소 ID. 직접 지정한 위치는 비어 있을 수 있음 |
| `displayName` | 여행자에게 표시할 숙소명 |
| `localName` | 현지어 숙소명 |
| `formattedAddress` | 현지어 공식 주소 |
| `latitude`, `longitude` | Google 장소 중심 좌표 |
| `entranceLatitude`, `entranceLongitude` | 사용자가 확인한 승하차 입구 좌표 |
| `checkInAt`, `checkOutAt` | 현지 시간 기준 체크인·체크아웃 |
| `timeZoneId` | 숙소가 위치한 지역의 시간대 |
| `luggageStorage` | 체크인 전·체크아웃 후 짐 보관 가능 여부 |
| `locationSource` | `googlePlaces` 또는 `manualPin` |

택시 딥링크와 기사 번역 카드에는 장소 중심점이 아니라 확인된 입구 좌표와
현지어 주소를 우선 사용한다.

## 다중 숙소 규칙

- 여행의 모든 숙박일은 하나의 숙소 구간에 포함되어야 한다.
- 숙소 구간끼리 날짜가 겹치거나 비면 사용자에게 알린다.
- 체크아웃과 다음 체크인이 같은 날짜라면 숙소 이동일로 표시한다.
- 이동일에는 짐 보관, 숙소 간 이동, 관광 시작 위치를 별도로 계획한다.
- 주변 랜드마크 추천은 사용자가 선택한 숙소를 기준으로 계산한다.

## 위치 및 API 보안

- Google Maps API 키는 iOS 번들 ID와 Android 패키지·서명으로 각각 제한한다.
- API 키와 비밀 값은 Git 저장소에 직접 커밋하지 않는다.
- 현재 위치는 사용자의 명시적인 권한을 받은 뒤 사용한다.
- 백그라운드 위치는 여행 중 실시간 안내에 꼭 필요한 범위에서만 요청한다.


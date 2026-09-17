import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_project/main.dart';

void main() {
  testWidgets('shows trip setup and travel home concepts on a wide screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TripProjectApp());

    expect(find.text('NextMate · UI Gallery'), findsOneWidget);
    expect(find.text('Splash'), findsOneWidget);
    expect(find.text('Plan trip'), findsOneWidget);
    expect(find.text('Stay planner'), findsOneWidget);
    expect(find.text('Plan around your stays'), findsOneWidget);
    expect(find.text('Add stay'), findsOneWidget);
    expect(find.text('Use this location'), findsOneWidget);
    expect(find.text('Day plan'), findsOneWidget);
    expect(find.text('No timetable. Go at your own pace.'), findsOneWidget);
    expect(find.text('Transit guide'), findsOneWidget);
    expect(find.text('Walk to Exit 6'), findsWidgets);
    expect(find.text('Taxi handoff'), findsOneWidget);
    expect(find.text('Ready to open Uber?'), findsOneWidget);
    expect(find.text('Driver card'), findsWidgets);
    expect(find.text('국립현대미술관\n서울관 정문으로\n가 주세요.'), findsOneWidget);
    expect(find.text('When will you be\nin Seoul?'), findsOneWidget);
    expect(find.text('L7 Myeongdong'), findsWidgets);
    expect(find.text('Next move'), findsOneWidget);
    expect(find.text('Day timeline'), findsOneWidget);
    expect(find.text('Live map'), findsOneWidget);
    expect(find.text('MMCA Seoul'), findsWidgets);
  });

  testWidgets('flow map shows button-to-screen destinations', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TripProjectApp());
    await tester.tap(find.text('Flow map'));
    await tester.pumpAndSettle();

    expect(find.text('Travel Home'), findsOneWidget);
    expect(find.text('NextMate Splash'), findsOneWidget);
    expect(find.text('Stay-based Planner'), findsOneWidget);
    expect(find.text('Add Stay Map'), findsOneWidget);
    expect(find.text('+ Stay'), findsOneWidget);
    expect(find.text('New trip'), findsOneWidget);
    expect(find.text('Build itinerary'), findsOneWidget);
    expect(find.text('Active trip'), findsOneWidget);
    expect(find.text('Uber Handoff Sheet'), findsOneWidget);
    expect(find.text('Continue in Uber'), findsOneWidget);
    expect(find.text('Live Transit Guide'), findsOneWidget);
  });

  testWidgets('Prepare an Uber opens the handoff bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextMoveHome())),
    );
    await tester.tap(find.text('Prepare an Uber'));
    await tester.pumpAndSettle();

    expect(find.text('Ready to open Uber?'), findsOneWidget);
    expect(find.text('Current location'), findsOneWidget);
    expect(find.text('Continue in Uber'), findsOneWidget);

    await tester.tap(find.text('Driver card'));
    await tester.pumpAndSettle();

    expect(find.text('기사님, 안녕하세요.'), findsOneWidget);
    expect(find.text('서울특별시 종로구 삼청로 30'), findsOneWidget);
    expect(find.text('Play Korean audio'), findsOneWidget);
  });

  testWidgets('stay planner switches anchors and adds nearby places', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StayBasedPlannerScreen())),
    );

    expect(find.text('Myeongdong Cathedral'), findsOneWidget);
    expect(find.text('Build 1 place itinerary'), findsOneWidget);

    await tester.tap(find.text('Bukchon Hanok'));
    await tester.pump();
    expect(find.text('Gyeongbokgung Palace'), findsOneWidget);

    await tester.tap(find.text('+ Add').first);
    await tester.pump();
    expect(find.text('Build 2 place itinerary'), findsOneWidget);
  });

  testWidgets('add stay searches map location and opens date assignment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AddStayMapScreen())),
    );

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.tap(find.text('L7 Hongdae'));
    await tester.pump();

    expect(find.text('서울특별시 마포구 양화로 141'), findsOneWidget);

    await tester.tap(find.text('Use this location'));
    await tester.pumpAndSettle();

    expect(find.text('When are you staying?'), findsOneWidget);
    expect(find.text('Wed, Sep 16'), findsOneWidget);
    expect(find.text('Add 2-night stay'), findsOneWidget);
  });

  testWidgets('flexible day plan handles closures and return to stay', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FlexibleDayPlanScreen())),
    );

    expect(find.textContaining('Closed on Tuesdays'), findsOneWidget);
    expect(find.text('1 place is closed today'), findsOneWidget);
    expect(find.textContaining('duration'), findsNothing);

    await tester.tap(find.text('Move to Wed'));
    await tester.pump();
    expect(find.text('All places are available today'), findsOneWidget);

    await tester.tap(find.text('Return to L7 Myeongdong'));
    await tester.pumpAndSettle();
    expect(find.text('Return to your stay'), findsOneWidget);
    expect(find.text('Public transit'), findsOneWidget);
    expect(find.text('Uber Taxi'), findsOneWidget);
  });

  testWidgets('tourist transit guide advances and shows local help', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TouristTransitGuideScreen())),
    );

    expect(find.text('을지로입구역 6번 출구'), findsWidgets);
    expect(find.text('Do not take Jamsil · Seongsu direction'), findsOneWidget);

    await tester.tap(find.text('I entered the station'));
    await tester.pump();
    expect(find.text('Follow green Line 2 signs'), findsWidgets);

    await tester.tap(find.text('Need help'));
    await tester.pumpAndSettle();
    expect(find.textContaining('타는 곳이 어디인가요?'), findsOneWidget);
    expect(find.text('Play Korean audio'), findsOneWidget);
  });

  testWidgets('home transit card opens tourist transit guidance', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextMoveHome())),
    );
    await tester.tap(find.text('Transit'));
    await tester.pumpAndSettle();

    expect(find.text('Back to L7 Myeongdong'), findsOneWidget);
    expect(find.text('Walk to Exit 6'), findsWidgets);
  });
}

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
    expect(find.text('Trip overview'), findsOneWidget);
    expect(find.text('Your whole trip'), findsOneWidget);
    expect(find.text('Use this location'), findsOneWidget);
    expect(find.text('Day plan'), findsOneWidget);
    expect(find.text('No timetable. Go at your own pace.'), findsOneWidget);
    expect(find.text('Add place'), findsWidgets);
    expect(find.text('Near L7 Myeongdong'), findsOneWidget);
    expect(find.text('Transit guide'), findsOneWidget);
    expect(find.text('Walk to Exit 6'), findsWidgets);
    expect(find.text('Route comparison'), findsOneWidget);
    expect(find.text('Compare time & cost'), findsWidgets);
    expect(find.text('Taxi handoff'), findsOneWidget);
    expect(find.text('Ready to open Uber?'), findsOneWidget);
    expect(find.text('Driver card'), findsWidgets);
    expect(find.text('국립현대미술관\n서울관 정문으로\n가 주세요.'), findsOneWidget);
    expect(find.text('Departure alert'), findsOneWidget);
    expect(find.text('Update your departure'), findsOneWidget);
    expect(find.text('Profile & settings'), findsWidgets);
    expect(find.text('App language'), findsOneWidget);
    expect(find.text('First-run onboarding'), findsOneWidget);
    expect(find.text('Travel with confidence'), findsOneWidget);
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
    expect(find.text('Trip Overview'), findsOneWidget);
    expect(find.text('Day Plan'), findsOneWidget);
    expect(find.text('Day card'), findsOneWidget);
    expect(find.text('Active trip'), findsOneWidget);
    expect(find.text('Uber Handoff Sheet'), findsOneWidget);
    expect(find.text('Continue in Uber'), findsOneWidget);
    expect(find.text('Live Transit Guide'), findsOneWidget);
  });

  testWidgets('gallery text size controls update the screen previews', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TripProjectApp());

    expect(find.text('115%'), findsOneWidget);
    await tester.tap(find.text('A+'));
    await tester.pump();
    expect(find.text('130%'), findsOneWidget);

    await tester.tap(find.text('A−'));
    await tester.pump();
    expect(find.text('115%'), findsOneWidget);
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

    await tester.tap(find.text('Build 2 place itinerary'));
    await tester.pumpAndSettle();
    expect(find.text('Your whole trip'), findsOneWidget);
  });

  testWidgets('trip overview shows stays move days open time and conflicts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TripOverviewScreen())),
    );

    expect(find.text('Sep 14–18 · 4 nights'), findsOneWidget);
    expect(find.text('L7 Myeongdong'), findsWidgets);
    expect(find.text('L7 → Bukchon Hanok'), findsOneWidget);
    expect(find.text('MOVE DAY'), findsOneWidget);
    expect(find.text('Morning is open'), findsWidgets);
    expect(find.text('Gyeongbokgung is closed on Tuesdays'), findsOneWidget);

    await tester.tap(find.text('Issues'));
    await tester.pump();
    expect(find.text('Move to Bukchon'), findsNothing);
    expect(find.text('Gyeongbokgung is closed on Tuesdays'), findsOneWidget);
    expect(find.text('Two reservations overlap by 30 minutes'), findsOneWidget);
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
    expect(find.text('Board at Euljiro 1-ga · Platform 2'), findsOneWidget);
    expect(find.text('Euljiro 3-ga'), findsWidgets);
    expect(find.text('Anguk 1'), findsOneWidget);
    expect(
      find.text('Do not take City Hall · Hongdae direction'),
      findsOneWidget,
    );
    expect(find.text('Subway map'), findsOneWidget);
    expect(find.text('Euljiro 1-ga'), findsOneWidget);
    expect(find.text('Anguk · Exit 1'), findsOneWidget);

    await tester.tap(find.text('I entered the station'));
    await tester.pump();
    expect(find.text('Follow green Line 2 signs'), findsWidgets);
    expect(find.text('Platform 2 · Board near car 4-2'), findsOneWidget);

    await tester.tap(find.text('I found the platform'));
    await tester.pump();
    expect(find.text('1 stop remaining'), findsOneWidget);

    await tester.tap(find.text('I got off to transfer'));
    await tester.pump();
    expect(find.text('Transfer here · Euljiro 3-ga'), findsOneWidget);
    expect(find.text('Do not take Ogeum direction'), findsOneWidget);

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

    expect(find.text('To MMCA Seoul'), findsOneWidget);
    expect(find.text('Walk to Exit 6'), findsWidgets);
  });

  testWidgets('compares Uber transit and walking time and cost', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RouteComparisonScreen())),
    );

    expect(find.text('Choose how to go'), findsOneWidget);
    expect(find.text('Uber'), findsOneWidget);
    expect(find.text('Public transit'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('17–22 min'), findsOneWidget);
    expect(find.text('₩13,000–17,000'), findsOneWidget);
    expect(find.text('24 min'), findsOneWidget);
    expect(find.text('₩1,500'), findsOneWidget);
    expect(find.text('31 min'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('View transit steps'), findsOneWidget);
    expect(find.text('Subway · Line 3'), findsOneWidget);
    expect(find.text('Line 3 toward Daehwa'), findsOneWidget);
    expect(find.text('Anguk'), findsOneWidget);
    expect(find.text('Gyeongbokgung'), findsOneWidget);

    await tester.tap(find.text('Bus · No. 11'));
    await tester.pumpAndSettle();
    expect(find.text('Bus 11 toward Seoul Station'), findsOneWidget);
    expect(find.text('5 stops'), findsWidgets);
    expect(find.textContaining('Get off at MMCA'), findsOneWidget);

    await tester.tap(find.text('Uber'));
    await tester.pump();
    expect(find.text('Prepare Uber'), findsOneWidget);

    await tester.ensureVisible(find.text('Prepare Uber'));
    await tester.tap(find.text('Prepare Uber'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to open Uber?'), findsOneWidget);
  });

  testWidgets('home comparison action opens route comparison', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextMoveHome())),
    );
    await tester.ensureVisible(find.text('Compare time & cost'));
    await tester.tap(find.text('Compare time & cost'));
    await tester.pumpAndSettle();

    expect(find.text('Choose how to go'), findsOneWidget);
    expect(find.text('BEST VALUE'), findsOneWidget);
  });

  testWidgets('departure status handles now reminder delay and skip', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DepartureAlertScreen())),
    );

    expect(find.text('Departure status'), findsOneWidget);
    expect(find.text('Leave now'), findsOneWidget);
    expect(find.text('Leave in 10 min'), findsOneWidget);
    expect(find.text('I am delayed'), findsOneWidget);
    expect(find.text('Skip next place'), findsOneWidget);

    await tester.tap(find.text('Leave now'));
    await tester.pump();
    expect(find.text('Ready to head out'), findsOneWidget);
    expect(find.text('Start route'), findsOneWidget);

    await tester.tap(find.text('Leave in 10 min'));
    await tester.pump();
    expect(find.text('Leave in 10 minutes'), findsOneWidget);
    expect(find.text('Reminder scheduled for 1:42 PM'), findsOneWidget);

    await tester.tap(find.text('I am delayed'));
    await tester.pump();
    expect(find.text('About 25 minutes delayed'), findsOneWidget);
    expect(
      find.text('Your 2:00 PM reservation may be affected'),
      findsOneWidget,
    );

    await tester.tap(find.text('Skip next place'));
    await tester.pumpAndSettle();
    expect(find.text('Skip MMCA Seoul?'), findsOneWidget);
    await tester.tap(find.text('Skip next place').last);
    await tester.pumpAndSettle();
    expect(find.text('Cheonggyecheon is next'), findsOneWidget);
    expect(find.text('Plan route to Cheonggyecheon'), findsOneWidget);
  });

  testWidgets('home departure card opens departure status', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextMoveHome())),
    );
    await tester.tap(find.text('MANAGE'));
    await tester.pumpAndSettle();

    expect(find.text('Departure status'), findsOneWidget);
    expect(find.text('Your schedule is currently on time'), findsOneWidget);
  });

  testWidgets('profile settings updates language permission and Uber status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProfileSettingsScreen())),
    );

    expect(find.text('Profile & settings'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('한국어 · Korean'), findsOneWidget);
    expect(find.text('While using the app'), findsOneWidget);
    expect(find.text('Installed · Ready to open'), findsOneWidget);
    expect(find.text('Transit'), findsOneWidget);

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日本語 · Japanese'));
    await tester.pumpAndSettle();
    expect(find.text('日本語 · Japanese'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('Location guidance is off'), findsOneWidget);

    await tester.ensureVisible(find.text('Check again'));
    await tester.tap(find.text('Check again'));
    await tester.pump();
    expect(find.text('Checked'), findsOneWidget);

    await tester.tap(find.text('Walk'));
    await tester.pump();
    await tester.ensureVisible(find.text('Save settings'));
    await tester.tap(find.text('Save settings'));
    await tester.pump();
    expect(find.text('사용자 설정이 저장되었습니다.'), findsOneWidget);
  });

  testWidgets('home profile button opens profile settings', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NextMoveHome())),
    );
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Profile & settings'), findsOneWidget);
    expect(find.text('Default travel mode'), findsOneWidget);
  });

  testWidgets('app shell switches between four root destinations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TravelAppShell()));

    final navigation = find.byType(NavigationBar);
    Finder navLabel(String label) =>
        find.descendant(of: navigation, matching: find.text(label));

    expect(navLabel('Today'), findsOneWidget);
    expect(navLabel('Trip'), findsOneWidget);
    expect(navLabel('Explore'), findsOneWidget);
    expect(navLabel('Profile'), findsOneWidget);
    expect(find.text('Seoul · Day 2'), findsOneWidget);

    await tester.tap(navLabel('Trip'));
    await tester.pump();
    expect(find.text('Your whole trip'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

    await tester.tap(navLabel('Explore'));
    await tester.pump();
    expect(find.text('Search places in Seoul'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

    await tester.tap(navLabel('Profile'));
    await tester.pump();
    expect(find.text('Profile & settings'), findsOneWidget);

    await tester.tap(navLabel('Today'));
    await tester.pump();
    await tester.tap(find.text('View itinerary'));
    await tester.pump();
    expect(find.text('Your whole trip'), findsOneWidget);
  });

  testWidgets('first-run onboarding completes feature and setup steps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OnboardingScreen())),
    );

    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    expect(find.text('Travel with confidence'), findsOneWidget);
    expect(find.text('Compare every way to go'), findsOneWidget);

    await tester.tap(find.text('See how it works'));
    await tester.pumpAndSettle();
    expect(find.text('STEP 2 OF 4'), findsOneWidget);
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('한국어'));
    await tester.pump();
    expect(find.text('Continue in 한국어'), findsOneWidget);
    await tester.tap(find.text('Continue in 한국어'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 3 OF 4'), findsOneWidget);
    expect(find.text('Know what is nearby'), findsOneWidget);
    await tester.tap(find.text('Allow location & continue'));
    await tester.pumpAndSettle();

    expect(find.text('STEP 4 OF 4'), findsOneWidget);
    expect(find.text('Get Uber ready'), findsOneWidget);
    await tester.tap(find.text('Uber is installed'));
    await tester.pump();
    expect(find.text('Installed · Ready'), findsOneWidget);

    await tester.tap(find.text('Start planning my trip'));
    await tester.pumpAndSettle();
    expect(find.text('When will you be\nin Seoul?'), findsOneWidget);
  });

  testWidgets('place explorer adds open places and reschedules closed places', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PlaceExplorerScreen())),
    );

    expect(find.text('1 place saved'), findsOneWidget);
    await tester.tap(find.text('+ Add').first);
    await tester.pump();
    expect(find.text('2 places saved'), findsOneWidget);

    await tester.tap(find.text('Search places in Seoul'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gyeongbokgung Palace').last);
    await tester.pumpAndSettle();

    expect(find.text('Closed on Tuesday'), findsWidgets);
    expect(find.text('Gwanghwamun main gate'), findsOneWidget);
    expect(find.text('On-site ticket available'), findsOneWidget);
    expect(find.text('서울특별시 종로구 사직로 161'), findsOneWidget);
    expect(find.text('Add to itinerary'), findsOneWidget);
  });

  testWidgets('scheduled place detail can change date and remove the place', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PlaceExplorerScreen())),
    );

    await tester.tap(find.text('Myeongdong Cathedral'));
    await tester.pumpAndSettle();

    expect(find.text('IN YOUR ITINERARY'), findsOneWidget);
    expect(find.text('Main entrance on Myeongdong-gil'), findsOneWidget);
    expect(find.text('No reservation needed'), findsOneWidget);
    expect(find.text('Save itinerary changes'), findsOneWidget);

    await tester.tap(find.text('Wed 16'));
    await tester.tap(find.text('Save itinerary changes'));
    await tester.pumpAndSettle();
    expect(find.text('1 place saved'), findsOneWidget);

    await tester.tap(find.text('Myeongdong Cathedral'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from itinerary'));
    await tester.pumpAndSettle();
    expect(find.text('0 places saved'), findsOneWidget);
  });
}

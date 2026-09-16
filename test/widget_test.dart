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
    expect(find.text('Taxi handoff'), findsOneWidget);
    expect(find.text('Ready to open Uber?'), findsOneWidget);
    expect(find.text('When will you be\nin Seoul?'), findsOneWidget);
    expect(find.text('L7 Myeongdong'), findsOneWidget);
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
    expect(find.text('Trip Setup'), findsOneWidget);
    expect(find.text('New trip'), findsOneWidget);
    expect(find.text('Add places'), findsOneWidget);
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
  });
}

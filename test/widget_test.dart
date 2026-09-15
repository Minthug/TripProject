import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_project/main.dart';

void main() {
  testWidgets('shows all three travel home concepts on a wide screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TripProjectApp());

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
    expect(find.text('Uber Confirmation'), findsOneWidget);
    expect(find.text('Open Uber'), findsOneWidget);
    expect(find.text('Live Transit Guide'), findsOneWidget);
  });
}

part of '../../main.dart';

void _openTransitGuide(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: TouristTransitGuideScreen()),
    ),
  );
}

void _openRouteComparison(BuildContext context, {bool uberInstalled = true}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          Scaffold(body: RouteComparisonScreen(uberInstalled: uberInstalled)),
    ),
  );
}

void _openDepartureAlert(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: DepartureAlertScreen()),
    ),
  );
}

void _openProfileSettings(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: ProfileSettingsScreen()),
    ),
  );
}

void _showPrototypeMessage(
  BuildContext context, {
  String message = '다음 단계는 프로토타입에서 제공되지 않습니다.',
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void _showUndoMessage(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(message),
        action: SnackBarAction(label: 'UNDO', onPressed: onUndo),
      ),
    );
}

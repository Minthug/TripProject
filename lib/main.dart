import 'package:flutter/material.dart';
import 'ui/gallery/screen_flow_board.dart';
import 'backend/backend.dart';
import 'auth/auth_gate.dart';
import 'auth/auth_screen.dart';
import 'trips/trip_workspace_screen.dart';

part 'ui/shared/colors.dart';
part 'ui/gallery/design_gallery.dart';
part 'ui/screens/splash_screen.dart';
part 'ui/screens/trip_setup_screen.dart';
part 'ui/screens/stay_planner_screen.dart';
part 'ui/screens/add_stay_screen.dart';
part 'ui/screens/trip_overview_screen.dart';
part 'ui/screens/day_plan_screen.dart';
part 'ui/screens/place_explorer_screen.dart';
part 'ui/screens/place_detail_screen.dart';
part 'ui/screens/transit_guide_screen.dart';
part 'ui/screens/driver_card_screen.dart';
part 'ui/screens/uber_handoff_screen.dart';
part 'ui/screens/route_comparison_screen.dart';
part 'ui/screens/departure_alert_screen.dart';
part 'ui/screens/profile_settings_screen.dart';
part 'ui/screens/recovery_states_screen.dart';
part 'ui/screens/onboarding_screen.dart';
part 'ui/screens/travel_shell.dart';
part 'ui/screens/next_move_home.dart';
part 'ui/screens/timeline_home.dart';
part 'ui/screens/map_first_home.dart';
part 'ui/shared/preview_widgets.dart';
part 'ui/shared/preview_navigation.dart';
part 'ui/shared/preview_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final backend = await NextMateBackend.initialize();
  runApp(BackendScope(backend: backend, child: const TripProjectApp()));
}

class TripProjectApp extends StatelessWidget {
  const TripProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final backend = BackendScope.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: backend == null ? 'NextMate UI Gallery' : 'NextMate',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
          surface: AppColors.canvas,
        ),
        scaffoldBackgroundColor: AppColors.board,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
      ),
      home: backend == null
          ? const DesignGalleryPage()
          : AuthGate(
              backend: backend,
              authenticatedBuilder: (context, session, signOut) =>
                  TripWorkspaceScreen(
                    backend: backend,
                    accountEmail: session.user.email?.isNotEmpty == true
                        ? session.user.email
                        : 'NextMate traveler',
                    onSignOut: signOut,
                  ),
            ),
    );
  }
}

part of '../../main.dart';

class TravelAppShell extends StatefulWidget {
  const TravelAppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<TravelAppShell> createState() => _TravelAppShellState();
}

class _TravelAppShellState extends State<TravelAppShell> {
  late int selectedIndex;
  TravelPreferences preferences = const TravelPreferences();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          NextMoveHome(
            preferences: preferences,
            onViewTrip: () => setState(() => selectedIndex = 1),
            onOpenProfile: () => setState(() => selectedIndex = 3),
          ),
          const TripOverviewScreen(showBack: false),
          const PlaceExplorerScreen(showBack: false),
          ProfileSettingsScreen(
            initialPreferences: preferences,
            onSaved: (value) => setState(() => preferences = value),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() => selectedIndex = value),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.paleGreen,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Today',
              korean: '오늘',
              japanese: '今日',
            ),
          ),
          NavigationDestination(
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.calendar_month_outlined),
            ),
            selectedIcon: const Badge(
              label: Text('2'),
              child: Icon(Icons.calendar_month_rounded),
            ),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Trip',
              korean: '일정',
              japanese: '旅程',
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Explore',
              korean: '장소',
              japanese: '探索',
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: _travelCopy(
              preferences.userLanguage,
              english: 'Profile',
              korean: '프로필',
              japanese: '設定',
            ),
          ),
        ],
      ),
    );
  }
}

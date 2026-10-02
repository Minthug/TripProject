part of '../../main.dart';

enum _RecoveryScenario {
  loading,
  emptySearch,
  offline,
  locationDenied,
  routeFailed,
  uberMissing,
  staleTransit,
}

extension on _RecoveryScenario {
  String get tabLabel => switch (this) {
    _RecoveryScenario.loading => 'Loading',
    _RecoveryScenario.emptySearch => 'No results',
    _RecoveryScenario.offline => 'Offline',
    _RecoveryScenario.locationDenied => 'Location',
    _RecoveryScenario.routeFailed => 'Route',
    _RecoveryScenario.uberMissing => 'Uber',
    _RecoveryScenario.staleTransit => 'Stale info',
  };

  String get eyebrow => switch (this) {
    _RecoveryScenario.loading => 'CHECKING LIVE OPTIONS',
    _RecoveryScenario.emptySearch => 'SEARCH COMPLETE',
    _RecoveryScenario.offline => 'CONNECTION LOST',
    _RecoveryScenario.locationDenied => 'ACTION REQUIRED',
    _RecoveryScenario.routeFailed => 'ROUTE UNAVAILABLE',
    _RecoveryScenario.uberMissing => 'APP REQUIRED',
    _RecoveryScenario.staleTransit => 'LAST UPDATED 8 MIN AGO',
  };

  String get title => switch (this) {
    _RecoveryScenario.loading => 'Finding your best route',
    _RecoveryScenario.emptySearch => 'No places match your search',
    _RecoveryScenario.offline => "You're offline",
    _RecoveryScenario.locationDenied => 'Turn on location for live guidance',
    _RecoveryScenario.routeFailed => 'No route found right now',
    _RecoveryScenario.uberMissing => "Uber isn't installed",
    _RecoveryScenario.staleTransit => 'Live times may be outdated',
  };

  String get description => switch (this) {
    _RecoveryScenario.loading =>
      'Checking traffic, train arrivals and walking time to MMCA Seoul.',
    _RecoveryScenario.emptySearch =>
      'Try a shorter place name, clear filters or search around your stay.',
    _RecoveryScenario.offline =>
      'Live routes cannot refresh, but your saved trip is still available.',
    _RecoveryScenario.locationDenied =>
      'NextMate needs your location only while you use directions and nearby search.',
    _RecoveryScenario.routeFailed =>
      'Transit data is temporarily unavailable for this departure time.',
    _RecoveryScenario.uberMissing =>
      'Install Uber to request a ride, or continue with another travel mode.',
    _RecoveryScenario.staleTransit =>
      'Platform and arrival details were saved earlier and may have changed.',
  };

  String get primaryAction => switch (this) {
    _RecoveryScenario.loading => 'Cancel route search',
    _RecoveryScenario.emptySearch => 'Clear search & filters',
    _RecoveryScenario.offline => 'Try connecting again',
    _RecoveryScenario.locationDenied => 'Open location settings',
    _RecoveryScenario.routeFailed => 'Try another travel mode',
    _RecoveryScenario.uberMissing => 'Open App Store',
    _RecoveryScenario.staleTransit => 'Refresh live times',
  };

  String? get secondaryAction => switch (this) {
    _RecoveryScenario.loading => null,
    _RecoveryScenario.emptySearch => 'Search near L7 Myeongdong',
    _RecoveryScenario.offline => 'Use saved trip offline',
    _RecoveryScenario.locationDenied => 'Enter a starting point',
    _RecoveryScenario.routeFailed => 'Retry this route',
    _RecoveryScenario.uberMissing => 'Use public transit instead',
    _RecoveryScenario.staleTransit => 'Keep saved route',
  };

  String get availableTitle => switch (this) {
    _RecoveryScenario.loading => 'You can keep browsing your itinerary',
    _RecoveryScenario.emptySearch => 'Your existing itinerary is unchanged',
    _RecoveryScenario.offline => 'Saved trip available offline',
    _RecoveryScenario.locationDenied => 'Manual starting point is available',
    _RecoveryScenario.routeFailed => 'Uber and walking are still available',
    _RecoveryScenario.uberMissing => 'Transit and walking still work',
    _RecoveryScenario.staleTransit => 'Saved station steps remain available',
  };

  IconData get icon => switch (this) {
    _RecoveryScenario.loading => Icons.route_rounded,
    _RecoveryScenario.emptySearch => Icons.search_off_rounded,
    _RecoveryScenario.offline => Icons.wifi_off_rounded,
    _RecoveryScenario.locationDenied => Icons.location_off_rounded,
    _RecoveryScenario.routeFailed => Icons.alt_route_rounded,
    _RecoveryScenario.uberMissing => Icons.mobile_off_rounded,
    _RecoveryScenario.staleTransit => Icons.history_rounded,
  };

  Color get color => switch (this) {
    _RecoveryScenario.loading => AppColors.green,
    _RecoveryScenario.emptySearch => const Color(0xFF52645A),
    _RecoveryScenario.offline => const Color(0xFFB64B43),
    _RecoveryScenario.locationDenied => const Color(0xFFB86D00),
    _RecoveryScenario.routeFailed => const Color(0xFFB64B43),
    _RecoveryScenario.uberMissing => const Color(0xFF27332D),
    _RecoveryScenario.staleTransit => const Color(0xFF9A6800),
  };

  Color get paleColor => switch (this) {
    _RecoveryScenario.loading => AppColors.paleGreen,
    _RecoveryScenario.emptySearch => const Color(0xFFF0F2F0),
    _RecoveryScenario.offline => const Color(0xFFFFEFEC),
    _RecoveryScenario.locationDenied => const Color(0xFFFFF2D7),
    _RecoveryScenario.routeFailed => const Color(0xFFFFEFEC),
    _RecoveryScenario.uberMissing => const Color(0xFFECEFED),
    _RecoveryScenario.staleTransit => const Color(0xFFFFF4D9),
  };
}

class RecoveryStatesScreen extends StatefulWidget {
  const RecoveryStatesScreen({super.key});

  @override
  State<RecoveryStatesScreen> createState() => _RecoveryStatesScreenState();
}

class _RecoveryStatesScreenState extends State<RecoveryStatesScreen> {
  _RecoveryScenario scenario = _RecoveryScenario.offline;

  void _handleAction(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$action selected'),
          action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'When plans change',
            subtitle: 'Clear status · useful fallback · next action',
            showProfile: false,
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 42,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _RecoveryScenario.values
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(item.tabLabel),
                          selected: scenario == item,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => scenario = item),
                          selectedColor: AppColors.deepGreen,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: scenario == item
                                ? Colors.white
                                : AppColors.ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                          side: BorderSide(
                            color: scenario == item
                                ? AppColors.deepGreen
                                : AppColors.line,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SingleChildScrollView(
                key: ValueKey(scenario),
                child: _RecoveryStatePanel(
                  scenario: scenario,
                  onPrimary: () => _handleAction(scenario.primaryAction),
                  onSecondary: scenario.secondaryAction == null
                      ? null
                      : () => _handleAction(scenario.secondaryAction!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryStatePanel extends StatelessWidget {
  const _RecoveryStatePanel({
    required this.scenario,
    required this.onPrimary,
    required this.onSecondary,
  });

  final _RecoveryScenario scenario;
  final VoidCallback onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: scenario.paleColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              scenario.eyebrow,
              style: TextStyle(
                color: scenario.color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: scenario.paleColor,
              shape: BoxShape.circle,
            ),
            child: scenario == _RecoveryScenario.loading
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: scenario.color,
                    ),
                  )
                : Icon(scenario.icon, color: scenario.color, size: 27),
          ),
          const SizedBox(height: 17),
          Text(
            scenario.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 7),
          Text(
            scenario.description,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (scenario == _RecoveryScenario.loading) ...[
            const SizedBox(height: 18),
            const _RouteLoadingPreview(),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: scenario.paleColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: scenario.color,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What still works',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scenario.availableTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PrimaryAction(
            label: scenario.primaryAction,
            icon: scenario == _RecoveryScenario.loading
                ? Icons.close_rounded
                : Icons.arrow_forward_rounded,
            background: scenario.color,
            foreground: Colors.white,
            onTap: onPrimary,
          ),
          if (onSecondary != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onSecondary,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  scenario.secondaryAction!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteLoadingPreview extends StatelessWidget {
  const _RouteLoadingPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LinearProgressIndicator(
          minHeight: 4,
          color: AppColors.green,
          backgroundColor: AppColors.paleGreen,
        ),
        const SizedBox(height: 13),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9ECE9),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: index == 1 ? .72 : .55,
                        child: Container(
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E4E0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FractionallySizedBox(
                        widthFactor: index == 2 ? .48 : .36,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF0EE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

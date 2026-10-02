part of '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  String language = 'English';
  bool locationAllowed = false;
  bool uberInstalled = false;

  void _continue() {
    if (step < 3) {
      setState(() {
        if (step == 2) locationAllowed = true;
        step += 1;
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: TripSetupScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'NextMate',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              if (step < 3)
                TextButton(
                  onPressed: () => setState(() => step = 3),
                  child: const Text('Skip setup'),
                ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: List.generate(4, (index) {
              final active = index <= step;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: active ? AppColors.green : AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'STEP ${step + 1} OF 4',
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SingleChildScrollView(
                key: ValueKey(step),
                child: switch (step) {
                  0 => const _OnboardingIntro(),
                  1 => _OnboardingLanguage(
                    selected: language,
                    onChanged: (value) => setState(() => language = value),
                  ),
                  2 => _OnboardingLocation(allowed: locationAllowed),
                  _ => _OnboardingUber(
                    installed: uberInstalled,
                    onChanged: (value) => setState(() => uberInstalled = value),
                  ),
                },
              ),
            ),
          ),
          if (step > 0) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => setState(() => step -= 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back'),
              ),
            ),
          ],
          const SizedBox(height: 5),
          _PrimaryAction(
            label: switch (step) {
              0 => 'See how it works',
              1 => 'Continue in $language',
              2 => locationAllowed ? 'Continue' : 'Allow location & continue',
              _ => 'Start planning my trip',
            },
            icon: step == 3 ? Icons.check_rounded : Icons.arrow_forward_rounded,
            background: AppColors.green,
            foreground: Colors.white,
            onTap: _continue,
          ),
        ],
      ),
    );
  }
}

class _OnboardingIntro extends StatelessWidget {
  const _OnboardingIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.travel_explore_rounded,
          title: 'Travel with confidence',
          detail:
              'NextMate keeps your stays, daily plans and next move together.',
        ),
        const SizedBox(height: 18),
        const Text('What NextMate helps with', style: _sectionTitle),
        const SizedBox(height: 9),
        const _OnboardingFeature(
          icon: Icons.calendar_month_rounded,
          title: 'Build days around your stays',
          detail: 'Keep every date, hotel and open time easy to understand.',
        ),
        const SizedBox(height: 8),
        const _OnboardingFeature(
          icon: Icons.compare_arrows_rounded,
          title: 'Compare every way to go',
          detail: 'See Uber, transit and walking time and cost together.',
        ),
        const SizedBox(height: 8),
        const _OnboardingFeature(
          icon: Icons.assistant_direction_rounded,
          title: 'Get tourist-friendly guidance',
          detail: 'Follow stations, transfers, exits and local-language help.',
        ),
      ],
    );
  }
}

class _OnboardingLanguage extends StatelessWidget {
  const _OnboardingLanguage({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const languages = [
      ('English', 'English'),
      ('한국어', 'Korean'),
      ('日本語', 'Japanese'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.translate_rounded,
          title: 'Choose your language',
          detail: 'You can change this later in Profile & settings.',
        ),
        const SizedBox(height: 18),
        ...languages.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _OnboardingChoice(
              selected: selected == item.$1,
              title: item.$1,
              detail: item.$2,
              onTap: () => onChanged(item.$1),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.language_rounded, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'For this Seoul trip, Korean names and addresses will also be shown.',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingLocation extends StatelessWidget {
  const _OnboardingLocation({required this.allowed});

  final bool allowed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.my_location_rounded,
          title: 'Know what is nearby',
          detail:
              'Allow location while using the app for routes and departure reminders.',
        ),
        const SizedBox(height: 18),
        Container(
          height: 175,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFEA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _MapCanvas()),
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.green, width: 4),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22000000), blurRadius: 12),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_pin_circle_rounded,
                    color: AppColors.green,
                    size: 31,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _PermissionReason(
          icon: Icons.route_rounded,
          title: 'Routes from where you are',
        ),
        const SizedBox(height: 7),
        const _PermissionReason(
          icon: Icons.notifications_active_outlined,
          title: 'Useful departure reminders',
        ),
        const SizedBox(height: 7),
        const _PermissionReason(
          icon: Icons.lock_outline_rounded,
          title: 'Only while you use NextMate',
        ),
        if (allowed) ...[
          const SizedBox(height: 9),
          const Text(
            'Location permission is ready.',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

class _OnboardingUber extends StatelessWidget {
  const _OnboardingUber({required this.installed, required this.onChanged});

  final bool installed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OnboardingHero(
          icon: Icons.local_taxi_rounded,
          title: 'Get Uber ready',
          detail:
              'NextMate prepares pickup and destination, then hands off to Uber.',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: installed ? AppColors.green : AppColors.line,
              width: installed ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'UBER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uber app status',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      installed ? 'Installed · Ready' : 'Not confirmed yet',
                      style: TextStyle(
                        color: installed ? AppColors.green : AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                installed
                    ? Icons.check_circle_rounded
                    : Icons.help_outline_rounded,
                color: installed ? AppColors.green : AppColors.muted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => onChanged(!installed),
            icon: Icon(
              installed
                  ? Icons.remove_circle_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: 17,
            ),
            label: Text(
              installed ? 'Uber is not installed' : 'Uber is installed',
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _OnboardingFeature(
          icon: Icons.pin_drop_outlined,
          title: 'Pickup point checked first',
          detail: 'Confirm the exact entrance before opening Uber.',
        ),
        const SizedBox(height: 8),
        const _OnboardingFeature(
          icon: Icons.translate_rounded,
          title: 'Driver card is always available',
          detail: 'Show the destination and entrance in the local language.',
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            'You can finish setup even without Uber.',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.yellow, size: 23),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: const TextStyle(
              color: Color(0xFFC7D8D0),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingFeature extends StatelessWidget {
  const _OnboardingFeature({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingChoice extends StatelessWidget {
  const _OnboardingChoice({
    required this.selected,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.green : AppColors.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionReason extends StatelessWidget {
  const _PermissionReason({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.green, size: 17),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

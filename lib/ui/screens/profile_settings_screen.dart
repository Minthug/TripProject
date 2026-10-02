part of '../../main.dart';

enum DefaultTravelMode { uber, transit, walk }

class TravelPreferences {
  const TravelPreferences({
    this.userLanguage = 'English',
    this.destinationLanguage = '한국어 · Korean',
    this.locationAllowed = true,
    this.uberInstalled = true,
    this.defaultMode = DefaultTravelMode.transit,
  });

  const TravelPreferences.standaloneHome()
    : userLanguage = 'English',
      destinationLanguage = '한국어 · Korean',
      locationAllowed = true,
      uberInstalled = true,
      defaultMode = DefaultTravelMode.uber;

  final String userLanguage;
  final String destinationLanguage;
  final bool locationAllowed;
  final bool uberInstalled;
  final DefaultTravelMode defaultMode;
}

String _travelCopy(
  String language, {
  required String english,
  required String korean,
  required String japanese,
}) {
  if (language.startsWith('한국어')) return korean;
  if (language.startsWith('日本語')) return japanese;
  return english;
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    this.initialPreferences = const TravelPreferences(),
    this.onSaved,
  });

  final TravelPreferences initialPreferences;
  final ValueChanged<TravelPreferences>? onSaved;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late String userLanguage;
  late String destinationLanguage;
  late bool locationAllowed;
  late bool uberInstalled;
  bool uberChecked = false;
  bool uberChecking = false;
  late DefaultTravelMode defaultMode;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPreferences;
    userLanguage = initial.userLanguage;
    destinationLanguage = initial.destinationLanguage;
    locationAllowed = initial.locationAllowed;
    uberInstalled = initial.uberInstalled;
    defaultMode = initial.defaultMode;
  }

  void _saveSettings() {
    widget.onSaved?.call(
      TravelPreferences(
        userLanguage: userLanguage,
        destinationLanguage: destinationLanguage,
        locationAllowed: locationAllowed,
        uberInstalled: uberInstalled,
        defaultMode: defaultMode,
      ),
    );
    _showPrototypeMessage(context, message: '사용자 설정이 여행 UI에 반영되었습니다.');
  }

  Future<void> _checkUberStatus() async {
    setState(() => uberChecking = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      uberChecking = false;
      uberChecked = true;
      uberInstalled = false;
      if (defaultMode == DefaultTravelMode.uber) {
        defaultMode = DefaultTravelMode.transit;
      }
    });
  }

  Future<void> _pickUserLanguage() async {
    final value = await _showSettingPicker(
      context,
      title: 'App language',
      current: userLanguage,
      options: const ['English', '한국어 · Korean', '日本語 · Japanese'],
    );
    if (value != null && mounted) setState(() => userLanguage = value);
  }

  Future<void> _pickDestinationLanguage() async {
    final value = await _showSettingPicker(
      context,
      title: 'Destination language',
      current: destinationLanguage,
      options: const ['한국어 · Korean', '日本語 · Japanese', '中文 · Chinese'],
    );
    if (value != null && mounted) {
      setState(() => destinationLanguage = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'Profile & settings',
            subtitle: 'Language, permissions and travel defaults',
            showProfile: false,
          ),
          const SizedBox(height: 17),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.deepGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundColor: Color(0xFFF5D67B),
                          child: Text(
                            'MK',
                            style: TextStyle(
                              color: AppColors.deepGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Min Kim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Seoul trip · Sep 14–18',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Languages', style: _sectionTitle),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: 'App language',
                        detail: 'Menus and travel guidance',
                        value: userLanguage,
                        onTap: _pickUserLanguage,
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      _SettingsTile(
                        icon: Icons.record_voice_over_rounded,
                        title: 'Destination language',
                        detail: 'Local names and driver card',
                        value: destinationLanguage,
                        onTap: _pickDestinationLanguage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  const Text('Travel readiness', style: _sectionTitle),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _PermissionTile(
                        allowed: locationAllowed,
                        onChanged: (value) =>
                            setState(() => locationAllowed = value),
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      _UberInstallTile(
                        installed: uberInstalled,
                        checked: uberChecked,
                        checking: uberChecking,
                        onCheck: _checkUberStatus,
                        onInstall: () => _showPrototypeMessage(
                          context,
                          message: 'Uber 앱스토어 페이지를 열 준비가 되었습니다.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  const Text('Default travel mode', style: _sectionTitle),
                  const SizedBox(height: 4),
                  const Text(
                    'Used first when NextMate recommends your next move.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _DefaultModeOption(
                          selected: defaultMode == DefaultTravelMode.uber,
                          icon: Icons.local_taxi_rounded,
                          label: 'Uber',
                          onTap: () {
                            if (!uberInstalled) {
                              _showPrototypeMessage(
                                context,
                                message: 'Uber 설치 후 기본 이동수단으로 선택할 수 있습니다.',
                              );
                              return;
                            }
                            setState(
                              () => defaultMode = DefaultTravelMode.uber,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _DefaultModeOption(
                          selected: defaultMode == DefaultTravelMode.transit,
                          icon: Icons.directions_subway_rounded,
                          label: 'Transit',
                          onTap: () => setState(
                            () => defaultMode = DefaultTravelMode.transit,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _DefaultModeOption(
                          selected: defaultMode == DefaultTravelMode.walk,
                          icon: Icons.directions_walk_rounded,
                          label: 'Walk',
                          onTap: () => setState(
                            () => defaultMode = DefaultTravelMode.walk,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: AppColors.green,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location is used only for routes and nearby guidance while you use the app.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _PrimaryAction(
            label: 'Save settings',
            icon: Icons.check_rounded,
            background: AppColors.green,
            foreground: Colors.white,
            onTap: _saveSettings,
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(children: children),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.chevron_right_rounded, size: 17),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.allowed, required this.onChanged});

  final bool allowed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const _SettingIcon(icon: Icons.location_on_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location permission',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                Text(
                  allowed ? 'While using the app' : 'Location guidance is off',
                  style: TextStyle(
                    fontSize: 11,
                    color: allowed ? AppColors.green : const Color(0xFFB64B43),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: allowed, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _UberInstallTile extends StatelessWidget {
  const _UberInstallTile({
    required this.installed,
    required this.checked,
    required this.checking,
    required this.onCheck,
    required this.onInstall,
  });

  final bool installed;
  final bool checked;
  final bool checking;
  final VoidCallback onCheck;
  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              _SettingIcon(
                icon: installed
                    ? Icons.local_taxi_outlined
                    : Icons.mobile_off_rounded,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Uber app',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      checking
                          ? 'Checking this device…'
                          : installed
                          ? 'Installed · Ready to open'
                          : checked
                          ? 'Checked · Not installed'
                          : 'Installation not checked',
                      style: TextStyle(
                        fontSize: 11,
                        color: checking
                            ? AppColors.muted
                            : installed
                            ? AppColors.green
                            : const Color(0xFFB64B43),
                      ),
                    ),
                  ],
                ),
              ),
              if (checking)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else
                TextButton(
                  onPressed: installed ? onCheck : onInstall,
                  child: Text(installed ? 'Check again' : 'Get Uber'),
                ),
            ],
          ),
          if (!checking && checked && !installed) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEFEC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 17,
                    color: Color(0xFFB64B43),
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Ride requests are unavailable. Transit and walking remain available.',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: AppColors.paleGreen,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 17, color: AppColors.green),
  );
}

class _DefaultModeOption extends StatelessWidget {
  const _DefaultModeOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.paleGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.green),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 15,
              color: selected ? AppColors.green : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _showSettingPicker(
  BuildContext context, {
  required String title,
  required String current,
  required List<String> options,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 11, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              ...options.map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: option == current
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.green,
                        )
                      : const Icon(
                          Icons.radio_button_off_rounded,
                          color: AppColors.muted,
                        ),
                  onTap: () => Navigator.pop(context, option),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

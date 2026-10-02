part of '../../main.dart';

class UberHandoffPreview extends StatelessWidget {
  const UberHandoffPreview({super.key, this.uberInstalled = true});

  final bool uberInstalled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const NextMoveHome(),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .38)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _UberHandoffSheetContent(
            preview: true,
            uberInstalled: uberInstalled,
          ),
        ),
      ],
    );
  }
}

class _UberHandoffSheetContent extends StatelessWidget {
  const _UberHandoffSheetContent({
    this.preview = false,
    this.uberInstalled = true,
  });

  final bool preview;
  final bool uberInstalled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .92,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7DBD8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            uberInstalled
                                ? 'Ready to open Uber?'
                                : 'Uber is not installed',
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            uberInstalled
                                ? 'Check your pickup and destination first.'
                                : 'Install Uber before requesting this ride.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _UberBadge(available: uberInstalled),
                  ],
                ),
                const SizedBox(height: 18),
                const _HandoffRoute(),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: uberInstalled
                        ? AppColors.paleGreen
                        : const Color(0xFFFFEFEC),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        uberInstalled
                            ? Icons.check_circle_rounded
                            : Icons.mobile_off_rounded,
                        size: 17,
                        color: uberInstalled
                            ? AppColors.green
                            : const Color(0xFFB64B43),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          uberInstalled
                              ? 'Destination coordinates and Korean address are ready.'
                              : 'Ride requests are unavailable. Your route details are saved.',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: preview
                            ? null
                            : () => _showDriverCard(context),
                        icon: const Icon(Icons.translate_rounded, size: 17),
                        label: const Text('Driver card'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          disabledForegroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: AppColors.line),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: uberInstalled && preview
                            ? null
                            : () => _showPrototypeMessage(
                                context,
                                message: uberInstalled
                                    ? 'Uber 앱으로 이동할 준비가 되었습니다.'
                                    : 'Uber 앱스토어 페이지를 열 준비가 되었습니다.',
                              ),
                        icon: Icon(
                          uberInstalled
                              ? Icons.open_in_new_rounded
                              : Icons.download_rounded,
                          size: 17,
                        ),
                        label: Text(
                          uberInstalled ? 'Continue in Uber' : 'Install Uber',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: uberInstalled
                              ? AppColors.ink
                              : AppColors.green,
                          disabledBackgroundColor: AppColors.ink,
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Center(
                  child: Text(
                    uberInstalled
                        ? 'Fare, vehicle selection and payment continue in Uber.'
                        : 'Or return to route comparison and choose public transit.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UberBadge extends StatelessWidget {
  const _UberBadge({this.available = true});

  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: available ? AppColors.ink : const Color(0xFFFFE4DE),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        available ? 'UBER' : 'NOT INSTALLED',
        style: TextStyle(
          color: available ? Colors.white : const Color(0xFFB64B43),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

class _HandoffRoute extends StatelessWidget {
  const _HandoffRoute();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F7),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: 5), child: _RouteDots()),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RouteAddress(
                  label: 'PICKUP',
                  title: 'Current location',
                  detail: 'Bukchon-ro 5-gil · GPS updated now',
                ),
                SizedBox(height: 15),
                _RouteAddress(
                  label: 'DESTINATION',
                  title: 'MMCA Seoul',
                  detail: '국립현대미술관 서울 · Main entrance',
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.edit_outlined, size: 17, color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

class _RouteDots extends StatelessWidget {
  const _RouteDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 73,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: 1.5, height: 53, color: const Color(0xFFBFC7C2)),
          const Positioned(
            top: 0,
            child: Icon(
              Icons.my_location_rounded,
              size: 15,
              color: AppColors.green,
            ),
          ),
          const Positioned(
            bottom: 0,
            child: Icon(
              Icons.location_on_rounded,
              size: 17,
              color: AppColors.deepGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteAddress extends StatelessWidget {
  const _RouteAddress({
    required this.label,
    required this.title,
    required this.detail,
  });

  final String label;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        Text(
          detail,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

void _showUberHandoff(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .42),
    builder: (_) =>
        const SafeArea(top: false, child: _UberHandoffSheetContent()),
  );
}

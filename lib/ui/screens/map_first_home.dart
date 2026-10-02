part of '../../main.dart';

class MapFirstHome extends StatelessWidget {
  const MapFirstHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _MapCanvas()),
        Positioned(
          left: 18,
          right: 18,
          top: 18,
          child: Row(
            children: [
              const _RoundButton(icon: Icons.menu_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 19,
                        color: AppColors.green,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Bukchon → MMCA Seoul',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 18,
          top: 92,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Leave in 24 min',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAF8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 25,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D8D4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next destination',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'MMCA Seoul',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '국립현대미술관 서울 · Main entrance',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '2:00 PM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RouteChoice(
                  selected: true,
                  icon: Icons.local_taxi_rounded,
                  title: 'Uber Taxi',
                  detail: '17 min',
                  trailing: 'Recommended',
                  onTap: () => _showUberHandoff(context),
                ),
                const SizedBox(height: 9),
                _RouteChoice(
                  selected: false,
                  icon: Icons.directions_subway_rounded,
                  title: 'Public transit',
                  detail: '24 min · No transfers',
                  trailing: '₩1,500',
                  onTap: () => _openTransitGuide(context),
                ),
                const SizedBox(height: 14),
                _PrimaryAction(
                  label: 'Prepare an Uber',
                  icon: Icons.arrow_forward_rounded,
                  background: AppColors.green,
                  foreground: Colors.white,
                  onTap: () => _showUberHandoff(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

part of '../../main.dart';

class TimelineHome extends StatelessWidget {
  const TimelineHome({super.key});

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppHeader(
            title: 'Today in Seoul',
            subtitle: '3 of 5 places remaining',
            onProfileTap: () => _openProfileSettings(context),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                _ContainerIcon(icon: Icons.my_location_rounded),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are at',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bukchon Hanok Village',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Text(
                  '1:08 PM',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Your day',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _TimelineRow(
                    time: '10:00',
                    title: 'Gyeongbokgung Palace',
                    subtitle: 'Visited · 1h 34m',
                    state: _TimelineState.done,
                  ),
                  _TimelineRow(
                    time: '12:00',
                    title: 'Bukchon Hanok Village',
                    subtitle: 'You are here',
                    state: _TimelineState.current,
                  ),
                  _TimelineRow(
                    time: '14:00',
                    title: 'MMCA Seoul',
                    subtitle: 'Next · Reservation',
                    state: _TimelineState.next,
                  ),
                  _TimelineRow(
                    time: '16:30',
                    title: 'Cheonggyecheon Stream',
                    subtitle: 'Free time',
                    state: _TimelineState.upcoming,
                  ),
                  _TimelineRow(
                    time: '18:00',
                    title: 'Myeongdong Kyoja',
                    subtitle: 'Dinner',
                    state: _TimelineState.upcoming,
                    drawLine: false,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave in 24 min',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Uber · 17 min to MMCA',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 14),
                _PrimaryAction(
                  label: 'Plan next move',
                  icon: Icons.route_rounded,
                  background: Colors.white,
                  foreground: AppColors.ink,
                  onTap: () => _openRouteComparison(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

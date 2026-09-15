import 'package:flutter/material.dart';
import 'screen_flow_board.dart';

void main() => runApp(const TripProjectApp());

class TripProjectApp extends StatelessWidget {
  const TripProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripProject UI Gallery',
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
      home: const DesignGalleryPage(),
    );
  }
}

class AppColors {
  static const ink = Color(0xFF17201B);
  static const green = Color(0xFF1E6B4E);
  static const deepGreen = Color(0xFF173F32);
  static const canvas = Color(0xFFF8F9F7);
  static const board = Color(0xFFF1F2EF);
  static const muted = Color(0xFF69716C);
  static const line = Color(0xFFE0E4E0);
  static const paleGreen = Color(0xFFE8F1EC);
  static const yellow = Color(0xFFF5D67B);
}

class DesignGalleryPage extends StatefulWidget {
  const DesignGalleryPage({super.key});

  @override
  State<DesignGalleryPage> createState() => _DesignGalleryPageState();
}

class _DesignGalleryPageState extends State<DesignGalleryPage> {
  int selected = 0;
  late bool flowMode;

  @override
  void initState() {
    super.initState();
    flowMode = Uri.base.queryParameters['view'] == 'flow';
  }

  static const variants = [
    _VariantInfo('A', 'Next move', '출발 시각과 다음 행동 중심'),
    _VariantInfo('B', 'Day timeline', '하루 일정의 흐름 중심'),
    _VariantInfo('C', 'Live map', '현재 위치와 경로 중심'),
  ];

  Widget _screen(int index) => switch (index) {
    0 => const NextMoveHome(),
    1 => const TimelineHome(),
    _ => const MapFirstHome(),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1180;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _GalleryHeader(
                  selected: selected,
                  showSelector: !wide,
                  flowMode: flowMode,
                  onSelected: (value) => setState(() => selected = value),
                  onModeChanged: (value) => setState(() => flowMode = value),
                ),
                Expanded(
                  child: flowMode
                      ? const ScreenFlowBoard()
                      : wide
                      ? SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(24, 10, 0, 36),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                variants.length,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(right: 24),
                                  child: _Preview(
                                    info: variants[index],
                                    child: _screen(index),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                            child: _Preview(
                              info: variants[selected],
                              child: _screen(selected),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.selected,
    required this.showSelector,
    required this.flowMode,
    required this.onSelected,
    required this.onModeChanged,
  });

  final int selected;
  final bool showSelector;
  final bool flowMode;
  final ValueChanged<int> onSelected;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
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
                child: const Icon(Icons.route_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TripProject · Travel Home',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '첫 화면 디자인 탐색 · Seoul Day 2',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Text(
                '390 × 844',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.phone_iphone_rounded, size: 16),
                    label: Text('Screens'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.account_tree_outlined, size: 16),
                    label: Text('Flow map'),
                  ),
                ],
                selected: {flowMode},
                onSelectionChanged: (value) => onModeChanged(value.first),
              ),
              const Spacer(),
              if (showSelector && !flowMode)
                SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 0, label: Text('A')),
                    ButtonSegment(value: 1, label: Text('B')),
                    ButtonSegment(value: 2, label: Text('C')),
                  ],
                  selected: {selected},
                  onSelectionChanged: (value) => onSelected(value.first),
                )
              else
                Text(
                  flowMode ? '버튼 → 화면 연결도' : '3 concepts',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.info, required this.child});

  final _VariantInfo info;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 390,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.ink,
                  child: Text(
                    info.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  info.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info.description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 844,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0xFFCED3CF), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class NextMoveHome extends StatelessWidget {
  const NextMoveHome({super.key});

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AppHeader(
              title: 'Seoul · Day 2',
              subtitle: 'Tuesday, September 15',
            ),
            const SizedBox(height: 22),
            const _LocationLine(label: 'Bukchon Hanok Village'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.deepGreen,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'NEXT STOP',
                        style: TextStyle(
                          color: Color(0xFFAED8C4),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.more_horiz, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'MMCA Seoul',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '국립현대미술관 서울 · 2:00 PM',
                    style: TextStyle(color: Color(0xFFC7D8D0), fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: AppColors.yellow,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Leave in 24 minutes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Arrive around 1:52 PM',
                                style: TextStyle(
                                  color: Color(0xFFC7D8D0),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAction(
                    label: 'Prepare an Uber',
                    icon: Icons.local_taxi_rounded,
                    background: const Color(0xFFF7F0D5),
                    foreground: AppColors.ink,
                    onTap: () => _showPrototypeMessage(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Other ways to get there', style: _sectionTitle),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: _ModeTile(
                    icon: Icons.directions_subway_rounded,
                    title: 'Transit',
                    detail: '24 min · Direct',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ModeTile(
                    icon: Icons.directions_walk_rounded,
                    title: 'Walk',
                    detail: '31 min · 2.1 km',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Text('Today', style: _sectionTitle),
                Spacer(),
                Text(
                  'View itinerary',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _MiniTimeline(),
          ],
        ),
      ),
    );
  }
}

class TimelineHome extends StatelessWidget {
  const TimelineHome({super.key});

  @override
  Widget build(BuildContext context) {
    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'Today in Seoul',
            subtitle: '3 of 5 places remaining',
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
                  onTap: () => _showPrototypeMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
                const _RouteChoice(
                  selected: true,
                  icon: Icons.local_taxi_rounded,
                  title: 'Uber Taxi',
                  detail: '17 min',
                  trailing: 'Recommended',
                ),
                const SizedBox(height: 9),
                const _RouteChoice(
                  selected: false,
                  icon: Icons.directions_subway_rounded,
                  title: 'Public transit',
                  detail: '24 min · No transfers',
                  trailing: '₩1,500',
                ),
                const SizedBox(height: 14),
                _PrimaryAction(
                  label: 'Prepare an Uber',
                  icon: Icons.arrow_forward_rounded,
                  background: AppColors.green,
                  foreground: Colors.white,
                  onTap: () => _showPrototypeMessage(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PhonePage extends StatelessWidget {
  const _PhonePage({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.canvas,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: child,
      ),
    ),
  );
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: const Icon(Icons.person_outline_rounded, size: 21),
        ),
      ],
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.my_location_rounded, size: 16, color: AppColors.green),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
        const Text(
          'Updated now',
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.green, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _MiniTimeline extends StatelessWidget {
  const _MiniTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          _MiniRow(
            dot: Color(0xFF98A09B),
            time: '10:00',
            label: 'Gyeongbokgung',
            checked: true,
          ),
          SizedBox(height: 11),
          _MiniRow(
            dot: AppColors.green,
            time: '12:00',
            label: 'Bukchon · You are here',
          ),
          SizedBox(height: 11),
          _MiniRow(
            dot: Color(0xFFE7B542),
            time: '14:00',
            label: 'MMCA Seoul · Next',
          ),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({
    required this.dot,
    required this.time,
    required this.label,
    this.checked = false,
  });
  final Color dot;
  final String time;
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 40,
          child: Text(
            time,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        if (checked)
          const Icon(Icons.check_rounded, size: 15, color: AppColors.muted),
      ],
    );
  }
}

class _ContainerIcon extends StatelessWidget {
  const _ContainerIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: AppColors.green, size: 19),
  );
}

enum _TimelineState { done, current, next, upcoming }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.state,
    this.drawLine = true,
  });
  final String time;
  final String title;
  final String subtitle;
  final _TimelineState state;
  final bool drawLine;

  @override
  Widget build(BuildContext context) {
    final active = state == _TimelineState.current;
    final next = state == _TimelineState.next;
    final done = state == _TimelineState.done;
    final dotColor = active
        ? AppColors.green
        : next
        ? const Color(0xFFE7B542)
        : const Color(0xFFCBD0CC);
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: done ? const Color(0xFF9AA09C) : const Color(0xFF4F5852),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: active
                        ? Border.all(color: const Color(0xFFBBD7CA), width: 4)
                        : null,
                  ),
                ),
                if (drawLine)
                  Expanded(child: Container(width: 1.5, color: AppColors.line)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Opacity(
              opacity: done ? .52 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: active ? AppColors.green : AppColors.muted,
                      fontWeight: active || next
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (active)
            const Icon(
              Icons.location_on_rounded,
              size: 17,
              color: AppColors.green,
            ),
        ],
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(),
      child: const Stack(
        children: [
          Positioned(
            left: 75,
            top: 252,
            child: _MapPin(
              label: 'You',
              icon: Icons.navigation_rounded,
              dark: true,
            ),
          ),
          Positioned(
            right: 54,
            top: 170,
            child: _MapPin(label: 'MMCA', icon: Icons.flag_rounded),
          ),
          Positioned(
            right: 20,
            top: 350,
            child: Column(
              children: [
                _MapControl(icon: Icons.add),
                SizedBox(height: 2),
                _MapControl(icon: Icons.remove),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFE8ECE7), BlendMode.src);
    final minor = Paint()
      ..color = const Color(0xFFD5DCD6)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final major = Paint()
      ..color = const Color(0xFFF9FAF8)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    final route = Paint()
      ..color = AppColors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(
      Rect.fromLTWH(-80, 115, 270, 120),
      Paint()..color = const Color(0xFFCFE1DF),
    );
    for (var i = -80.0; i < size.width + 80; i += 82) {
      canvas.drawLine(Offset(i, 0), Offset(i + 170, size.height * .67), minor);
    }
    for (var y = 72.0; y < size.height * .68; y += 105) {
      final path = Path()
        ..moveTo(0, y)
        ..cubicTo(
          size.width * .25,
          y - 35,
          size.width * .62,
          y + 35,
          size.width,
          y - 5,
        );
      canvas.drawPath(path, major);
    }
    final routePath = Path()
      ..moveTo(96, 280)
      ..cubicTo(135, 225, 180, 270, 220, 205)
      ..cubicTo(245, 166, 278, 207, 313, 185);
    canvas.drawPath(routePath, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.label, required this.icon, this.dark = false});
  final String label;
  final IconData icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.ink : AppColors.green;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(width: 12, height: 7, color: color),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _MapControl extends StatelessWidget {
  const _MapControl({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    color: Colors.white,
    child: Icon(icon, size: 18),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    elevation: 2,
    child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 21)),
  );
}

class _RouteChoice extends StatelessWidget {
  const _RouteChoice({
    required this.selected,
    required this.icon,
    required this.title,
    required this.detail,
    required this.trailing,
  });
  final bool selected;
  final IconData icon;
  final String title;
  final String detail;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: selected ? AppColors.paleGreen : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: selected ? AppColors.green : AppColors.line,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.green),
          ),
          const SizedBox(width: 11),
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
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 10,
              color: selected ? AppColors.green : AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

void _showPrototypeMessage(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('다음 단계에서 이동수단 비교 화면으로 연결됩니다.')));
}

class _VariantInfo {
  const _VariantInfo(this.key, this.title, this.description);
  final String key;
  final String title;
  final String description;
}

const _sectionTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w800);

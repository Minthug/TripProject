import 'package:flutter/material.dart';

class ScreenFlowBoard extends StatelessWidget {
  const ScreenFlowBoard({super.key});

  static const _width = 1260.0;
  static const _height = 760.0;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      minScale: .65,
      maxScale: 1.6,
      boundaryMargin: const EdgeInsets.all(80),
      child: Container(
        width: _width,
        height: _height,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9F7),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFDDE2DE)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _FlowPainter())),
            const Positioned(left: 32, top: 25, child: _BoardTitle()),
            const Positioned(
              left: 40,
              top: 292,
              child: _FlowNode(
                number: '01',
                title: 'Travel Home',
                subtitle: '현재 위치 · 다음 일정',
                icon: Icons.home_rounded,
                primary: true,
              ),
            ),
            const Positioned(
              left: 300,
              top: 118,
              child: _FlowNode(
                number: '02',
                title: 'Route Comparison',
                subtitle: '택시 · 대중교통 비교',
                icon: Icons.compare_arrows_rounded,
              ),
            ),
            const Positioned(
              left: 560,
              top: 64,
              child: _FlowNode(
                number: '03',
                title: 'Uber Confirmation',
                subtitle: '승차 · 하차 위치 확인',
                icon: Icons.local_taxi_rounded,
              ),
            ),
            const Positioned(
              left: 850,
              top: 24,
              child: _FlowNode(
                number: 'EXT',
                title: 'Uber App',
                subtitle: '호출 · 배차 · 결제',
                icon: Icons.open_in_new_rounded,
                external: true,
              ),
            ),
            const Positioned(
              left: 850,
              top: 152,
              child: _FlowNode(
                number: '04',
                title: 'Driver Card',
                subtitle: '현지어 목적지 표시',
                icon: Icons.translate_rounded,
              ),
            ),
            const Positioned(
              left: 560,
              top: 314,
              child: _FlowNode(
                number: '05',
                title: 'Transit Routes',
                subtitle: '추천 경로 선택',
                icon: Icons.directions_subway_rounded,
              ),
            ),
            const Positioned(
              left: 850,
              top: 314,
              child: _FlowNode(
                number: '06',
                title: 'Live Transit Guide',
                subtitle: '승차 · 환승 · 출구 안내',
                icon: Icons.assistant_direction_rounded,
              ),
            ),
            const Positioned(
              left: 300,
              top: 494,
              child: _FlowNode(
                number: '07',
                title: 'Itinerary',
                subtitle: '오늘의 전체 일정',
                icon: Icons.view_timeline_rounded,
              ),
            ),
            const Positioned(
              left: 560,
              top: 548,
              child: _FlowNode(
                number: '08',
                title: 'Place Detail',
                subtitle: '시간 · 입구 · 메모 수정',
                icon: Icons.place_rounded,
              ),
            ),
            const Positioned(
              left: 40,
              top: 612,
              child: _FlowNode(
                number: '09',
                title: 'Profile & Setup',
                subtitle: '언어 · Uber 준비 상태',
                icon: Icons.person_rounded,
              ),
            ),
            const _FlowLabels(),
            const Positioned(right: 28, bottom: 24, child: _Legend()),
          ],
        ),
      ),
    );
  }
}

class _BoardTitle extends StatelessWidget {
  const _BoardTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Travel Home · Screen Flow',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          '버튼 이름이 연결선 위에 표시됩니다.',
          style: TextStyle(fontSize: 12, color: Color(0xFF69716C)),
        ),
      ],
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.primary = false,
    this.external = false,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool primary;
  final bool external;

  @override
  Widget build(BuildContext context) {
    final background = primary
        ? const Color(0xFF173F32)
        : external
        ? const Color(0xFFF3EDE0)
        : Colors.white;
    final foreground = primary ? Colors.white : const Color(0xFF17201B);
    return Container(
      width: 190,
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary
              ? const Color(0xFF173F32)
              : external
              ? const Color(0xFFD4BD8E)
              : const Color(0xFFD7DDD8),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withValues(alpha: .15)
                      : const Color(0xFFE8F1EC),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: primary ? Colors.white : const Color(0xFF1E6B4E),
                ),
              ),
              const Spacer(),
              Text(
                number,
                style: TextStyle(
                  color: primary ? Colors.white60 : const Color(0xFF8A928D),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primary ? Colors.white60 : const Color(0xFF69716C),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowLabels extends StatelessWidget {
  const _FlowLabels();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(left: 217, top: 190, child: _EdgeLabel('Plan next move')),
        Positioned(left: 365, top: 265, child: _EdgeLabel('Prepare an Uber')),
        Positioned(left: 475, top: 110, child: _EdgeLabel('Uber Taxi')),
        Positioned(left: 470, top: 300, child: _EdgeLabel('Public transit')),
        Positioned(left: 742, top: 55, child: _EdgeLabel('Open Uber')),
        Positioned(left: 727, top: 174, child: _EdgeLabel('Show to driver')),
        Positioned(left: 742, top: 360, child: _EdgeLabel('Start guidance')),
        Positioned(left: 204, top: 470, child: _EdgeLabel('View itinerary')),
        Positioned(left: 475, top: 535, child: _EdgeLabel('Select place')),
        Positioned(left: 62, top: 526, child: _EdgeLabel('Profile icon')),
      ],
    );
  }
}

class _EdgeLabel extends StatelessWidget {
  const _EdgeLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE2DE)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE2DE)),
      ),
      child: const Row(
        children: [
          _LegendDot(color: Color(0xFF173F32)),
          SizedBox(width: 5),
          Text('현재 화면', style: TextStyle(fontSize: 10)),
          SizedBox(width: 13),
          _LegendDot(color: Colors.white, outlined: true),
          SizedBox(width: 5),
          Text('내부 화면', style: TextStyle(fontSize: 10)),
          SizedBox(width: 13),
          _LegendDot(color: Color(0xFFF3EDE0), outlined: true),
          SizedBox(width: 5),
          Text('외부 앱', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, this.outlined = false});
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: outlined ? Border.all(color: const Color(0xFF9AA19C)) : null,
      ),
    );
  }
}

class _FlowPainter extends CustomPainter {
  const _FlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8D9891)
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke;
    final externalPaint = Paint()
      ..color = const Color(0xFFB58D45)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    _arrow(canvas, const Offset(230, 318), const Offset(300, 170), paint);
    _arrow(canvas, const Offset(230, 326), const Offset(560, 116), paint);
    _arrow(canvas, const Offset(490, 153), const Offset(560, 116), paint);
    _arrow(canvas, const Offset(490, 184), const Offset(560, 350), paint);
    _arrow(
      canvas,
      const Offset(750, 102),
      const Offset(850, 76),
      externalPaint,
    );
    _arrow(canvas, const Offset(750, 135), const Offset(850, 194), paint);
    _arrow(canvas, const Offset(750, 366), const Offset(850, 366), paint);
    _arrow(canvas, const Offset(230, 376), const Offset(300, 530), paint);
    _arrow(canvas, const Offset(490, 546), const Offset(560, 600), paint);
    _arrow(canvas, const Offset(135, 396), const Offset(135, 612), paint);
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx + (to.dx - from.dx) * .45,
        from.dy,
        from.dx + (to.dx - from.dx) * .55,
        to.dy,
        to.dx,
        to.dy,
      );
    canvas.drawPath(path, paint);
    const arrowSize = 7.0;
    final arrow = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - arrowSize * 1.4, to.dy - arrowSize)
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - arrowSize * 1.4, to.dy + arrowSize);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

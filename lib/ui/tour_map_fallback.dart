import 'package:flutter/material.dart';

/// A clearly labeled map preview for builds without a mobile map credential.
/// Roads are decorative only; no place position is implied by this artwork.
class TourMapFallback extends StatelessWidget {
  const TourMapFallback({
    super.key,
    required this.message,
    this.showMessage = true,
  });

  final String message;
  final bool showMessage;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      CustomPaint(painter: _PreviewRoadsPainter()),
      if (showMessage)
        Align(
          alignment: const Alignment(0, -0.45),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x18000000), blurRadius: 12),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 17,
                  color: Color(0xFF217556),
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF53665D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _PreviewRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFE7ECE8), BlendMode.src);
    final sideRoad = Paint()
      ..color = const Color(0xFFD3DDD6)
      ..strokeWidth = 5;
    for (var x = -size.height; x < size.width + size.height; x += 94) {
      canvas.drawLine(
        Offset(x.toDouble(), 0),
        Offset(x + size.height * 0.22, size.height),
        sideRoad,
      );
    }
    final mainRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 17;
    for (final fraction in [0.23, 0.49, 0.78]) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 18), mainRoad);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

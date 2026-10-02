part of '../../main.dart';

class SplashScreenPreview extends StatelessWidget {
  const SplashScreenPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.deepGreen,
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F0D5),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 26,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const _NextMateMark(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'NextMate',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your next move, made local.',
                    style: TextStyle(
                      color: Color(0xFFBFD1C9),
                      fontSize: 13,
                      letterSpacing: .2,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Text(
                'TRAVEL WITH CONFIDENCE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8EACA0),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextMateMark extends StatelessWidget {
  const _NextMateMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NextMateMarkPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _NextMateMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppColors.deepGreen
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = AppColors.green;
    final start = Offset(size.width * .28, size.height * .66);
    final end = Offset(size.width * .72, size.height * .34);
    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        size.width * .28,
        size.height * .27,
        size.width * .72,
        size.height * .73,
        end.dx,
        end.dy,
      );
    canvas.drawPath(route, routePaint);
    canvas.drawCircle(start, 7, dotPaint);
    canvas.drawCircle(end, 7, dotPaint);
    canvas.drawCircle(start, 2.5, Paint()..color = const Color(0xFFF7F0D5));
    canvas.drawCircle(end, 2.5, Paint()..color = const Color(0xFFF7F0D5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

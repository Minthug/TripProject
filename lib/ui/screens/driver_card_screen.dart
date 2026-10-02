part of '../../main.dart';

class DriverCardPreview extends StatelessWidget {
  const DriverCardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DriverCardContent(preview: true);
  }
}

class _DriverCardContent extends StatelessWidget {
  const _DriverCardContent({this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.deepGreen,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: preview ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    style: IconButton.styleFrom(
                      disabledBackgroundColor: Colors.white.withValues(
                        alpha: .12,
                      ),
                      disabledForegroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: .12),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHOW TO YOUR DRIVER',
                          style: TextStyle(
                            color: Color(0xFFAED8C4),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Destination card',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Text(
                      '한국어  KO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFDFB),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.waving_hand_rounded,
                            color: Color(0xFFE7AA27),
                            size: 19,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '기사님, 안녕하세요.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 17),
                      const Text(
                        '국립현대미술관\n서울관 정문으로\n가 주세요.',
                        style: TextStyle(
                          fontSize: 27,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.7,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(height: 1, color: AppColors.line),
                      const SizedBox(height: 17),
                      const _DriverDetail(
                        icon: Icons.location_on_rounded,
                        label: '목적지',
                        value: '국립현대미술관 서울',
                      ),
                      const SizedBox(height: 14),
                      const _DriverDetail(
                        icon: Icons.signpost_rounded,
                        label: '주소',
                        value: '서울특별시 종로구 삼청로 30',
                      ),
                      const SizedBox(height: 14),
                      const _DriverDetail(
                        icon: Icons.door_front_door_rounded,
                        label: '내리는 곳',
                        value: '서울관 정문 · 삼청로 방면',
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: AppColors.green,
                              size: 18,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'English check',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Please take me to the main entrance of MMCA Seoul.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: preview
                      ? null
                      : () => _showPrototypeMessage(context),
                  icon: const Icon(Icons.volume_up_rounded, size: 19),
                  label: const Text('Play Korean audio'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF7F0D5),
                    foregroundColor: AppColors.ink,
                    disabledBackgroundColor: const Color(0xFFF7F0D5),
                    disabledForegroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverDetail extends StatelessWidget {
  const _DriverDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.paleGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.green, size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _showDriverCard(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const _DriverCardContent()));
}

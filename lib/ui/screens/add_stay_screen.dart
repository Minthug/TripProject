part of '../../main.dart';

class AddStayMapScreen extends StatefulWidget {
  const AddStayMapScreen({super.key});

  @override
  State<AddStayMapScreen> createState() => _AddStayMapScreenState();
}

class _AddStayMapScreenState extends State<AddStayMapScreen> {
  final _searchController = TextEditingController(text: 'L7 Myeongdong');
  bool showResults = false;
  bool mapMoved = false;
  Offset mapOffset = Offset.zero;
  String stayName = 'L7 Myeongdong';
  String localName = 'L7 명동 바이 롯데';
  String address = '서울특별시 중구 퇴계로 137';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectResult({
    required String name,
    required String local,
    required String newAddress,
  }) {
    setState(() {
      stayName = name;
      localName = local;
      address = newAddress;
      _searchController.text = name;
      showResults = false;
      mapMoved = false;
      mapOffset = Offset.zero;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onPanUpdate: (details) => setState(() {
              mapOffset += details.delta;
              mapMoved = true;
              showResults = false;
            }),
            child: _StayPickerMap(offset: mapOffset),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 16,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  children: [
                    _MapCircleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: Navigator.of(context).canPop()
                          ? () => Navigator.pop(context)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Add a stay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Seoul',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 3,
                  shadowColor: Colors.black26,
                  child: TextField(
                    controller: _searchController,
                    onTap: () => setState(() => showResults = true),
                    onChanged: (_) => setState(() => showResults = true),
                    decoration: InputDecoration(
                      hintText: 'Hotel name or address',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.green,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          _searchController.clear();
                          showResults = true;
                        }),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (showResults) ...[
                  const SizedBox(height: 7),
                  _StaySearchResults(onSelected: _selectResult),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 245,
          child: Column(
            children: [
              _MapCircleButton(
                icon: Icons.my_location_rounded,
                onTap: () => setState(() {
                  mapOffset = Offset.zero;
                  mapMoved = false;
                }),
              ),
              const SizedBox(height: 8),
              const _MapCircleButton(icon: Icons.layers_outlined),
            ],
          ),
        ),
        const Align(alignment: Alignment(0, -.1), child: _CenterStayPin()),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 11, 20, 22),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFBF9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5DAD6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.hotel_rounded,
                          color: AppColors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mapMoved ? 'Custom entrance pin' : stayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mapMoved ? 'Move the map to adjust' : localName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  _LocationCheckRow(
                    icon: Icons.signpost_rounded,
                    title: 'Local address',
                    detail: address,
                  ),
                  const SizedBox(height: 9),
                  _LocationCheckRow(
                    icon: Icons.door_front_door_rounded,
                    title: 'Pickup entrance',
                    detail: mapMoved
                        ? 'Pin adjusted manually'
                        : 'Main entrance · Toegye-ro',
                  ),
                  const SizedBox(height: 14),
                  _PrimaryAction(
                    label: 'Use this location',
                    icon: Icons.arrow_forward_rounded,
                    background: AppColors.green,
                    foreground: Colors.white,
                    onTap: () => _showStayDatesSheet(
                      context,
                      stayName: mapMoved ? 'Custom stay' : stayName,
                      address: address,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaySearchResults extends StatelessWidget {
  const _StaySearchResults({required this.onSelected});

  final void Function({
    required String name,
    required String local,
    required String newAddress,
  })
  onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: Column(
        children: [
          _StaySearchResult(
            title: 'L7 Myeongdong',
            detail: 'L7 명동 바이 롯데 · 137 Toegye-ro',
            onTap: () => onSelected(
              name: 'L7 Myeongdong',
              local: 'L7 명동 바이 롯데',
              newAddress: '서울특별시 중구 퇴계로 137',
            ),
          ),
          const Divider(height: 1, indent: 48),
          _StaySearchResult(
            title: 'L7 Hongdae',
            detail: 'L7 홍대 바이 롯데 · 141 Yanghwa-ro',
            onTap: () => onSelected(
              name: 'L7 Hongdae',
              local: 'L7 홍대 바이 롯데',
              newAddress: '서울특별시 마포구 양화로 141',
            ),
          ),
        ],
      ),
    );
  }
}

class _StaySearchResult extends StatelessWidget {
  const _StaySearchResult({
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: const Icon(
        Icons.hotel_rounded,
        color: AppColors.green,
        size: 19,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        detail,
        style: const TextStyle(fontSize: 11, color: AppColors.muted),
      ),
      trailing: const Icon(Icons.north_west_rounded, size: 15),
    );
  }
}

class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 19, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _CenterStayPin extends StatelessWidget {
  const _CenterStayPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.deepGreen,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Text(
            'Entrance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Icon(Icons.location_on_rounded, color: AppColors.green, size: 42),
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .18),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}

class _LocationCheckRow extends StatelessWidget {
  const _LocationCheckRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.green),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StayPickerMap extends StatelessWidget {
  const _StayPickerMap({required this.offset});

  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StayPickerMapPainter(offset),
      child: const SizedBox.expand(),
    );
  }
}

class _StayPickerMapPainter extends CustomPainter {
  const _StayPickerMapPainter(this.offset);

  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8ECE7),
    );
    canvas.save();
    canvas.translate(offset.dx % 120, offset.dy % 120);
    final minor = Paint()
      ..color = const Color(0xFFD1D9D3)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
    for (var x = -100.0; x < size.width + 100; x += 92) {
      canvas.drawLine(
        Offset(x, -100),
        Offset(x + 150, size.height + 100),
        minor,
      );
    }
    for (var y = 120.0; y < size.height; y += 115) {
      final path = Path()
        ..moveTo(-100, y)
        ..cubicTo(
          size.width * .25,
          y - 28,
          size.width * .7,
          y + 32,
          size.width + 100,
          y - 5,
        );
      canvas.drawPath(path, road);
    }
    canvas.drawCircle(
      Offset(size.width * .2, size.height * .43),
      47,
      Paint()..color = const Color(0xFFCFE2DE),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StayPickerMapPainter oldDelegate) =>
      oldDelegate.offset != offset;
}

void _showStayDatesSheet(
  BuildContext context, {
  required String stayName,
  required String address,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _StayDatesSheet(
      stayName: stayName,
      address: address,
      onAdd: () {
        Navigator.pop(sheetContext);
        _showPrototypeMessage(context);
      },
    ),
  );
}

class _StayDatesSheet extends StatelessWidget {
  const _StayDatesSheet({
    required this.stayName,
    required this.address,
    required this.onAdd,
  });

  final String stayName;
  final String address;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 11, 20, 22),
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
              const SizedBox(height: 18),
              const Text(
                'When are you staying?',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                stayName,
                style: const TextStyle(fontSize: 13, color: AppColors.green),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 17),
              const Row(
                children: [
                  Expanded(
                    child: _StayDateBox(
                      label: 'CHECK-IN',
                      date: 'Wed, Sep 16',
                      time: '3:00 PM',
                    ),
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: _StayDateBox(
                      label: 'CHECK-OUT',
                      date: 'Fri, Sep 18',
                      time: '11:00 AM',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.paleGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 17,
                      color: AppColors.green,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fills your uncovered Sep 16–18 stay · 2 nights',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryAction(
                label: 'Add 2-night stay',
                icon: Icons.add_rounded,
                background: AppColors.green,
                foreground: Colors.white,
                onTap: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StayDateBox extends StatelessWidget {
  const _StayDateBox({
    required this.label,
    required this.date,
    required this.time,
  });

  final String label;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

part of '../../main.dart';

enum _DepartureChoice { undecided, now, tenMinutes, delayed, skipped }

class DepartureAlertScreen extends StatefulWidget {
  const DepartureAlertScreen({super.key});

  @override
  State<DepartureAlertScreen> createState() => _DepartureAlertScreenState();
}

class _DepartureAlertScreenState extends State<DepartureAlertScreen> {
  _DepartureChoice choice = _DepartureChoice.undecided;

  Future<void> _skipNextPlace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip MMCA Seoul?'),
        content: const Text(
          'MMCA Seoul will stay in your saved places. Cheonggyecheon Stream becomes your next stop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep this stop'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip next place'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final previousChoice = choice;
      setState(() => choice = _DepartureChoice.skipped);
      _showUndoMessage(
        context,
        message: 'MMCA Seoul skipped. Cheonggyecheon is next.',
        onUndo: () => setState(() => choice = previousChoice),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final skipped = choice == _DepartureChoice.skipped;
    final (eyebrow, title, detail, statusColor) = switch (choice) {
      _DepartureChoice.now => (
        'LEAVING NOW',
        'Ready to head out',
        'Arrive at MMCA around 1:52 PM',
        const Color(0xFF69C99C),
      ),
      _DepartureChoice.tenMinutes => (
        'REMINDER SET',
        'Leave in 10 minutes',
        'We will remind you again at 1:42 PM',
        AppColors.yellow,
      ),
      _DepartureChoice.delayed => (
        'RUNNING LATE',
        'About 25 minutes delayed',
        'Estimated arrival · 2:17 PM',
        const Color(0xFFF2A08C),
      ),
      _DepartureChoice.skipped => (
        'STOP SKIPPED',
        'Cheonggyecheon is next',
        '18 min by public transit',
        const Color(0xFF8CBDEA),
      ),
      _ => (
        'ON TIME',
        'Leave in 24 minutes',
        'Arrive at MMCA around 1:52 PM',
        const Color(0xFF69C99C),
      ),
    };

    return _PhonePage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AppHeader(
            title: 'Departure status',
            subtitle: 'Seoul · Day 2 · Updated now',
          ),
          const SizedBox(height: 17),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.deepGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              eyebrow,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '1:08 PM',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          style: const TextStyle(
                            color: Color(0xFFC7D8D0),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DepartureDestination(
                          icon: skipped
                              ? Icons.water_rounded
                              : Icons.museum_outlined,
                          title: skipped
                              ? 'Cheonggyecheon Stream'
                              : 'MMCA Seoul',
                          local: skipped ? '청계천' : '국립현대미술관 서울',
                          time: skipped ? 'Next' : '2:00 PM',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 19),
                  const Text('Update your departure', style: _sectionTitle),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose once. You can change it again at any time.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.now,
                          icon: Icons.directions_run_rounded,
                          title: 'Leave now',
                          detail: 'Start directions',
                          color: AppColors.green,
                          onTap: () =>
                              setState(() => choice = _DepartureChoice.now),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.tenMinutes,
                          icon: Icons.snooze_rounded,
                          title: 'Leave in 10 min',
                          detail: 'Remind me again',
                          color: const Color(0xFFB18316),
                          onTap: () => setState(
                            () => choice = _DepartureChoice.tenMinutes,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.delayed,
                          icon: Icons.schedule_rounded,
                          title: 'I am delayed',
                          detail: 'Recheck the day',
                          color: const Color(0xFFC45C4D),
                          onTap: () =>
                              setState(() => choice = _DepartureChoice.delayed),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _DepartureActionCard(
                          selected: choice == _DepartureChoice.skipped,
                          icon: Icons.skip_next_rounded,
                          title: 'Skip next place',
                          detail: 'Keep it saved',
                          color: const Color(0xFF536A8A),
                          onTap: _skipNextPlace,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DepartureImpact(choice: choice),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          _PrimaryAction(
            label: switch (choice) {
              _DepartureChoice.now => 'Start route',
              _DepartureChoice.tenMinutes => 'Keep 10-minute reminder',
              _DepartureChoice.delayed => 'Review adjusted itinerary',
              _DepartureChoice.skipped => 'Plan route to Cheonggyecheon',
              _ => 'Keep current departure',
            },
            icon: choice == _DepartureChoice.tenMinutes
                ? Icons.notifications_active_outlined
                : Icons.arrow_forward_rounded,
            background: AppColors.green,
            foreground: Colors.white,
            onTap: () =>
                _showPrototypeMessage(context, message: '출발 상태가 일정에 반영되었습니다.'),
          ),
        ],
      ),
    );
  }
}

class _DepartureDestination extends StatelessWidget {
  const _DepartureDestination({
    required this.icon,
    required this.title,
    required this.local,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String local;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.yellow, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  local,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartureActionCard extends StatelessWidget {
  const _DepartureActionCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DepartureImpact extends StatelessWidget {
  const _DepartureImpact({required this.choice});

  final _DepartureChoice choice;

  @override
  Widget build(BuildContext context) {
    final (icon, title, detail, warning) = switch (choice) {
      _DepartureChoice.now => (
        Icons.check_circle_outline_rounded,
        'You will arrive about 8 minutes early',
        'The rest of today stays unchanged.',
        false,
      ),
      _DepartureChoice.tenMinutes => (
        Icons.notifications_active_outlined,
        'Reminder scheduled for 1:42 PM',
        'You should still arrive before your reservation.',
        false,
      ),
      _DepartureChoice.delayed => (
        Icons.warning_amber_rounded,
        'Your 2:00 PM reservation may be affected',
        'Cheonggyecheon moves about 25 minutes later.',
        true,
      ),
      _DepartureChoice.skipped => (
        Icons.skip_next_rounded,
        'MMCA Seoul remains in saved places',
        'Cheonggyecheon is now your next destination.',
        false,
      ),
      _ => (
        Icons.event_available_outlined,
        'Your schedule is currently on time',
        'Leave by 1:32 PM to arrive around 1:52 PM.',
        false,
      ),
    };
    final color = warning ? const Color(0xFFB64B43) : AppColors.green;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFEFEC) : AppColors.paleGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
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
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../models/daily_status.dart';

/// Sky, ruler ticks, balloon height from [progressDays], score + flame, lives, daily actions.
class BalloonView extends StatelessWidget {
  const BalloonView({
    super.key,
    required this.habitName,
    required this.progressDays,
    required this.livesRemaining,
    required this.todayStatus,
    required this.onCheck,
    required this.onFail,
  });

  final String habitName;
  final int progressDays;
  final int livesRemaining;
  final DailyStatus? todayStatus;
  final VoidCallback onCheck;
  final VoidCallback onFail;

  @override
  Widget build(BuildContext context) {
    final t = (progressDays / (progressDays + 28)).clamp(0.0, 1.0);
    final alignY = 0.88 - t * 1.45;

    final startTick = (progressDays - 4).clamp(0, progressDays);
    final endTick = progressDays + 10;
    final ticks = <int>[
      for (var d = startTick; d <= endTick; d++) d,
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        const _SkyBackground(),
        Positioned(
          left: 8,
          top: 72,
          bottom: 120,
          width: 40,
          child: _DayRuler(ticks: ticks, highlight: progressDays),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 48,
          child: Column(
            children: [
              Text(
                habitName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black26),
                      ],
                    ),
              ),
              const SizedBox(height: 6),
              Opacity(
                opacity: 0.45,
                child: Text(
                  '$progressDays 🔥',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment(0, alignY),
          child: const _BalloonGraphic(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 100,
          child: _LivesRow(livesRemaining: livesRemaining),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: _TodayActions(
            todayStatus: todayStatus,
            onCheck: onCheck,
            onFail: onFail,
          ),
        ),
      ],
    );
  }
}

class _SkyBackground extends StatelessWidget {
  const _SkyBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB),
            Color(0xFFB8E0FF),
            Color(0xFFE8F4FF),
          ],
        ),
      ),
    );
  }
}

class _DayRuler extends StatelessWidget {
  const _DayRuler({required this.ticks, required this.highlight});

  final List<int> ticks;
  final int highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
        ),
      ),
      child: ListView.builder(
        reverse: true,
        itemCount: ticks.length,
        itemBuilder: (context, index) {
          final day = ticks[ticks.length - 1 - index];
          final isHi = day == highlight;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$day',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: isHi ? 14 : 12,
                      fontWeight: isHi ? FontWeight.w800 : FontWeight.w500,
                      color: Colors.white.withValues(
                        alpha: isHi ? 0.95 : 0.55,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: isHi ? 12 : 8,
                  height: 2,
                  color: Colors.white.withValues(alpha: isHi ? 0.9 : 0.45),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalloonGraphic extends StatelessWidget {
  const _BalloonGraphic();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 110,
          height: 130,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(55),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(40, 28),
          painter: _BasketPainter(),
        ),
      ],
    );
  }
}

class _BasketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.65, size.height)
      ..lineTo(size.width * 0.35, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LivesRow extends StatelessWidget {
  const _LivesRow({required this.livesRemaining});

  final int livesRemaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final alive = i < livesRemaining;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            Icons.favorite,
            size: 28,
            color: alive
                ? Colors.redAccent
                : Colors.white.withValues(alpha: 0.25),
            shadows: const [Shadow(blurRadius: 4, color: Colors.black26)],
          ),
        );
      }),
    );
  }
}

class _TodayActions extends StatelessWidget {
  const _TodayActions({
    required this.todayStatus,
    required this.onCheck,
    required this.onFail,
  });

  final DailyStatus? todayStatus;
  final VoidCallback onCheck;
  final VoidCallback onFail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Today',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: onCheck,
                style: FilledButton.styleFrom(
                  backgroundColor: todayStatus == DailyStatus.check
                      ? Colors.green.shade200
                      : Colors.white.withValues(alpha: 0.85),
                  foregroundColor: Colors.green.shade900,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Check'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: onFail,
                style: FilledButton.styleFrom(
                  backgroundColor: todayStatus == DailyStatus.fail
                      ? Colors.orange.shade200
                      : Colors.white.withValues(alpha: 0.85),
                  foregroundColor: Colors.deepOrange.shade900,
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Fail'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Neutral until you choose. After midnight, unset days count as fail.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

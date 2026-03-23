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
    // Center balloon on screen, then move it up/down based on progress.
    // This makes centering independent from the left ruler width.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxShiftY = screenHeight * 0.35;
    final dy = -t * maxShiftY;

    final rulerLeft = 8.0;
    final rulerWidth = 40.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        const _SkyBackground(),
        Positioned(
          left: rulerLeft,
          top: 72,
          bottom: 120,
          width: rulerWidth,
          child: _DayRuler(currentDay: progressDays),
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
        // Balloon: centered on X and Y of the screen, with a score-based vertical shift.
        Center(
          child: Transform.translate(
            offset: Offset(0, dy),
            child: const _BalloonGraphic(),
          ),
        ),
        // Hearts under the AppBar `+` button (top-right).
        Positioned(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
          right: 16,
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
  const _DayRuler({required this.currentDay});

  // Only show the current day + 2 days before + 2 days after.
  // Current day is full opacity; distance fades out.
  final int currentDay;

  static const int range = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.withValues(alpha: 0.35)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // We render 5 fixed vertical slots so the direction is stable.
          // Values are clamped to 0 (as requested).
          int clamped(int v) => (v < 0 ? 0 : v);
          final topToBottomDays = <int>[
            clamped(currentDay + range),
            clamped(currentDay + (range - 1)),
            clamped(currentDay),
            clamped(currentDay - (range - 1)),
            clamped(currentDay - range),
          ];

          final baseColor = Colors.grey.shade600;

          double opacityForDist(int dist) {
            // dist: 0 => 1.0, 1 => 0.75, 2 => 0.45
            if (dist == 0) return 1.0;
            if (dist == 1) return 0.75;
            return 0.45;
          }

          return Column(
            children: List.generate(topToBottomDays.length, (index) {
              final day = topToBottomDays[index];
              final dist = (day - currentDay).abs();
              final alpha = opacityForDist(dist);
              final isCurrent = day == currentDay;

              return Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$day',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: isCurrent ? 16 : 12,
                              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w500,
                              color: baseColor.withValues(alpha: alpha),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: isCurrent ? 14 : 10,
                          height: isCurrent ? 3 : 2,
                          color: baseColor.withValues(alpha: alpha),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final alive = i < livesRemaining;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Icon(
            Icons.favorite,
            size: 24,
            color: alive ? Colors.redAccent : Colors.white.withValues(alpha: 0.25),
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

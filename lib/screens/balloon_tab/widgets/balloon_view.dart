import 'package:flutter/material.dart';
import 'dart:math';
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

class _BalloonGraphic extends StatefulWidget {
  const _BalloonGraphic();

  @override
  State<_BalloonGraphic> createState() => _BalloonGraphicState();
}


class _BalloonString extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 24,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9E9E9E).withValues(alpha: 0.9),
            const Color(0xFF616161).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
      // Optional: subtle sway using a repeating pulse
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(sin(value * 6.28) * 1.5, 0), // gentle horizontal sway
            child: child,
          );
        },
        child: Container(),
      ),
    );
  }
}


class _BalloonGraphicState extends State<_BalloonGraphic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Smooth sine-wave floating: ±8 pixels vertically
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _floatAnimation,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(0, _floatAnimation.value),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎈 3D Balloon body
            Container(
              width: 110,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // ✅ valid
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.8,
                  colors: const [
                    Color(0xFFFF6B6B),
                    Color(0xFFE53935),
                    Color(0xFFB71C1C),
                  ],
                  stops: const [0.2, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Glossy highlight — FIXED
                  Positioned(
                    top: 18,
                    left: 22,
                    child: Container(
                      width: 32,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20), // ✅ oval-like
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.45),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom shadow — FIXED
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Container(
                      width: 24,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // ✅ valid
                        color: Colors.black.withValues(alpha: 0.12),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            spreadRadius: 0.5,
                            color: Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 🪢 Knot
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 16,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // 🧵 String
            _BalloonString(),
            // 🧺 Basket
            CustomPaint(
              size: const Size(44, 32),
              painter: _BasketPainter3D(),
            ),
          ],
        ),
      );
    },
  );
}
}


class _BasketPainter3D extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Basket body (trapezoid with depth)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFF8D6E63), // Light brown
          Color(0xFF5D4037), // Mid brown
          Color(0xFF3E2723), // Dark brown shadow
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.15, 0)
      ..lineTo(size.width * 0.85, 0)
      ..lineTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.25, size.height)
      ..close();
    canvas.drawPath(path, bodyPaint);

    // Basket rim (top edge highlight)
    final rimPaint = Paint()
      ..color = const Color(0xFFA1887F).withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.85, 0),
      rimPaint,
    );

    // Subtle weave lines for texture
    final weavePaint = Paint()
      ..color = const Color(0xFF3E2723).withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(size.width * 0.2 + i * 2, y),
        Offset(size.width * 0.8 - i * 2, y),
        weavePaint,
      );
    }
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

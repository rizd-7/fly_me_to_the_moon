import 'package:flutter/material.dart';

import '../../../models/daily_status.dart';


/// Scrolling background - Creates the rising balloon illusion
/// As progress increases, the LONG background moves UP → balloon appears to rise
class _ScrollingBackground extends StatelessWidget {
  const _ScrollingBackground({
    required this.progressDays,
    required this.availableHeight,
  });

  final int progressDays;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    const imageWidth = 978.0;
    const imageHeight = 2798.0;

    final aspectRatio = imageHeight / imageWidth;
    final scaledImageHeight = screenWidth * aspectRatio;

    // Progress 0.0 → 1.0 (you can change 60 to 90 or 120 if you want slower/faster rise)
    final t = (progressDays / 60.0).clamp(0.0, 1.0);

    final maxScroll = scaledImageHeight - availableHeight;

    // === CORRECTED DIRECTION ===
    // We want the image to move UP as t increases
    // So we use negative offset and invert the logic
    final scrollOffset = t * maxScroll;

    // At t = 0, we want the BOTTOM of the image at the bottom of the screen
    final topOffset = availableHeight - scaledImageHeight + scrollOffset;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: topOffset,
          left: 0,
          width: screenWidth,
          height: scaledImageHeight,
          child: Image.asset(
            'assets/images/env.png',
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.blue.shade100,
                child: Center(
                  child: Text(
                    '⚠️ Image not found\nCheck: assets/images/env.png',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.22),
                ],
                stops: const [0.6, 0.85, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}




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
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        const rulerLeft = 8.0;
        const rulerWidth = 40.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Scrolling background - creates the rising effect
            _ScrollingBackground(
              progressDays: progressDays,
              availableHeight: availableHeight,
            ),

            // Day Ruler
            Positioned(
              left: rulerLeft,
              top: 72,
              bottom: 120,
              width: rulerWidth,
              child: _DayRuler(currentDay: progressDays),
            ),

            // Habit name + score at top
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
                  // Fixed: removed const from TextStyle because of .shade200
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

            // Balloon stays fixed in the center (this creates the rising illusion)
            const Center(
              child: _BalloonGraphic(),
            ),

            // Lives counter (top right)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              right: 16,
              child: _LivesRow(livesRemaining: livesRemaining),
            ),

            // Today's check/fail buttons
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
      },
    );
  }
}

// ==================== UNCHANGED PARTS ====================

class _DayRuler extends StatelessWidget {
  const _DayRuler({required this.currentDay});

  final int currentDay;
  static const int range = 2;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFE53935);
    final inactiveColor = Colors.grey.shade400;

    return Container(
      width: 55,
      padding: const EdgeInsets.only(right: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int clamped(int v) => (v < 0 ? 0 : v);
          final topToBottomDays = <int>[
            clamped(currentDay + range),
            clamped(currentDay + 1),
            currentDay,
            clamped(currentDay - 1),
            clamped(currentDay - range),
          ];

          return Stack(
            alignment: Alignment.centerRight,
            children: [
              Positioned(
                top: 10,
                bottom: 10,
                right: 2,
                child: Container(
                  width: 1.5,
                  color: inactiveColor.withValues(alpha: 0.2),
                ),
              ),
              Column(
                children: List.generate(topToBottomDays.length, (index) {
                  final day = topToBottomDays[index];
                  final isCurrent = day == currentDay;
                  final distance = (day - currentDay).abs();
                  final double opacity =
                      isCurrent ? 1.0 : (distance == 1 ? 0.6 : 0.3);

                  return Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: isCurrent ? 16 : 12,
                            fontWeight:
                                isCurrent ? FontWeight.w900 : FontWeight.w500,
                            color: (isCurrent ? activeColor : inactiveColor)
                                .withValues(alpha: opacity),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: isCurrent ? 12 : 6,
                          height: isCurrent ? 3 : 1.5,
                          decoration: BoxDecoration(
                            color: (isCurrent ? activeColor : inactiveColor)
                                .withValues(alpha: opacity),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
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

class _BalloonGraphicState extends State<_BalloonGraphic>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double offset =
            Curves.easeInOutSine.transform(_controller.value) * 12;
        return Transform.translate(
          offset: Offset(0, -offset),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.4),
                colors: [Color(0xFFFF7043), Color(0xFFE53935), Color(0xFFB71C1C)],
                stops: [0.1, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 30),
                ),
              ],
            ),
            child: Align(
              alignment: const Alignment(-0.4, -0.5),
              child: Container(
                width: 20,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -5),
            child: CustomPaint(
              size: const Size(80, 60),
              painter: _BalloonDetailsPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalloonDetailsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    final stringPaint = Paint()
      ..color = const Color(0xFF8D6E63).withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final basketPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;

    final knotPath = Path()
      ..moveTo(centerX - 8, 0)
      ..lineTo(centerX + 8, 0)
      ..lineTo(centerX + 4, 8)
      ..lineTo(centerX - 4, 8)
      ..close();
    canvas.drawPath(knotPath, Paint()..color = const Color(0xFFB71C1C));

    final stringPath = Path();
    stringPath.moveTo(centerX - 4, 4);
    stringPath.lineTo(size.width * 0.3, size.height * 0.7);
    stringPath.moveTo(centerX + 4, 4);
    stringPath.lineTo(size.width * 0.7, size.height * 0.7);
    canvas.drawPath(stringPath, stringPaint);

    final basketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.4,
        size.height * 0.3,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(basketRect, basketPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.7, size.width * 0.44, 3),
      Paint()..color = const Color(0xFF3E2723),
    );
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
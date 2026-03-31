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

  final int currentDay;
  static const int range = 2;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFE53935);
    final inactiveColor = Colors.grey.shade400;

    return Container(
      // Increase width slightly to prevent the 13px overflow
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
              // Background line
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
                  final double opacity = isCurrent ? 1.0 : (distance == 1 ? 0.6 : 0.3);

                  return Expanded(
                    child: Row(
                      // Use mainAxisSize min so it doesn't try to take up infinite space
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Day Number
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: isCurrent ? 16 : 12,
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w500,
                            color: (isCurrent ? activeColor : inactiveColor).withValues(alpha: opacity),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Tick Mark
                        Container(
                          width: isCurrent ? 12 : 6,
                          height: isCurrent ? 3 : 1.5,
                          decoration: BoxDecoration(
                            color: (isCurrent ? activeColor : inactiveColor).withValues(alpha: opacity),
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

class _BalloonGraphicState extends State<_BalloonGraphic> with SingleTickerProviderStateMixin {
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
        // Smooth floating Sine wave
        final double offset = Curves.easeInOutSine.transform(_controller.value) * 12;
        return Transform.translate(
          offset: Offset(0, -offset),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D Balloon Head
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
                  offset: const Offset(0, 30), // Shadow stays lower for depth
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
          // Connection & Basket
          Transform.translate(
            offset: const Offset(0, -5), // Pulls the strings UP to touch the balloon
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

    // 1. Draw the "Tie/Knot" at the bottom of the balloon
    final knotPath = Path()
      ..moveTo(centerX - 8, 0)
      ..lineTo(centerX + 8, 0)
      ..lineTo(centerX + 4, 8)
      ..lineTo(centerX - 4, 8)
      ..close();
    canvas.drawPath(knotPath, Paint()..color = const Color(0xFFB71C1C));

    // 2. Draw Strings (Starting from the knot)
    final stringPath = Path();
    // Left string
    stringPath.moveTo(centerX - 4, 4);
    stringPath.lineTo(size.width * 0.3, size.height * 0.7);
    // Right string
    stringPath.moveTo(centerX + 4, 4);
    stringPath.lineTo(size.width * 0.7, size.height * 0.7);
    canvas.drawPath(stringPath, stringPaint);

    // 3. Draw Basket
    final basketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.7, size.width * 0.4, size.height * 0.3),
      const Radius.circular(4),
    );
    
    canvas.drawRRect(basketRect, basketPaint);
    
    // Basket rim (detail)
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

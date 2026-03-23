import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/habit_controller.dart';
import 'widgets/habits_swiper.dart';

class BalloonTabScreen extends StatelessWidget {
  const BalloonTabScreen({super.key});

  Future<void> _showCreateAxeDialog(BuildContext context) async {
    final controller = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New axe'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'e.g. No sugary food',
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            onSubmitted: (_) => Navigator.of(ctx).pop(true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (created == true && context.mounted) {
      await context.read<HabitController>().addHabit(controller.text);
    }
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Kernetl'),
        actions: [
          IconButton(
            tooltip: 'New axe',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showCreateAxeDialog(context),
          ),
        ],
      ),
      body: Consumer<HabitController>(
        builder: (context, ctrl, _) {
          if (!ctrl.ready) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.habits.isEmpty) {
            return _EmptyAxeState(onCreate: () => _showCreateAxeDialog(context));
          }
          return const HabitsSwiper();
        },
      ),
    );
  }
}

class _EmptyAxeState extends StatelessWidget {
  const _EmptyAxeState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.air, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                'Create your first axe',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe between habits on the balloon screen. Data stays on this device (V01).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('New axe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

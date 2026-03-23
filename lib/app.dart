import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/json_habit_store.dart';
import 'screens/balloon_tab/balloon_tab_screen.dart';
import 'screens/online_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'state/habit_controller.dart';

class KernetlApp extends StatelessWidget {
  const KernetlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitController(JsonHabitStore()),
      child: MaterialApp(
        title: 'Kernetl',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90D9),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const _LifecycleWrapper(child: _MainShell()),
      ),
    );
  }
}

class _LifecycleWrapper extends StatefulWidget {
  const _LifecycleWrapper({required this.child});

  final Widget child;

  @override
  State<_LifecycleWrapper> createState() => _LifecycleWrapperState();
}

class _LifecycleWrapperState extends State<_LifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HabitController>().init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<HabitController>().refreshFromClock();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _navIndex,
        children: const [
          BalloonTabScreen(),
          ProfileScreen(),
          SettingsScreen(),
          OnlineScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.air),
            label: 'Balloon',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            label: 'Online',
          ),
        ],
      ),
    );
  }
}

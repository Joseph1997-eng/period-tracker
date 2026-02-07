import 'package:flutter/material.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../cycle/presentation/screens/analytics_screen.dart';
import '../../../cycle/presentation/screens/cycle_tracker_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    CycleTrackerScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  static const List<String> _titles = <String>[
    'Dashboard',
    'Cycle Tracker',
    'Analytics',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Track',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

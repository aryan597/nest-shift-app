import 'package:go_router/go_router.dart';
import '../../presentation/screens/welcome_screen.dart';
import '../../presentation/screens/pairing_screen.dart';
import '../../presentation/screens/home_dashboard.dart';
import '../../presentation/screens/room_screen.dart';
import '../../presentation/screens/device_screen.dart';
import '../../presentation/screens/energy_dashboard.dart';
import '../../presentation/screens/ai_assistant_screen.dart';
import '../../presentation/screens/main_navigation_shell.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/automation_screen.dart';
import 'package:flutter/material.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/pairing',
      builder: (context, state) => const PairingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainNavigationShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const HomeDashboard(),
        ),
        GoRoute(
          path: '/automations',
          builder: (context, state) => const AutomationScreen(),
        ),
        GoRoute(
          path: '/energy',
          builder: (context, state) => const EnergyDashboard(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/room/:id',
      builder: (context, state) => RoomScreen(roomId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/device/:id',
      builder: (context, state) => DeviceScreen(deviceId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => const AiAssistantScreen(),
    ),
  ],
);

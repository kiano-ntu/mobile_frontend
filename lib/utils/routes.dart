// File: lib/config/routes.dart

import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/dashboards/pembeli_dashboard.dart';
import '../screens/dashboards/penitip_dashboard.dart';
import '../screens/dashboards/kurir_dashboard.dart';
import '../screens/dashboards/hunter_dashboard.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String pembeliDashboard = '/pembeli-dashboard';
  static const String penitipDashboard = '/penitip-dashboard';
  static const String kurirDashboard = '/kurir-dashboard';
  static const String hunterDashboard = '/hunter-dashboard';

  // Static Routes Map
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        home: (context) => const HomeScreen(),
        login: (context) => const LoginScreen(),
        pembeliDashboard: (context) => const PembeliDashboard(),
        penitipDashboard: (context) => const PenitipDashboard(),
        kurirDashboard: (context) => const KurirDashboard(),
        hunterDashboard: (context) => const HunterDashboard(),
      };

  // Dynamic Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );

      case pembeliDashboard:
        return MaterialPageRoute(
          builder: (context) => const PembeliDashboard(),
          settings: settings,
        );

      case penitipDashboard:
        return MaterialPageRoute(
          builder: (context) => const PenitipDashboard(),
          settings: settings,
        );

      case kurirDashboard:
        return MaterialPageRoute(
          builder: (context) => const KurirDashboard(),
          settings: settings,
        );

      case hunterDashboard:
        return MaterialPageRoute(
          builder: (context) => const HunterDashboard(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

// 404 Screen untuk route yang tidak ditemukan
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Tidak Ditemukan'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Halaman tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

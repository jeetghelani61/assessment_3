// main.dart
import 'package:ass_3/screens/dashboard_screen.dart';
import 'package:ass_3/screens/login_screen.dart';
import 'package:ass_3/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(
    isFirstLaunch: isFirstLaunch,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isFirstLaunch,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventBuzz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.lightBlueAccent,
        appBarTheme: const AppBarTheme(color: Colors.redAccent),
      ),
      themeMode: ThemeMode.system,
      home: isFirstLaunch
          ? const WelcomeScreen()
          : isLoggedIn
          ? const DashboardScreen()
          : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
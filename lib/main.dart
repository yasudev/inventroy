import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppUser? _user;

  void _onLogin(AppUser user) {
    setState(() => _user = user);
  }

  void _onLogout() {
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _user == null
          ? LoginScreen(onLogin: _onLogin)
          : HomeScreen(user: _user!, onLogout: _onLogout),
    );
  }
}

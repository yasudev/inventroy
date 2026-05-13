import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'models/user_model.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';
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
  final _localeProvider = LocaleProvider();

  void _onLogin(AppUser user) {
    setState(() => _user = user);
  }

  void _onLogout() {
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Inventory App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: _localeProvider.locale,
          supportedLocales: const [Locale('en'), Locale('am')],
          localizationsDelegates: [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: _user == null
              ? LoginScreen(onLogin: _onLogin)
              : HomeScreen(user: _user!, onLogout: _onLogout, localeProvider: _localeProvider),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'models/user_model.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard/home_screen.dart';
import 'services/database_helper.dart';
import 'providers/inventory_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await DatabaseHelper().init();
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
  final _inventoryProvider = InventoryProvider();
  static const _apiUrl = 'http://localhost:8080';
  void _onLogin(AppUser user) {
    _inventoryProvider.init(
      apiUrl: _apiUrl,
      userId: user.id ?? 0,
      token: '${user.username}_${DateTime.now().millisecondsSinceEpoch}',
    );
    _inventoryProvider.refresh();
    setState(() => _user = user);
  }

  void _onLogout() {
    setState(() => _user = null);
  }

  @override
  void dispose() {
    _inventoryProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeProvider,
      builder: (context, _) {
        return ChangeNotifierProvider.value(
          value: _inventoryProvider,
          child: MaterialApp(
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
          ),
        );
      },
    );
  }
}

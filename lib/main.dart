import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temp_jobs/widget/animated_job_background.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _settings = SettingsProvider();

  @override
  void initState() {
    super.initState();
    _settings.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: _settings),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Ocupa2',

  themeMode: settings.themeMode,

  theme: ThemeData(
    colorSchemeSeed: Colors.teal,
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor:
        Colors.transparent,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
  ),

  darkTheme: ThemeData(
    colorSchemeSeed: Colors.teal,
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor:
        Colors.transparent,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
  ),

  builder: (context, child) {
    final mediaQuery =
        MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(
          settings.fontScale,
        ),
      ),

      child: AnimatedJobBackground(
        child: child!,
      ),
    );
  },

  home: const AuthGate(),
);
        },
      ),
    );
  }
}

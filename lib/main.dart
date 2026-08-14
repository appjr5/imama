import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/theme_controller.dart';
import 'theme/app_theme.dart';
import 'theme/strings_sw.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const IMamaApp(),
    ),
  );
}

class IMamaApp extends StatelessWidget {
  const IMamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    return MaterialApp(
      title: StringsSw.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: themeController.mode,
      home: const SplashScreen(),
    );
  }
}

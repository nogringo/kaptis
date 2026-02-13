import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const AboulApp());
}

class AboulApp extends StatelessWidget {
  const AboulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Aboul'",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF234d3f),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.light.primaryBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.light.appBarBackground,
          foregroundColor: AppColors.light.appBarForeground,
          elevation: 0,
        ),
        extensions: const [AppColors.light],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF234d3f),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.dark.primaryBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.dark.appBarBackground,
          foregroundColor: AppColors.dark.appBarForeground,
          elevation: 0,
        ),
        extensions: const [AppColors.dark],
      ),
      home: const HomeScreen(),
    );
  }
}

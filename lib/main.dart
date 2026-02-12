import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      // themeMode: kDebugMode ? ThemeMode.dark : null,
      home: const HomeScreen(),
    );
  }
}

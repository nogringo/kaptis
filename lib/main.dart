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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const HomeScreen(),
    );
  }
}

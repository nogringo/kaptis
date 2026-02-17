import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/preferences_service.dart';
import 'theme/app_colors.dart';

// TODO par defaut IA
// TODO les selections doivent rester en mémoire
// TODO Utiliser les mots de blobrain

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.init();
  runApp(const KaptisApp());
}

class KaptisApp extends StatelessWidget {
  const KaptisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kaptis",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF234d3f),
          brightness: Brightness.light,
        ),
        extensions: const [AppColors.light],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF234d3f),
          brightness: Brightness.dark,
        ),
        extensions: const [AppColors.dark],
      ),
      themeMode: kDebugMode ? ThemeMode.dark : null,
      home: const HomeScreen(),
    );
  }
}

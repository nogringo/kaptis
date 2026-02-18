import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/online_lobby_screen.dart';
import 'services/deep_link_service.dart';
import 'services/preferences_service.dart';
import 'theme/app_colors.dart';

// TODO Noyau par defaut
// TODO les selections doivent rester en mémoire
// TODO Utiliser les mots de blobrain
// TODO Migrer vers Riverpod pour une meilleure gestion du state et de l'init async des services

final deepLinkService = DeepLinkService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.init();
  runApp(const KaptisApp());
}

class KaptisApp extends StatefulWidget {
  const KaptisApp({super.key});

  @override
  State<KaptisApp> createState() => _KaptisAppState();
}

class _KaptisAppState extends State<KaptisApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    await deepLinkService.init();
    _deepLinkSubscription = deepLinkService.onRoomCode.listen(_onRoomCode);
  }

  void _onRoomCode(String code) {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) =>
            OnlineLobbyScreen(mode: LobbyMode.join, initialCode: code),
      ),
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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

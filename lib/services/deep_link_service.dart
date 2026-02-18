import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static const String baseUrl = 'https://aboul-cbc38--online2-r8nhkyg4.web.app';

  final AppLinks _appLinks = AppLinks();
  final _roomCodeController = StreamController<String>.broadcast();

  Stream<String> get onRoomCode => _roomCodeController.stream;

  StreamSubscription<Uri>? _linkSubscription;

  Future<void> init() async {
    // Check initial link (app opened via link)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLink(initialLink);
    }

    // Listen for links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleLink);
  }

  void _handleLink(Uri uri) {
    // Parse /join/{code} from the URL
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'join') {
      final code = segments[1].toUpperCase();
      if (code.length == 6) {
        _roomCodeController.add(code);
      }
    }
  }

  String generateShareLink(String roomCode) {
    return '$baseUrl/join/$roomCode';
  }

  void dispose() {
    _linkSubscription?.cancel();
    _roomCodeController.close();
  }
}

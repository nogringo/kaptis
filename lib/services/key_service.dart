import 'dart:math';
import 'package:ndk/shared/nips/nip19/nip19.dart';
import 'nostr_service.dart';

class KeyService {
  /// Get public key hex
  static Future<String> getPublicKey() async {
    return await NostrService().getPublicKey();
  }

  /// Get public key in npub format
  static Future<String> getNpub() async {
    final publicKey = await getPublicKey();
    return Nip19.encodePubKey(publicKey);
  }

  /// Generate a unique room code (6 characters, alphanumeric)
  static String generateRoomCode() {
    const chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excluding confusing chars
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

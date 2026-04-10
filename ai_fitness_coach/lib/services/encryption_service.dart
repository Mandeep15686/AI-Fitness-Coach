import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class EncryptionService {
  final _storage = const FlutterSecureStorage();
  static const _keyIdentifier = 'encryption_key';

  late final Encrypter _encrypter;
  late final IV _iv;

  Future<void> init() async {
    final keyString = await _getOrCreateKey();
    final key = Key.fromBase64(keyString);
    _iv = IV.fromLength(16); // AES block size is 16 bytes
    _encrypter = Encrypter(AES(key));
  }

  Future<String> _getOrCreateKey() async {
    String? key = await _storage.read(key: _keyIdentifier);
    if (key == null) {
      final newKey = _generateSecureKey();
      await _storage.write(key: _keyIdentifier, value: newKey);
      return newKey;
    } 
    return key;
  }

  String _generateSecureKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(keyBytes);
  }

  String encrypt(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}

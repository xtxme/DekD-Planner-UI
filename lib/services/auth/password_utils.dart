import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

// ฟังก์ชัน hash + salt
String generateSalt({int length = 16}) {
  final random = Random.secure();
  final bytes = List<int>.generate(length, (_) => random.nextInt(256));
  return base64UrlEncode(bytes);
}

String hashPassword(String password, String salt) {
  final bytes = utf8.encode('$password:$salt');
  return sha256.convert(bytes).toString();
}

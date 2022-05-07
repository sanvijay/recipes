import 'package:http/http.dart';
import 'dart:convert';

// Import Services
import 'package:recipes/services/auth/auth.dart';

class AuthController {
  Future<void> signOut(String? token) async {
    Auth auth = Auth();

    if (token == null) { return; }
    Uri uri = Uri.parse('http://192.168.0.102:3000/oauth/authorize');
    Response response = await delete(uri, headers: { 'Authorization': 'Bearer $token' });
    auth.signOut();
  }
}

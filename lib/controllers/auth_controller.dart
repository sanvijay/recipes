import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import Services
import 'package:recipes/services/auth_service.dart';

class AuthController {
  Future<void> signOut(String? token) async {
    AuthService auth = AuthService();

    if (token == null) { return; }
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/oauth/authorize');
    Response response = await delete(uri, headers: { 'Authorization': 'Bearer $token' });
    auth.signOut();
  }
}

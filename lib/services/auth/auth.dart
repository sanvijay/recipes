import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  Future<bool> isLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    return token != null;
  }

  Future<String?> accessToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    return token;
  }

  Future<void> setAuthDetails(String accessToken, String refreshToken) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('auth:access_token', accessToken);
    await pref.setString('auth:refresh_token', refreshToken);

    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    await pref.setString('user:email', decodedToken['user']['email']);
    await pref.setInt('user:id', decodedToken['user']['id']);
  }

  Future<void> signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('auth:access_token');
    await pref.remove('auth:refresh_token');
    await pref.remove('user:email');
    await pref.remove('user:id');
  }
}

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
}

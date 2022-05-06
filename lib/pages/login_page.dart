import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;

  void login(String email, String password) async {
    var response = await post(Uri.parse('http://192.168.0.102:3000/oauth/token'), body: {
      "email": email,
      "password": password,
      "grant_type": "password",
      "client_id": "M6UgtxJaOaH7k7LWMCzHHcFyU9jds8D0NuLhGwFIpJw",
      "client_secret": "65YNBsr1MqqqYCBg-LE1_W0daHqeSvwcagZRkw2wIUU"
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      pageRoute(body['access_token'], body['refresh_token']);
    }
    else {
      ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Invalid Credentials")));
    }
  }

  void pageRoute(String accessToken, String refreshToken) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('auth:access_token', accessToken);
    await pref.setString('auth:refresh_token', refreshToken);

    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    print(decodedToken['user']['email']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/login_bg.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(),
            Container(
              padding: const EdgeInsets.only(left: 35, top: 80),
              child: const Text(
                'Welcome\nBack',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.black),
                            onChanged: (email) {
                              this.email = email;
                            },
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          const SizedBox(height: 30,),
                          TextField(
                            style: const TextStyle(),
                            obscureText: true,
                            onChanged: (password) {
                              this.password = password;
                            },
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),
                          const SizedBox(height: 40,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xff4c505b),
                                child: IconButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      if (email == null || email == '' || password == null || password == '') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(content: Text("Please enter email and password")));
                                        return;
                                      }
                                      login(email!, password!);
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                    )),
                              )
                            ],
                          ),
                          const SizedBox(height: 40,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: const Text(
                                  'Sign Up',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.white,
                                    fontSize: 18),
                                ),
                                style: const ButtonStyle(),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                )
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

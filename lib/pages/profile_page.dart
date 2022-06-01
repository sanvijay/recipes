import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? token;

  TextEditingController firstNameTxtCntl = TextEditingController();
  TextEditingController lastNameTxtCntl = TextEditingController();

  void setUserDetails(String firstName, String lastName) async {
    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString('auth:access_token');

    try {
      String url = '${dotenv.env['API_URL']}/user/update';
      Uri baseUri = Uri.parse(url);
      Uri uri = baseUri.replace(queryParameters: {
        'first_name': firstName,
        'last_name': lastName,
      });
      Response response =
          await post(uri, headers: {
            'Authorization': 'Bearer $token',
            'Content-type': 'application/json'
          });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Updated Successfully!")));

      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Some error occurred! Please try again later!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Some error occurred! Please try again later!")));
    }
  }

  void getUserDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString('auth:access_token');
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/user/current');
    Response response = await get(uri, headers: { 'Authorization': 'Bearer $token' });

    Map data = jsonDecode(response.body);

    firstNameTxtCntl.text = data["first_name"];
    lastNameTxtCntl.text = data["last_name"];
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              // Center(
              //   child: Stack(
              //     children: [
              //       Container(
              //         width: 130,
              //         height: 130,
              //         decoration: BoxDecoration(
              //           border: Border.all(
              //             width: 4,
              //             color: Theme.of(context).scaffoldBackgroundColor),
              //           boxShadow: [
              //             BoxShadow(
              //               spreadRadius: 2,
              //               blurRadius: 10,
              //               color: Colors.black.withOpacity(0.1),
              //               offset: const Offset(0, 10))
              //           ],
              //           shape: BoxShape.circle,
              //           image: const DecorationImage(
              //             fit: BoxFit.cover,
              //             image: NetworkImage(
              //               "https://images.pexels.com/photos/3307758/pexels-photo-3307758.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=250",
              //             )
              //           )
              //         ),
              //       ),
              //       Positioned(
              //         bottom: 0,
              //         right: 0,
              //         child: Container(
              //           height: 40,
              //           width: 40,
              //           decoration: BoxDecoration(
              //             shape: BoxShape.circle,
              //             border: Border.all(
              //               width: 4,
              //               color: Theme.of(context).scaffoldBackgroundColor,
              //             ),
              //             color: Colors.redAccent,
              //           ),
              //           child: const Icon(
              //             Icons.edit,
              //             color: Colors.white,
              //           ),
              //         )
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(
                height: 35,
              ),
              buildTextField("First Name", firstNameTxtCntl),
              buildTextField("Last Name", lastNameTxtCntl),
              const SizedBox(
                height: 35,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setUserDetails(firstNameTxtCntl.text, lastNameTxtCntl.text);
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        obscureText: false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )
        ),
      ),
    );
  }
}

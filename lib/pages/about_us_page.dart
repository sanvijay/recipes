import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

// Import Components
import 'package:recipes/components/bottom_navigator.dart';
import 'package:recipes/components/left_drawer.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const LeftDrawer(),
        appBar: AppBar(
          title: const Text('About Us'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
          child: Column(
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Ku-Ky is created by a team of two who are more of intersted in cooking. Our goal is that anyone can cook with simple and easy steps.",
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "We are providing multiple features to make cooking easy. Do provide your support.",
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Provide your queries and suggestions in the feedback section.",
                ),
              ),
            ]
          ),
        )
    );
  }
}

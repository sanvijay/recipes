import 'package:flutter/material.dart';

// Import components
import 'package:recipes/components/login_message.dart';

// Import services
import 'package:recipes/services/auth/auth.dart';

// Import models
import 'package:recipes/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewRecipePage extends StatefulWidget {
  const AddNewRecipePage({Key? key}) : super(key: key);

  @override
  State<AddNewRecipePage> createState() => _AddNewRecipePageState();
}

class _AddNewRecipePageState extends State<AddNewRecipePage> {
  List<String> fields = ['title', 'description', 'image_url'];
  Map values = {};
  Map errors = {};
  bool isLoggedIn = false;

  void setLoggedInDetails()async {
    Auth auth = Auth();
    isLoggedIn = await auth.isLoggedIn();

    setState(() {
      isLoggedIn = isLoggedIn;
    });
  }

  @override
  void initState() {
    super.initState();
    setLoggedInDetails();
  }

  void validateAndSaveData() async {
    errors = {};
    for(int i = 0; i < fields.length; i++) {
      if (values[fields[i]] == null || values[fields[i]] == '') {
        setState(() {
          errors[fields[i]] = "This field is required";
        });
      }
    }

    if (errors.isNotEmpty) { return; }

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("You need to login")));
      return;
    }

    Recipe newRecipe = Recipe(slug: '');
    newRecipe.assignValues(
      values['description'],
      values['title'],
      values['image_url']
    );

    newRecipe.saveToCloud(token);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Recipe'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: !isLoggedIn ? LoginMessage() : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                onChanged: (text) {
                  setState(() { errors['title'] = null; });
                  values['title'] = text;
                },
                maxLines: 2,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter title',
                  errorText: errors['title'],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                onChanged: (text) {
                  setState(() { errors['description'] = null; });
                  values['description'] = text;
                },
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter description',
                  errorText: errors['description'],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                onChanged: (text) {
                  setState(() { errors['image_url'] = null; });
                  values['image_url'] = text;
                },
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Image Url',
                  errorText: errors['image_url'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  validateAndSaveData();
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      )
    );
  }
}

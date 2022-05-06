import 'package:flutter/material.dart';

// Import services
import 'package:recipes/services/recipes/all_recipes.dart';

// Import models
import 'package:recipes/models/recipe.dart';

class AddNewRecipePage extends StatefulWidget {
  const AddNewRecipePage({Key? key}) : super(key: key);

  @override
  State<AddNewRecipePage> createState() => _AddNewRecipePageState();
}

class _AddNewRecipePageState extends State<AddNewRecipePage> {
  List<String> fields = ['title', 'description', 'image_url'];
  Map values = {};
  Map errors = {};

  void validateAndSaveData() {
    errors = {};
    for(int i = 0; i < fields.length; i++) {
      if (values[fields[i]] == null || values[fields[i]] == '') {
        setState(() {
          errors[fields[i]] = "This field is required";
        });
      }
    }

    if (errors.isNotEmpty) { return; }

    Recipe newRecipe = Recipe(slug: '');
    newRecipe.assignValues(
      values['description'],
      values['title'],
      values['image_url']
    );

    newRecipe.saveToCloud();
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
      body: SingleChildScrollView(
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

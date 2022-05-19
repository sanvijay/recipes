import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import models
import 'package:recipes/models/recipe.dart';

class PlayRecipePage extends StatefulWidget {
  const PlayRecipePage({Key? key}) : super(key: key);

  @override
  _PlayRecipePageState createState() => _PlayRecipePageState();
}

class _PlayRecipePageState extends State<PlayRecipePage> {
  Recipe? recipe;

  @override
  void initState() {
    super.initState();
  }

  getRecipeDetails(String slug, { bool force = false }) async {
    if (recipe != null && !force) return;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    recipe = Recipe(slug: slug);
    await recipe?.setDetails(token);
    setState(() {
      recipe = recipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)?.settings.arguments as Map;
    getRecipeDetails(args['slug']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(
          color: Colors.black,
        ),
      ),
      body: const SingleChildScrollView(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: 'previous',
            onPressed: () {/* Do something */},
            child: const Icon(
              Icons.arrow_left,
              size: 40,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FloatingActionButton(
            heroTag: 'action',
            onPressed: () {/* Do something */},
            child: const Icon(
              Icons.play_arrow,
              size: 40,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FloatingActionButton(
            heroTag: 'next',
            onPressed: () {/* Do something */},
            child: const Icon(
              Icons.arrow_right,
              size: 40,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      )
    );
  }
}

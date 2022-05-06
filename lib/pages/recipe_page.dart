import 'package:flutter/material.dart';

// Import models
import 'package:recipes/models/recipe.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Map data = {};
  Recipe? recipe;

  getRecipeDetails(String slug) async {
    if (recipe != null) return;

    recipe = Recipe(slug: slug);
    await recipe?.setDetails();
    setState(() {
      recipe = recipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings?.arguments as Map;
    getRecipeDetails(data['slug']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          GestureDetector(
            child: Icon(Icons.favorite_border),
            onTap: () {

            },
          ),
          const SizedBox(width: 20.0,),
          GestureDetector(
            child: Icon(Icons.share),
            onTap: () {

            },
          ),
          const SizedBox(width: 30.0,),
        ],
      ),
      body: recipe?.title == null ?
        const Center(child: Text("Loading...")) :
        SingleChildScrollView(child: RecipeDetails(recipe: recipe))
    );
  }
}

class RecipeDetails extends StatelessWidget {
  const RecipeDetails({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.network(
          recipe?.imageUrl as String,
          fit: BoxFit.fitWidth,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                recipe?.title as String,
                style: const TextStyle(
                  fontSize: 28.0,
                  letterSpacing: 2.0
                ),
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(recipe?.description as String),
        ),
        const Divider(
          thickness: 2.0,
        ),
      ],
    );
  }
}

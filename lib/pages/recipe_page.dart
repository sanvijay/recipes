import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import models
import 'package:recipes/models/recipe.dart';

// Import controllers
import '../controllers/recipes_controller.dart';

// Import Services
import 'package:recipes/services/auth/auth.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Map data = {};
  Recipe? recipe;
  Map currentUser = {};

  getRecipeDetails(String slug) async {
    if (recipe != null) return;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    recipe = Recipe(slug: slug);
    await recipe?.setDetails(token);
    setState(() {
      recipe = recipe;
    });
  }

  void setCurrentUser() async {
    Auth auth = Auth();
    currentUser = await auth.currentUserDetails();
    setState(() {
      currentUser = currentUser;
    });
  }

  @override
  void initState() {
    super.initState();
    setCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments as Map;
    getRecipeDetails(data['slug']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          recipe != null && currentUser.isNotEmpty && recipe!.authorId == currentUser['userId'] ? GestureDetector(
            child: const Icon(Icons.edit),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add-edit-recipe',
                arguments: { 'slug': recipe?.slug }
              );
            },
          ) : const SizedBox.shrink(),
          const SizedBox(width: 20.0,),
          GestureDetector(
            child: recipe != null && recipe!.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
            onTap: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              String? token = pref.getString('auth:access_token');

              if (token == null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("You need to login")));
                return;
              }

              RecipesController recipesController = RecipesController();
              Recipe updatedRecipe = await recipesController.setFavorite(recipe!, !recipe!.isFavorite, token);
              setState(() {
                recipe = updatedRecipe;
              });
            },
          ),
          const SizedBox(width: 20.0,),
          GestureDetector(
            child: const Icon(Icons.share),
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
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            recipe?.title as String,
            style: const TextStyle(
              fontSize: 28.0,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(recipe?.description as String),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text((recipe?.durationInMin.toString() as String) + ' minutes'),
            ),
          ],
        ),
        const Divider(
          thickness: 2.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            'Ingredients',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        const Divider(
          thickness: 2.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            'Directions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

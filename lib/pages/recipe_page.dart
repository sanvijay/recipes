import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import models
import 'package:recipes/models/recipe.dart';

// Import controllers
import '../controllers/recipes_controller.dart';

// Import Services
import 'package:recipes/services/auth_service.dart';
import 'package:recipes/services/share_service.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Map data = {};
  Recipe? recipe;
  Map currentUser = {};

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

  void setCurrentUser() async {
    AuthService auth = AuthService();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("New feature coming soon!")));
          // Navigator.pushNamed(
          //   context,
          //   '/play-recipe',
          //   arguments: { 'slug': recipe!.slug },
          // );
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(recipe?.title ?? ''),
        centerTitle: true,
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
              bool sameUser = currentUser.isNotEmpty && recipe!.authorId == currentUser['userId'];
              String appUrl = 'https://play.google.com/store/apps/details?id=com.fireflies.kuky';

              String shareText = sameUser ? '${recipe!.title}\n\nThis is my recipe available in Ku-Ky app.\n\n$appUrl' : '${recipe!.title}\n\nI found this recipe on Ku-Ky.\n\n$appUrl';

              ShareService shareService = ShareService();
              shareService.share(recipe?.imageUrl ?? '', shareText);
            },
          ),
          const SizedBox(width: 30.0,),
        ],
      ),
      body: recipe?.title == null ?
        const Center(child: Text("Loading...")) :
        RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            getRecipeDetails(data['slug'], force: true);
          },
          child: SingleChildScrollView(child: RecipeDetails(recipe: recipe))
        )
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
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
          height: 300,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            recipe?.title as String,
            style: const TextStyle(
              fontSize: 28.0,
              letterSpacing: 2.0,
            ),
            textAlign: TextAlign.center,
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
            'Added By',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text((recipe?.authorFirstName ?? '')[0].toUpperCase() + (recipe?.authorLastName ?? '')[0].toUpperCase(), style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
              ),
              Text((recipe?.authorFirstName ?? '') + ' ' + (recipe?.authorLastName ?? ''))
            ],
          ),
        ),
        const Divider(
          thickness: 2.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              Row(
                children: [
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 10.0),
                  //   child: Text(
                  //     '-',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.black,
                  //     ),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      '${recipe?.servings ?? ''} Servings',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 10.0),
                  //   child: Text(
                  //     '+',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.black,
                  //     ),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // ),
                ],
              )
            ],
          )
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          child: Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(4.0),
              1: FlexColumnWidth(1.0),
              2: FlexColumnWidth(1.0),
            },
            children: recipe!.ingredients!.map((ing) => ingredientTableRow(ing)).toList(),
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
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recipe!.instructions!.map((ins) => instructionStep(ins)).toList(),
          ),
        ),
        const SizedBox(height: 60.0,)
      ],
    );
  }

  TableRow ingredientTableRow(Map ingredient) {
    return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Text(ingredient['title'], textAlign: TextAlign.left,),
          ),
          Text(ingredient['quantity'].toString(), textAlign: TextAlign.left,),
          Text(ingredient['unit'], textAlign: TextAlign.left,),
        ]
    );
  }

  Widget instructionStep(Map instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("Step ${instruction['order'] + 1}: ${instruction['value']}", textAlign: TextAlign.left,),
    );
  }
}

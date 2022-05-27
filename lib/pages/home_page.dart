import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import controllers
import 'package:recipes/controllers/recipes_controller.dart';

// Import models
import 'package:recipes/models/recipe.dart';

// Import components
import 'package:recipes/components/recipe_card.dart';
import 'package:recipes/components/bottom_navigator.dart';
import 'package:recipes/components/left_drawer.dart';

// Import Services
import 'package:recipes/services/auth_service.dart';
import 'package:recipes/services/share_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Recipe> allRecipes = [];
  RecipesController recipesController = RecipesController();
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool loadMorePage = true;

  AuthService auth = AuthService();
  Future<void> getAllRecipes(page) async {

    String? token = await auth.accessToken();
    await recipesController.getData(page, token ?? '');
    List<Recipe> allRecipes = recipesController.list;
    setState(() {
      this.allRecipes = allRecipes;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllRecipes(_page);

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (loadMorePage) {
          int oldListCount = allRecipes.length;
          await getAllRecipes(++_page);
          int newListCount = allRecipes.length;

          if (oldListCount == newListCount) {
            loadMorePage = false;
          }
        }
      }
    });
  }

  Widget recipeCardBuilder(MapEntry e) {
    return RecipeCard(
      recipe: e.value,
      share: () async {
        Map currentUser = await auth.currentUserDetails();
        bool sameUser = currentUser.isNotEmpty && e.value!.authorId == currentUser['userId'];
        String appUrl = 'https://play.google.com/store/apps/details?id=com.fireflies.kuky';

        String shareText = sameUser ? '${e.value!.title}\n\nThis is my recipe available in Ku-Ky app.\n\n$appUrl' : '${e.value!.title}\n\nI found this recipe on Ku-Ky.\n\n$appUrl';

        ShareService shareService = ShareService();
        shareService.share(e.value?.imageUrl ?? '', shareText);
      },
      setFavorite: () async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        String? token = pref.getString('auth:access_token');

        if (token == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("You need to login")));
          return;
        }

        RecipesController recipesController = RecipesController();
        Recipe updatedRecipe = await recipesController.setFavorite(e.value, !e.value.isFavorite, token);
        setState(() {
          allRecipes[e.key] = updatedRecipe;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(currentIndex: 0,),
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: allRecipes.isEmpty ?
        const Center(child: Text("Loading...")) :
        ListView(
          controller: _scrollController,
          children: [
            ...allRecipes.asMap().entries.map((recipeEntry) => recipeCardBuilder(recipeEntry)).toList(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: loadMorePage ? const Text("Cooking more recipes...", textAlign: TextAlign.center,) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You reached the end. Do you want to add your magic recipe?'),
                  TextButton(
                      onPressed: () { Navigator.pushNamed(context, '/add-edit-recipe', arguments: {}); },
                      child: const Text(
                        'Add your recipe',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                        ),
                      )
                  ),
                ],
              ),
            )
          ],
        )
    );
  }
}

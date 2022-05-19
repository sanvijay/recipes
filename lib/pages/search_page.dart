import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Components
import 'package:recipes/components/bottom_navigator.dart';
import 'package:recipes/components/left_drawer.dart';
import 'package:recipes/components/recipe_card.dart';

// Import Controllers
import 'package:recipes/controllers/recipes_controller.dart';

// Import Models
import 'package:recipes/models/recipe.dart';

// Import Services
import 'package:recipes/services/auth_service.dart';
import 'package:recipes/services/share_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showAdvancedInput = false;
  RecipesController recipesController = RecipesController();
  List<Recipe> searchResults = [];
  AuthService auth = AuthService();

  TextEditingController recipeTitleTxtCntl = TextEditingController();
  TextEditingController recipeIngredientTxtCntl = TextEditingController();
  TextEditingController recipeDurationTxtCntl = TextEditingController();

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
            searchResults[e.key] = updatedRecipe;
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const BottomNavigator(currentIndex: 1,),
        drawer: const LeftDrawer(),
        appBar: AppBar(
          title: const Text('Search'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                child: TextField(
                  controller: recipeTitleTxtCntl,
                  onChanged: (text) {},
                  maxLines: 2,
                  autofocus: true,
                  maxLength: 96,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Search by keywords',
                    counterText: '',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    showAdvancedInput = !showAdvancedInput;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Cook with what I have',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                )
              ),
              showAdvancedInput ? Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: TextField(
                  controller: recipeIngredientTxtCntl,
                  onChanged: (text) {},
                  maxLines: 2,
                  autofocus: true,
                  maxLength: 96,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Search by ingredients. Type comma separated.',
                    counterText: '',
                  ),
                ),
              ) : const SizedBox.shrink(),
              showAdvancedInput ? Padding(
                padding: const EdgeInsets.fromLTRB(8, 1, 8, 8),
                child: TextField(
                  controller: recipeDurationTxtCntl,
                  keyboardType: TextInputType.number,
                  onChanged: (text) {},
                  autofocus: true,
                  maxLength: 96,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Maximum time you have (in min).',
                    counterText: '',
                  ),
                ),
              ) : const SizedBox.shrink(),
              ElevatedButton(
                onPressed: () async {
                  searchResults = await recipesController.searchRecipe(
                    1,
                    title: recipeTitleTxtCntl.text,
                    ingredients: recipeIngredientTxtCntl.text,
                    durationInMinutes: recipeDurationTxtCntl.text
                  );

                  setState(() {
                    searchResults = searchResults;
                  });
                },
                child: const Text('Search'),
              ),
              ...searchResults.asMap().entries.map((recipeEntry) => recipeCardBuilder(recipeEntry)).toList()
            ]
          ),
        )
    );
  }
}

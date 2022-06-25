import 'package:flutter/material.dart';
import 'package:recipes/components/login_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import controllers
import 'package:recipes/controllers/recipes_controller.dart';

// Import services
import 'package:recipes/services/auth_service.dart';
import 'package:recipes/services/share_service.dart';

// Import models
import 'package:recipes/models/recipe.dart';

// Import components
import 'package:recipes/components/recipe_card.dart';
import 'package:recipes/components/bottom_navigator.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with TickerProviderStateMixin {
  List<Recipe> allCreatedRecipes = [];
  List<Recipe> allFavoriteRecipes = [];
  RecipesController recipesController = RecipesController();
  AuthService auth = AuthService();

  final ScrollController _createdScrollController = ScrollController();
  final ScrollController _favoriteScrollController = ScrollController();

  int _createdPage = 1;
  int _favoritePage = 1;

  bool createdLoadMorePage = true;
  bool favoriteLoadMorePage = true;

  late TabController _tabController;

  bool isLoading = true;
  bool isLoggedIn = false;

  void setLoggedInDetails()async {
    isLoggedIn = await auth.isLoggedIn();

    setState(() {
      isLoggedIn = isLoggedIn;
    });
  }

  Future<void> getAllCreatedRecipes(page) async {
    String? token = await auth.accessToken();
    await recipesController.getCreatedData(token, page);
    List<Recipe> allCreatedRecipes = recipesController.createdList;

    if (allCreatedRecipes.length <= 3) {
      createdLoadMorePage = false;
    }

    setState(() {
      this.allCreatedRecipes = allCreatedRecipes;
      isLoading = false;
    });
  }

  Future<void> getAllFavoriteRecipes(page) async {
    String? token = await auth.accessToken();
    await recipesController.getFavoriteData(token, page);
    List<Recipe> allFavoriteRecipes = recipesController.favoriteList;

    if (allFavoriteRecipes.length <= 3) {
      favoriteLoadMorePage = false;
    }

    setState(() {
      this.allFavoriteRecipes = allFavoriteRecipes;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setLoggedInDetails();
    getAllCreatedRecipes(_createdPage);
    getAllFavoriteRecipes(_favoritePage);
    _tabController = TabController(vsync: this, length: 2);

    _createdScrollController.addListener(() async {
      if (_createdScrollController.position.pixels ==
          _createdScrollController.position.maxScrollExtent) {
        if (createdLoadMorePage) {
          int oldListCount = allCreatedRecipes.length;
          await getAllCreatedRecipes(++_createdPage);
          int newListCount = allCreatedRecipes.length;

          if (oldListCount == newListCount) {
            createdLoadMorePage = false;
          }
        }
      }
    });

    _favoriteScrollController.addListener(() async {
      if (_favoriteScrollController.position.pixels ==
          _favoriteScrollController.position.maxScrollExtent) {
        if (favoriteLoadMorePage) {
          int oldListCount = allFavoriteRecipes.length;
          await getAllFavoriteRecipes(++_favoritePage);
          int newListCount = allFavoriteRecipes.length;

          if (oldListCount == newListCount) {
            favoriteLoadMorePage = false;
          }
        }
      }
    });
  }

  Widget recipeCardBuilder(MapEntry e, bool createdList) {
    return RecipeCard(
        recipe: e.value,
        share: () async {
          Map currentUser = await auth.currentUserDetails();
          bool sameUser = currentUser.isNotEmpty && e.value!.authorId == currentUser['userId'];
          String appUrl = 'https://play.google.com/store/apps/details?id=com.fireflies.kuky';

          String shareText = sameUser ? '${e.value!.title}\n\nThis is my recipe available in Ku-Ky app.\n\n$appUrl' : '${e.value!.title}\n\nI found this recipe on Ku-Ky app.\n\n$appUrl';

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
            if (createdList) { allCreatedRecipes[e.key] = updatedRecipe; }
            else { allFavoriteRecipes[e.key] = updatedRecipe; }
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(currentIndex: 3,),
      body: isLoading ?
        const Center(child: Text("Loading...")) :
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TabBar(
                indicatorColor: Colors.redAccent,
                controller: _tabController,
                tabs: const [
                  Tab(text: "My Recipes",),
                  Tab(text: "My Favorites",),
                ],
              ),
              Expanded(
                child: Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context, '/add-edit-recipe',
                        arguments: {}
                      );
                    },
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.add),
                  ),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      isLoggedIn ? ListView(
                        controller: _createdScrollController,
                        children: [
                          ...allCreatedRecipes.asMap().entries.map((recipeEntry) => recipeCardBuilder(recipeEntry, true)).toList(),
                          allCreatedRecipes.isEmpty ? const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                "There are no recipes created by you.\nAdd your recipe by clicking the '+' button.",
                                textAlign: TextAlign.center,
                              )
                          ) : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: createdLoadMorePage ? const Text("Cooking more recipes...", textAlign: TextAlign.center,) : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('You reached the end. Do you want to add more recipe?'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/add-edit-recipe',
                                      arguments: {}
                                    );
                                  },
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
                      ) : const LoginMessage(),
                      isLoggedIn ? ListView(
                        controller: _favoriteScrollController,
                        children: [
                          ...allFavoriteRecipes.asMap().entries.map((recipeEntry) => recipeCardBuilder(recipeEntry, false)).toList(),
                          allFavoriteRecipes.isEmpty ? Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Your favorite recipes will show here",),
                                ],
                              )
                          ) : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: favoriteLoadMorePage ? const Text("Cooking more recipes...", textAlign: TextAlign.center,) : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('You reached the end.'),
                              ],
                            ),
                          )
                        ],
                      ) : const LoginMessage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}

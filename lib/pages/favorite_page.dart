import 'package:flutter/material.dart';
import 'package:recipes/components/login_message.dart';

// Import controllers
import 'package:recipes/controllers/recipes_controller.dart';

// Import services
import 'package:recipes/services/auth/auth.dart';

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

  late TabController _tabController;

  bool isLoading = true;
  bool isLoggedIn = false;

  void setLoggedInDetails()async {
    Auth auth = Auth();
    isLoggedIn = await auth.isLoggedIn();

    setState(() {
      isLoggedIn = isLoggedIn;
    });
  }

  void getAllRecipes() async {
    Auth auth = Auth();
    String? token = await auth.accessToken();
    await recipesController.getCreatedData(token);
    await recipesController.getFavoriteData(token);
    List<Recipe> allCreatedRecipes = recipesController.createdList;
    List<Recipe> allFavoriteRecipes = recipesController.favoriteList;

    setState(() {
      this.allCreatedRecipes = allCreatedRecipes;
      this.allFavoriteRecipes = allFavoriteRecipes;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setLoggedInDetails();
    getAllRecipes();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(currentIndex: 2,),

      body: isLoading ?
        const Center(child: Text("Loading...")) :
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Created",),
                    Tab(text: "Favorite",),
                  ],
                ),
                Expanded(
                  child: Scaffold(
                    floatingActionButton: FloatingActionButton(
                      onPressed: () { Navigator.pushNamed(context, '/add-new-recipe'); },
                      child: const Icon(Icons.add),
                    ),
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        isLoggedIn ? Column(
                          children: allCreatedRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
                        ) : LoginMessage(),
                        isLoggedIn ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: allFavoriteRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
                            ),
                          ],
                        ) : LoginMessage(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

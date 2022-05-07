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
    Auth auth = Auth();
    isLoggedIn = await auth.isLoggedIn();

    setState(() {
      isLoggedIn = isLoggedIn;
    });
  }

  void getAllCreatedRecipes(page) async {
    Auth auth = Auth();
    String? token = await auth.accessToken();
    await recipesController.getCreatedData(token, page);
    List<Recipe> allCreatedRecipes = recipesController.createdList;

    setState(() {
      this.allCreatedRecipes = allCreatedRecipes;
      isLoading = false;
    });
  }

  void getAllFavoriteRecipes(page) async {
    Auth auth = Auth();
    String? token = await auth.accessToken();
    await recipesController.getFavoriteData(token, page);
    List<Recipe> allFavoriteRecipes = recipesController.favoriteList;

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

    _createdScrollController.addListener(() {
      if (_createdScrollController.position.pixels ==
          _createdScrollController.position.maxScrollExtent) {
        if (createdLoadMorePage) {
          int oldListCount = allCreatedRecipes.length;
          getAllCreatedRecipes(++_createdPage);
          int newListCount = allCreatedRecipes.length;

          if (oldListCount == newListCount) {
            createdLoadMorePage = false;
          }
        }
      }
    });

    _favoriteScrollController.addListener(() {
      if (_favoriteScrollController.position.pixels ==
          _favoriteScrollController.position.maxScrollExtent) {
        print("This is end");
        if (favoriteLoadMorePage) {
          int oldListCount = allFavoriteRecipes.length;
          getAllFavoriteRecipes(++_favoritePage);
          int newListCount = allFavoriteRecipes.length;

          if (oldListCount == newListCount) {
            favoriteLoadMorePage = false;
          }
        }
      }
    });
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
                        isLoggedIn ? ListView(
                          controller: _createdScrollController,
                          children: allCreatedRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
                        ) : const LoginMessage(),
                        isLoggedIn ? ListView(
                          controller: _favoriteScrollController,
                          children: allFavoriteRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
                        ) : const LoginMessage(),
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

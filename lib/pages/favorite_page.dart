import 'package:flutter/material.dart';

// Import services
import 'package:recipes/services/recipes/all_recipes.dart';

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
  List<Recipe> allRecipes = [];
  AllRecipes recipes = AllRecipes();

  late TabController _tabController;

  void getAllRecipes() async {
    await recipes.getData();
    List<Recipe> allRecipes = recipes.list;
    setState(() {
      this.allRecipes = allRecipes;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllRecipes();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(currentIndex: 1,),

      body: allRecipes.isEmpty ?
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
                      child: Icon(Icons.add),
                    ),
                    body: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: allRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: allRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
                            ),
                          ],
                        ),
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

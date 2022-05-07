import 'package:flutter/material.dart';

// Import controllers
import 'package:recipes/controllers/recipes_controller.dart';

// Import models
import 'package:recipes/models/recipe.dart';

// Import components
import 'package:recipes/components/recipe_card.dart';
import 'package:recipes/components/bottom_navigator.dart';
import 'package:recipes/components/left_drawer.dart';

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

  void getAllRecipes(page) async {
    await recipesController.getData(page);
    List<Recipe> allRecipes = recipesController.list;
    setState(() {
      this.allRecipes = allRecipes;
    });
  }

  @override
  void initState() {
    super.initState();
    getAllRecipes(_page);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (loadMorePage) {
          int oldListCount = allRecipes.length;
          getAllRecipes(++_page);
          int newListCount = allRecipes.length;

          if (oldListCount == newListCount) {
            loadMorePage = false;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(currentIndex: 0,),
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text('Recipes'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: allRecipes.isEmpty ?
        const Center(child: Text("Loading...")) :
        ListView(
          controller: _scrollController,
          children: allRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
        )
    );
  }
}

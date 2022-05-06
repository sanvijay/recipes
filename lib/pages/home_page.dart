import 'package:flutter/material.dart';

// Import services
import 'package:recipes/services/recipes/all_recipes.dart';

// Import models
import 'package:recipes/models/recipe.dart';

// Import components
import 'package:recipes/components/recipe_card.dart';
import 'package:recipes/components/bottom_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Recipe> allRecipes = [];
  AllRecipes recipes = AllRecipes();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(currentIndex: 0,),
      appBar: AppBar(
        title: const Text('Recipes'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: allRecipes.isEmpty ?
        const Center(child: Text("Loading...")) :
        Column(
          children: allRecipes.map((recipe) => RecipeCard(recipe: recipe)).toList()
        )
    );
  }
}

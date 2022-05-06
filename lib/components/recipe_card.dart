import 'package:flutter/material.dart';

// Import models
import 'package:recipes/models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  RecipeCard({ required this.recipe });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/recipe',
          arguments: { 'slug': recipe.slug }
        );
      },
      child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(recipe.title as String),
                Text(recipe.description as String),
              ],
            ),
          )
      ),
    );
  }
}

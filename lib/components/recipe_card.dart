import 'package:flutter/material.dart';

// Import models
import 'package:recipes/models/recipe.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback setFavorite;

  const RecipeCard({
    Key? key,
    required this.recipe,
    required this.setFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/recipe',
                  arguments: { 'slug': recipe.slug },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Stack(
                    children: [
                      Image.network(
                        recipe.imageUrl as String,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe.title as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                    child: Text(
                      recipe.description as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: setFavorite,
                        child: recipe.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border)
                      ),
                      const SizedBox(width: 10.0,),
                      const Icon(Icons.share),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/recipe',
                        arguments: { 'slug': recipe.slug },
                      );
                    },
                    child: const Text('VIEW RECIPE')
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

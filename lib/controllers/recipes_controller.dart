import 'package:http/http.dart';
import 'dart:convert';

import 'package:recipes/models/recipe.dart';

class RecipesController {
  List<Recipe> list = [];
  List<Recipe> createdList = [];
  List<Recipe> favoriteList = [];

  Future<void> getData() async {
    Response response = await get(Uri.parse('http://192.168.0.102:3000/recipe/list'));
    List<dynamic> data = jsonDecode(response.body);

    for(var i = 0; i < data.length; i++) {
      Recipe recipe = Recipe(slug: data[i]['slug']);
      recipe.assignValues(data[i]['description'], data[i]['title'], data[i]['image_url'], data[i]['is_favorite']);
      list.add(recipe);
    }
  }

  Future<void> getCreatedData(String ?token) async {
    if (token == null) { return; }

    Uri uri = Uri.parse('http://192.168.0.102:3000/recipe/created_list');
    Response response = await get(uri, headers: { 'Authorization': 'Bearer $token' });
    List<dynamic> data = jsonDecode(response.body);

    for(var i = 0; i < data.length; i++) {
      Recipe recipe = Recipe(slug: data[i]['slug']);
      recipe.assignValues(data[i]['description'], data[i]['title'], data[i]['image_url'], data[i]['is_favorite']);
      createdList.add(recipe);
    }
  }

  Future<void> getFavoriteData(String ?token) async {
    if (token == null) { return; }

    Uri uri = Uri.parse('http://192.168.0.102:3000/recipe/favorite_list');
    Response response = await get(uri, headers: { 'Authorization': 'Bearer $token' });
    List<dynamic> data = jsonDecode(response.body);

    for(var i = 0; i < data.length; i++) {
      Recipe recipe = Recipe(slug: data[i]['slug']);
      recipe.assignValues(data[i]['description'], data[i]['title'], data[i]['image_url'], data[i]['is_favorite']);
      favoriteList.add(recipe);
    }
  }

  Future<Recipe> setFavorite(Recipe recipe, bool flag, String ?token) async {
    Uri uri = Uri.http(
        '192.168.0.102:3000',
        '/recipe/${recipe.slug}/set_favorite',
        { 'flag': flag.toString() }
    );
    Response response = await post(uri, headers: { 'Authorization': 'Bearer $token' });
    Map data = jsonDecode(response.body);

    Recipe newRecipe = Recipe(slug: data['slug']);
    newRecipe.assignValues(data['description'], data['title'], data['image_url'], data['is_favorite']);

    return newRecipe;
  }
}

import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

// Import Models
import 'package:recipes/models/recipe.dart';

class RecipesController {
  List<Recipe> list = [];
  List<Recipe> createdList = [];
  List<Recipe> favoriteList = [];

  Future<void> getData(int page, String token) async {
    Uri uri = Uri.parse('${dotenv.env['API_URL']}/recipe/list?page=$page&page_size=10');
    Response response = await get(uri, headers: { 'Authorization': 'Bearer $token' });
    List<dynamic> data = jsonDecode(response.body);

    for(var i = 0; i < data.length; i++) {
      Recipe recipe = Recipe(slug: data[i]['slug']);
      recipe.assignValues(
        data[i]['description'],
        data[i]['title'],
        data[i]['image_url'],
        data[i]['ingredient_details'],
        data[i]['instructions'],
        data[i]['is_favorite'],
        data[i]['duration_in_minutes'],
      );
      list.add(recipe);
    }
  }

  Future<void> getCreatedData(String ?token, int page) async {
    if (token == null) { return; }

    Uri uri = Uri.parse('${dotenv.env['API_URL']}/recipe/created_list?page=$page&page_size=10');
    Response response = await get(uri, headers: { 'Authorization': 'Bearer $token' });
    List<dynamic> data = jsonDecode(response.body);

    for(var i = 0; i < data.length; i++) {
      Recipe recipe = Recipe(slug: data[i]['slug']);
      recipe.assignValues(
        data[i]['description'],
        data[i]['title'],
        data[i]['image_url'],
        data[i]['ingredient_details'],
        data[i]['instructions'],
        data[i]['is_favorite'],
        data[i]['duration_in_minutes']
      );
      createdList.add(recipe);
    }
  }

  Future<void> getFavoriteData(String ?token, int page) async {
    if (token == null) { return; }

    Uri uri = Uri.parse('${dotenv.env['API_URL']}/recipe/favorite_list?page=$page&page_size=10');
    Response response = await get(uri, headers: { 'Authorization': 'Bearer $token' });
    List<dynamic> data = jsonDecode(response.body);

    for(var i = 0; i < data.length; i++) {
      Recipe recipe = Recipe(slug: data[i]['slug']);
      recipe.assignValues(
        data[i]['description'],
        data[i]['title'],
        data[i]['image_url'],
        data[i]['ingredient_details'],
        data[i]['instructions'],
        data[i]['is_favorite'],
        data[i]['duration_in_minutes'],
      );
      favoriteList.add(recipe);
    }
  }

  Future<Recipe> setFavorite(Recipe recipe, bool flag, String ?token) async {
    Uri uri = Uri.parse(
      '${dotenv.env['API_URL']}/recipe/${recipe.slug}/set_favorite?flag=$flag'
    );
    Response response = await post(uri, headers: { 'Authorization': 'Bearer $token' });
    Map data = jsonDecode(response.body);

    Recipe newRecipe = Recipe(slug: data['slug']);
    newRecipe.assignValues(
      data['description'],
      data['title'],
      data['image_url'],
      data['ingredient_details'],
      data['instructions'],
      data['is_favorite'],
      data['duration_in_minutes'],
    );
    newRecipe.assignAuthor(
      data['author']['id'],
      data['author']['first_name'] + ' ' + data['author']['last_name']
    );

    return newRecipe;
  }
}

import 'package:http/http.dart';
import 'dart:convert';

import 'package:recipes/models/recipe.dart';

class AllRecipes {
  List<Recipe> list = [];

  Future<void> getData() async {
    Response response = await get(Uri.parse('http://192.168.0.102:3000/recipe/list'));
    List<dynamic> data = jsonDecode(response.body);

    for(var i = 0; i < data.length; i++) {
      Recipe recipe = Recipe(slug: data[i]['slug']);
      recipe.assignValues(data[i]['description'], data[i]['title'], data[i]['image_url']);
      list.add(recipe);
    }
  }
}

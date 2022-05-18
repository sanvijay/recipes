import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Recipe {
  String slug;
  String? title;
  String? description;
  String? imageUrl;
  bool isFavorite = false;
  int? authorId;
  String? authorFirstName;
  String? authorLastName;
  int? durationInMin;
  List? ingredients;
  List? instructions;
  int? servings;

  final jsonEncoder = const JsonEncoder();

  Recipe({ required this.slug });

  Future<void> setDetails(String? token) async {
    Uri url = Uri.parse('${dotenv.env['API_URL']}/recipe/$slug');
    Response response = await get(url, headers: { 'Authorization': 'Bearer $token' });
    Map data = jsonDecode(response.body);

    title = data['title'];
    description = data['description'];
    imageUrl = data['image_url'];
    isFavorite = data['is_favorite'];
    durationInMin = data['duration_in_minutes'];
    authorId = data['author']['id'];
    authorFirstName = data['author']['first_name'];
    authorLastName = data['author']['last_name'];
    ingredients = data['ingredient_details'];
    instructions = data['instructions'];
    servings = data['servings'];
  }

  void assignValues(String description, String title, String imageUrl, List ingredients, List instructions, bool isFavorite, int durationInMin, int servings) {
    this.description = description;
    this.title = title;
    this.imageUrl = imageUrl;
    this.isFavorite = isFavorite;
    this.durationInMin = durationInMin;
    this.ingredients = ingredients;
    this.instructions = instructions;
    this.servings = servings;
  }

  void assignAuthor(int authorId, String authorFirstName, String authorLastName) {
    this.authorId = authorId;
    this.authorFirstName = authorFirstName;
    this.authorLastName = authorLastName;
  }

  void saveToCloud(String token) async {
    String url = slug == '' ? '${dotenv.env['API_URL']}/recipe/new' : '${dotenv.env['API_URL']}/recipe/$slug/update';
    Uri baseUri = Uri.parse(url);
    Uri uri = baseUri.replace(queryParameters: {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'duration_in_minutes': durationInMin.toString(),
      'ingredient_details': jsonEncoder.convert(ingredients),
      'instructions': jsonEncoder.convert(instructions),
    });
    Response response = await post(uri, headers: { 'Authorization': 'Bearer $token', 'Content-type': 'application/json' });
    Map data = jsonDecode(response.body);
    slug = data['slug'];
  }
}

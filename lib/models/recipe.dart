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
  String? authorName;
  int? durationInMin;

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
    authorName = data['author']['first_name'] + ' ' + data['author']['last_name'];
  }

  void assignValues(String description, String title, String imageUrl, List ingredients, List instructions, bool isFavorite, int durationInMin) {
    this.description = description;
    this.title = title;
    this.imageUrl = imageUrl;
    this.isFavorite = isFavorite;
    this.durationInMin = durationInMin;
  }

  void assignAuthor(int authorId, String authorName) {
    this.authorId = authorId;
    this.authorName = authorName;
  }

  void saveToCloud(String token) async {
    String url = slug == '' ? '${dotenv.env['API_URL']}/recipe/new' : '${dotenv.env['API_URL']}/recipe/$slug/update';
    Uri uri = Uri.parse(url + '?title=$title&description=$description&image_url=$imageUrl&duration_in_minutes=$durationInMin');
    Response response = await post(uri, headers: { 'Authorization': 'Bearer $token' });
    Map data = jsonDecode(response.body);
    slug = data['slug'];
  }
}

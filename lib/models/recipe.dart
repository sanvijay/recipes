import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Recipe {
  String slug;
  String? title;
  String? description;
  String? imageUrl;

  Recipe({ required this.slug });

  Future<void> setDetails() async {
    Response response = await get(Uri.parse('http://192.168.0.102:3000/recipe/$slug'));
    Map data = jsonDecode(response.body);

    title = data['title'];
    description = data['description'];
    imageUrl = data['image_url'];
  }

  void assignValues(description, title, image_url) {
    this.description = description;
    this.title = title;
    this.imageUrl = image_url;
  }

  void saveToCloud() async {
    Uri url = Uri.http(
      '192.168.0.102:3000',
      '/recipe/new',
      { 'title': title, 'description': description, 'image_url': imageUrl }
    );
    Response response = await post(url);
    Map data = jsonDecode(response.body);

    slug = data['slug'];
  }
}

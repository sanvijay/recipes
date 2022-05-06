import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Recipe {
  String slug;
  String? title;
  String? description;
  String? imageUrl;
  bool isFavorite = false;

  Recipe({ required this.slug });

  Future<void> setDetails(String? token) async {
    Uri url = Uri.http(
      '192.168.0.102:3000',
      '/recipe/$slug'
    );
    Response response = await get(url, headers: { 'Authorization': 'Bearer $token' });
    Map data = jsonDecode(response.body);

    title = data['title'];
    description = data['description'];
    imageUrl = data['image_url'];
    isFavorite = data['is_favorite'];
  }

  void assignValues(String description, String title, String imageUrl, bool isFavorite) {
    this.description = description;
    this.title = title;
    this.imageUrl = imageUrl;
    this.isFavorite = isFavorite;
  }

  void saveToCloud(String token) async {
    Uri url = Uri.http(
      '192.168.0.102:3000',
      '/recipe/new',
      { 'title': title, 'description': description, 'image_url': imageUrl }
    );
    Response response = await post(url, headers: { 'Authorization': 'Bearer $token' });
    Map data = jsonDecode(response.body);

    slug = data['slug'];
  }
}

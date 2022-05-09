import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import Pages
import 'package:recipes/pages/home_page.dart';
import 'package:recipes/pages/login_page.dart';
import 'package:recipes/pages/profile_page.dart';
import 'package:recipes/pages/recipe_page.dart';
import 'package:recipes/pages/favorite_page.dart';
import 'package:recipes/pages/add_edit_recipe.dart';
import 'package:recipes/pages/register_page.dart';
import 'package:recipes/pages/search_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/recipe': (context) => const RecipePage(),
        '/favorite': (context) => const FavoritePage(),
        '/add-edit-recipe': (context) => const AddEditRecipePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
        '/search': (context) => const SearchPage(),
      },
    )
  );
}

import 'package:flutter/material.dart';

// Import Pages
import 'package:recipes/pages/home_page.dart';
import 'package:recipes/pages/login_page.dart';
import 'package:recipes/pages/profile_page.dart';
import 'package:recipes/pages/recipe_page.dart';
import 'package:recipes/pages/favorite_page.dart';
import 'package:recipes/pages/add_new_recipe.dart';
import 'package:recipes/pages/register_page.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const HomePage(),
    '/recipe': (context) => const RecipePage(),
    '/favorite': (context) => const FavoritePage(),
    '/add-new-recipe': (context) => const AddNewRecipePage(),
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/profile': (context) => const ProfilePage(),
  },
));

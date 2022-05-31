import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Pages
import 'package:recipes/pages/home_page.dart';
import 'package:recipes/pages/login_page.dart';
import 'package:recipes/pages/play_recipe_page.dart';
import 'package:recipes/pages/profile_page.dart';
import 'package:recipes/pages/recipe_page.dart';
import 'package:recipes/pages/favorite_page.dart';
import 'package:recipes/pages/add_edit_recipe_page.dart';
import 'package:recipes/pages/register_page.dart';
import 'package:recipes/pages/search_page.dart';
import 'package:recipes/pages/settings_page.dart';
import 'package:recipes/pages/confirm_email_page.dart';
import 'package:recipes/pages/reset_password_page.dart';
import 'package:recipes/pages/change_password_page.dart';

// Import Theme
import 'package:recipes/theme_manager.dart';

import 'package:recipes/services/rating_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final newVersion = NewVersion(
      androidId: 'com.fireflies.kuky',
    );
    showRating();

    newVersion.showAlertIfNecessary(context: context);
  }

  void showRating() {
    final RatingService ratingService = RatingService();

    ratingService.readyToShowRating().then((showRating) {
      if (showRating) {
        ratingService.showRating().then((shown) async {
          if (shown) {
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setBool('app:rating_shown', true);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => ThemeNotifier(),
        child: Consumer<ThemeNotifier>(
            builder: (context, theme, _) => MaterialApp(
              theme: theme.getTheme(),
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
                '/settings': (context) => const SettingsPage(),
                '/play-recipe': (context) => const PlayRecipePage(),
                '/confirm-email': (context) => const ConfirmEmailPage(),
                '/reset-password': (context) => const ResetPasswordPage(),
                '/change-password': (context) => const ChangePasswordPage(),
              },
            )
        )
    );
  }
}


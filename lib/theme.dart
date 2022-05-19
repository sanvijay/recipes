import 'package:flutter/material.dart';

class ThemeKlass {

  static ThemeData lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.redAccent,
      )
  );

  static ThemeData darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
      )
  );
}

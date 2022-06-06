import 'package:flutter/material.dart';

class ThemeKlass {

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(),
    tabBarTheme: const TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.redAccent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith((state) => Colors.redAccent)
      )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((state) => Colors.redAccent)
      )
    ),
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        color: Colors.redAccent,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors.redAccent
        ),
      ),
    ),
    primaryColor: Colors.redAccent,
    cardColor: Colors.white30,
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith((state) => Colors.redAccent)
        )
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((state) => Colors.redAccent)
        )
    ),
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        color: Colors.redAccent,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
            color: Colors.redAccent
        ),
      ),
    ),
    primaryColor: Colors.redAccent,
    cardColor: Colors.white30,
  );
}

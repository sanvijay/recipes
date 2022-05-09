import 'package:flutter/material.dart';

// Import Components
import 'package:recipes/components/bottom_navigator.dart';
import 'package:recipes/components/left_drawer.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const BottomNavigator(currentIndex: 1,),
        drawer: const LeftDrawer(),
        appBar: AppBar(
          title: const Text('Search'),
          centerTitle: true,
          backgroundColor: Colors.redAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text('Search Page.')
          ],
        )
    );
  }
}

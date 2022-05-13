import 'package:flutter/material.dart';

class BottomNavigator extends StatelessWidget {
  final int currentIndex;

  const BottomNavigator({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.redAccent,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
      ],
      onTap: (index) {
        switch(index) {
          case 0: {
            if (ModalRoute.of(context)?.settings.name != '/') {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/', (Route<dynamic> route) => false);
            }
          }
          break;
          case 1: {
            if (ModalRoute.of(context)?.settings.name != '/search') {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/search', (Route<dynamic> route) => false);
            }
          }
          break;
          case 2: {
              if (ModalRoute.of(context)?.settings.name != '/favorite') {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/favorite', (Route<dynamic> route) => false);
              }
            }
          break;
          default: {}
          break;
        }
      },
    );
  }
}

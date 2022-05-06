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
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        switch(index) {
          case 0: { Navigator.pushReplacementNamed(context, '/'); }
          break;
          case 1: { Navigator.pushReplacementNamed(context, '/favorite'); }
          break;
          case 2: { Navigator.pushNamed(context, '/login'); }
          break;
          default: {}
          break;
        }
      },
    );
  }
}

import 'package:flutter/material.dart';

// Import services
import 'package:recipes/services/auth_service.dart';
import 'package:recipes/services/rating_service.dart';

// Import controller
import 'package:recipes/controllers/auth_controller.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  bool isLoggedIn = false;
  List<Widget> drawerList = [];
  final RatingService ratingService = RatingService();

  void setDrawerList() async {
    AuthService auth = AuthService();
    isLoggedIn = await auth.isLoggedIn();

    drawerList.add(
      const DrawerHeader(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/appicon-1024.png')),
          color: Color.fromRGBO(249, 250, 250, 1),
          border: Border(bottom: BorderSide(color: Colors.black,)),
        ),
        child: null,
      ),
    );

    drawerList.add(
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Navigator.pushNamed(context, '/settings');
        },
      ),
    );

    if (isLoggedIn) {
      drawerList.add(
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          )
      );
    }

    if (!isLoggedIn) {
      drawerList.add(
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Sign up'),
            onTap: () {
              Navigator.pushNamed(context, '/register');
            },
          )
      );

      drawerList.add(
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Login'),
            onTap: () {
              Navigator.pushNamed(context, '/login');
            },
          )
      );
    }

    if (isLoggedIn) {
      drawerList.add(
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sign Out'),
            onTap: () async {
              AuthController authController = AuthController();
              String? token = await auth.accessToken();

              await authController.signOut(token);
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
            },
          )
      );
    }

    drawerList.add(
        ListTile(
          leading: const Icon(Icons.feedback_outlined),
          title: const Text('Feedback'),
          onTap: () {
            Navigator.pushNamed(context, '/feedback');
          },
        )
    );

    drawerList.add(
      ListTile(
        leading: const Icon(Icons.star),
        title: const Text('Rate our app!'),
        onTap: () {
          if(!ratingService.openRating()) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Try again later!")));
          }
        },
      )
    );

    setState(() {
      isLoggedIn = isLoggedIn;
      drawerList = drawerList;
    });
  }

  @override
  void initState() {
    super.initState();
    setDrawerList();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10.0,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: drawerList.toList(),
      ),
    );
  }
}

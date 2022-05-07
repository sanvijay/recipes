import 'package:flutter/material.dart';

// Import services
import 'package:recipes/services/auth/auth.dart';

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

  void setDrawerList() async {
    Auth auth = Auth();
    isLoggedIn = await auth.isLoggedIn();

    drawerList.add(
      const DrawerHeader(
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Text('Drawer Header'),
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

    drawerList.add(
      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text('Settings'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );

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

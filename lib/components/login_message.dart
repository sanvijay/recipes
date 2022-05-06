import 'package:flutter/material.dart';

class LoginMessage extends StatelessWidget {
  const LoginMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login to access many cool features'),
            TextButton(
                onPressed: () { Navigator.pushNamed(context, '/login'); },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                )
            ),
          ],
        )
    );
  }
}

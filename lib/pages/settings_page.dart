import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:recipes/theme_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String darkThemeValue = 'light';

  void setDarkTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? darkTheme = pref.getString('theme:dark_theme');

    setState(() {
      darkThemeValue = darkTheme ?? 'light';
    });
  }

  @override
  void initState() {
    super.initState();
    setDarkTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
        builder: (context, theme, child) => Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "System Settings",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Dark theme",),
                    DropdownButton<String>(
                      value: darkThemeValue,
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) async {
                        setState(() {
                          darkThemeValue = newValue!;
                        });
                        switch(newValue) {
                          case "light": {
                            theme.setLightMode();
                          }
                          break;
                          case "dark": {
                            theme.setDarkMode();
                          }
                          break;
                          case "system": {
                            theme.setSystemMode();
                          }
                          break;
                          default: {
                            theme.setLightMode();
                          }
                        }
                      },
                      items: <String>['light', 'dark', 'system']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // SwitchListTile(
                //   activeColor: Colors.purple,
                //   contentPadding: const EdgeInsets.all(0),
                //   value: true,
                //   title: const Text("Received notification"),
                //   onChanged: (val) {},
                // ),
                // const SwitchListTile(
                //   activeColor: Colors.purple,
                //   contentPadding: EdgeInsets.all(0),
                //   value: false,
                //   title: Text("Received newsletter"),
                //   onChanged: null,
                // ),
                // SwitchListTile(
                //   activeColor: Colors.purple,
                //   contentPadding: const EdgeInsets.all(0),
                //   value: true,
                //   title: const Text("Received Offer Notification"),
                //   onChanged: (val) {},
                // ),
                // const SwitchListTile(
                //   activeColor: Colors.purple,
                //   contentPadding: EdgeInsets.all(0),
                //   value: true,
                //   title: Text("Received App Updates"),
                //   onChanged: null,
                // ),
                const SizedBox(height: 60.0),
              ],
            ),
          ),
        ],
      ),
        )
    );
  }
}

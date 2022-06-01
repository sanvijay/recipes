import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

// Import Components
import 'package:recipes/components/bottom_navigator.dart';
import 'package:recipes/components/left_drawer.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  String category = 'Love this app!';
  TextEditingController descTxtCntl = TextEditingController();

  void saveFeedback(String cat, String desc) async {
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Write some description")));
      return;
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    int? userId = pref.getInt('user:id');
    try {
      String url = '${dotenv.env['API_URL']}/feedback/new';
      Uri baseUri = Uri.parse(url);
      Uri uri = baseUri.replace(queryParameters: {
        'description': desc,
        'category': cat,
        'user_id': userId.toString()
      });
      Response response =
          await post(uri, headers: {'Content-type': 'application/json'});

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thanks for your feedback!")));
        setState(() {
          category = 'Love this app!';
          descTxtCntl.text = '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Some error occurred! Please try again later!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Some error occurred! Please try again later!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const BottomNavigator(currentIndex: 1,),
        drawer: const LeftDrawer(),
        appBar: AppBar(
          title: const Text('Feedback'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: category,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (String? newValue) {
                      setState(() {
                        category = newValue!;
                      });
                    },
                    items: <String>['Love this app!', 'Faced an issue', 'I have an idea']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10.0,),
              TextField(
                controller: descTxtCntl,
                onChanged: (text) {},
                maxLines: 3,
                maxLength: 256,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter description',
                  labelText: 'Description',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  saveFeedback(category, descTxtCntl.text);
                },
                child: const Text('Submit'),
              ),
            ]
          ),
        )
    );
  }
}

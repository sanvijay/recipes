import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import components
import 'package:recipes/components/login_message.dart';

// Import services
import 'package:recipes/services/auth/auth.dart';

// Import models
import 'package:recipes/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEditRecipePage extends StatefulWidget {
  const AddEditRecipePage({Key? key}) : super(key: key);

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  List<String> fields = ['title', 'description', 'image_url', 'duration_in_minutes'];
  Map values = {};
  Map errors = {};
  bool isLoggedIn = false;
  Map args = {};

  Recipe? recipe;

  TextEditingController recipeTitleTxtCntl = TextEditingController();
  TextEditingController recipeDescTxtCntl = TextEditingController();
  TextEditingController recipeImgUrlTxtCntl = TextEditingController();
  TextEditingController recipeDurationTxtCntl = TextEditingController();

  getRecipeDetails(String? slug) async {
    if (recipe != null) return;
    if (slug == null) return;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    recipe = Recipe(slug: slug);
    await recipe?.setDetails(token);

    recipeTitleTxtCntl.text = recipe?.title ?? '';
    recipeDescTxtCntl.text = recipe?.description ?? '';
    recipeImgUrlTxtCntl.text = recipe?.imageUrl ?? '';
    recipeDurationTxtCntl.text = (recipe?.durationInMin == null ? '' : recipe?.durationInMin.toString())!;

    setState(() {
      recipe = recipe;
      values['title'] = recipe?.title;
      values['description'] = recipe?.description;
      values['image_url'] = recipe?.imageUrl;
      values['slug'] = recipe?.slug;
      values['duration_in_minutes'] = recipe?.durationInMin.toString();
      values['ingredients'] = recipe?.ingredients ?? [];
      values['instructions'] = recipe?.instructions ?? [];
    });
  }

  void setLoggedInDetails()async {
    Auth auth = Auth();
    isLoggedIn = await auth.isLoggedIn();

    setState(() {
      isLoggedIn = isLoggedIn;
    });
  }

  void prepareValueForIngredient() {
    if(values['ingredients'] == null) {
      values['ingredients'] = [];
    }

    if(values['ingredients'].length < 1) {
      values['ingredients'].add({});
    }
  }

  void prepareValueForInstruction() {
    if(values['instructions'] == null) {
      values['instructions'] = [];
    }

    if(values['instructions'].length < 1) {
      values['instructions'].add({});
    }
  }

  @override
  void initState() {
    super.initState();
    setLoggedInDetails();
    prepareValueForIngredient();
    prepareValueForInstruction();
  }

  void validateAndSaveData() async {
    errors = {};
    for(int i = 0; i < fields.length; i++) {
      if (values[fields[i]] == null || values[fields[i]] == '') {
        values[fields[i]];
        setState(() {
          errors[fields[i]] = "This field is required";
        });
      }
    }

    if (errors.isNotEmpty) { return; }

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    if (token == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("You need to login")));
      return;
    }

    Recipe newRecipe = Recipe(slug: values['slug'] ?? '');
    newRecipe.assignValues(
      values['description'],
      values['title'],
      values['image_url'],
      values['ingredients'],
      values['instructions'],
      false,
      int.parse(values['duration_in_minutes']),
    );

    newRecipe.saveToCloud(token);
    Navigator.pop(context);
  }

  List<Widget> ingredientInputList() {
    List<Widget> res = [];
    for(int i = 0; i < values['ingredients'].length; i++){
      res.add(ingredientInput(i, values['ingredients'][i]));
    }
    return res;
  }

  Widget ingredientInput(int index, Map value) {
    TextEditingController titleCntl = TextEditingController();
    TextEditingController quantityCntl = TextEditingController();
    TextEditingController unitCntl = TextEditingController();

    titleCntl.text = value['title'] ?? '';
    quantityCntl.text = value['quantity'] == null ? '' : value['quantity'].toString();
    unitCntl.text = value['unit'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Container(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            children: [
              TextField(
                controller: titleCntl,
                maxLength: 24,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Ingredient',
                ),
                onChanged: (text) {
                  Map currentValue = values['ingredients'][index];
                  currentValue['title'] = text;

                  values['ingredients'][index] = currentValue;
                },
              ),
              const SizedBox(height: 10.0,),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityCntl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Quantity',
                      ),
                      onChanged: (text) {
                        Map currentValue = values['ingredients'][index];
                        currentValue['quantity'] = text;

                        values['ingredients'][index] = currentValue;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                    ),
                    flex: 1,
                  ),
                  const SizedBox(width: 10.0,),
                  Expanded(child:
                    TextField(
                      controller: unitCntl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Unit',
                      ),
                      onChanged: (text) {
                        Map currentValue = values['ingredients'][index];
                        currentValue['unit'] = text;

                        values['ingredients'][index] = currentValue;
                      },
                    ),
                    flex: 1,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if(values['ingredients'].length <= 1) { return; }
                  setState(() {
                    values['ingredients'].removeAt(index);
                  });
                },
                child: const Text('Remove'),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> instructionInputList() {
    List<Widget> res = [];
    for(int i = 0; i < values['instructions'].length; i++){
      res.add(instructionInput(i, values['instructions'][i]));
    }
    return res;
  }

  Widget instructionInput(int index, Map value) {
    TextEditingController valueCntl = TextEditingController();
    TextEditingController durationCntl = TextEditingController();

    value['order'] = index;
    valueCntl.text = value['value'] ?? '';
    durationCntl.text = value['duration'] == null ? '' : value['duration'].toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Container(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            children: [
              TextField(
                controller: valueCntl,
                maxLines: 3,
                maxLength: 256,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Instruction',
                ),
                onChanged: (text) {
                  Map currentValue = values['instructions'][index];
                  currentValue['value'] = text;

                  values['instructions'][index] = currentValue;
                },
              ),
              const SizedBox(height: 10.0,),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durationCntl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Duration',
                      ),
                      onChanged: (text) {
                        Map currentValue = values['instructions'][index];
                        currentValue['duration'] = text;

                        values['instructions'][index] = currentValue;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                    ),
                    flex: 1,
                  ),
                  const SizedBox(width: 10.0,),
                  Expanded(
                    child: DropdownButton<String>(
                      value: values['instructions'][index]['unit'] ?? 'min',
                      icon: const Icon(Icons.arrow_downward),
                      elevation: 16,
                      onChanged: (String? newValue) {
                        setState(() {
                          Map currentValue = values['instructions'][index];
                          currentValue['unit'] = newValue;

                          values['instructions'][index] = currentValue;
                        });
                      },
                      items: <String>['sec', 'min', 'hours', 'days']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    flex: 1,
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if(values['instructions'].length <= 1) { return; }
                  setState(() {
                    values['instructions'].removeAt(index);
                  });
                },
                child: const Text('Remove'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    args = ModalRoute.of(context)?.settings.arguments as Map;
    getRecipeDetails(args['slug']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Recipe'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: !isLoggedIn ? const LoginMessage() : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: recipeTitleTxtCntl,
                onChanged: (text) {
                  setState(() { errors['title'] = null; });
                  values['title'] = text;
                },
                maxLines: 2,
                autofocus: true,
                maxLength: 72,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter title',
                  errorText: errors['title'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: recipeDescTxtCntl,
                onChanged: (text) {
                  setState(() { errors['description'] = null; });
                  values['description'] = text;
                },
                maxLines: 3,
                maxLength: 256,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter description',
                  errorText: errors['description'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: recipeImgUrlTxtCntl,
                onChanged: (text) {
                  setState(() { errors['image_url'] = null; });
                  values['image_url'] = text;
                },
                maxLength: 256,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Image Url',
                  errorText: errors['image_url'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: recipeDurationTxtCntl,
                keyboardType: TextInputType.number,
                onChanged: (text) {
                  setState(() { errors['duration_in_minutes'] = null; });
                  values['duration_in_minutes'] = text;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Enter Duration in minutes',
                  errorText: errors['duration_in_minutes'],
                ),
              ),
            ),
            const Divider(
              thickness: 2.0,
            ),
            const Text(
              'Ingredients',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: [
                ...ingredientInputList(),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      values['ingredients'].add({});
                    });
                  },
                  child: const Text("Add another ingredient")
                )
              ],
            ),
            const Divider(
              thickness: 2.0,
            ),
            const Text(
              'Instructions',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: [
                ...instructionInputList(),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        values['instructions'].add({});
                      });
                    },
                    child: const Text("Add another instruction")
                )
              ],
            ),
            const Divider(
              thickness: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  validateAndSaveData();
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      )
    );
  }
}

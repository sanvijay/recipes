import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import models
import 'package:recipes/models/recipe.dart';

import 'package:recipes/theme_manager.dart';

class PlayRecipePage extends StatefulWidget {
  const PlayRecipePage({Key? key}) : super(key: key);

  @override
  _PlayRecipePageState createState() => _PlayRecipePageState();
}

class _PlayRecipePageState extends State<PlayRecipePage> {
  Recipe? recipe;
  int state = -1;
  bool isDarkMode = false;

  ThemeNotifier theme = ThemeNotifier();

  List ingredients = [];
  int noOfServings = 1;
  List instructions = [];

  late BannerAd _ad;
  bool adLoaded = false;

  @override
  void initState() {
    super.initState();

    setDarkMode();

    _ad = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: dotenv.env['BANNER_AD_UNIT_ID'] ?? "",
        listener: BannerAdListener(
            onAdLoaded: (_) {
              setState(() {
                adLoaded = true;
              });
            },
            onAdFailedToLoad: (_, error) {
              print('Ad failed: $error');
            }
        ),
        request: const AdRequest()
    )..load();
  }

  Widget checkForAd() {
    if (adLoaded) {
      return SizedBox(
        height: _ad.size.height.toDouble(),
        width: _ad.size.width.toDouble(),
        child: AdWidget(ad: _ad,),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void setDarkMode() async {
    isDarkMode = await theme.isDarkMode();
  }

  void getRecipeDetails(String slug, { bool force = false }) async {
    if (recipe != null && !force) return;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    recipe = Recipe(slug: slug);
    await recipe?.setDetails(token);
    setState(() {
      recipe = recipe;
      ingredients = recipe!.ingredients!;
      noOfServings = recipe!.servings!;
      instructions = recipe!.instructions!;
    });
  }

  void moveNextState() {
    if (recipe == null) return;
    state++;

    setState(() {
      if (state > recipe!.instructions!.length) state = recipe!.instructions!.length;
    });
  }

  void movePrevState() {
    if (recipe == null) return;
    state--;

    setState(() {
      if (state < -1) state = -1;
    });
  }

  bool areAllIngredientChecked() {
    if (ingredients.isEmpty) return false;

    return ingredients.every((element) => element['checked'] ?? false);
  }

  void checkAllIngredients() {
    for(int i = 0; i < ingredients.length; i++) {
      ingredients[i]['checked'] = true;
    }

    setState(() {
      ingredients = ingredients;
    });
  }

  void uncheckAllIngredients() {
    for(int i = 0; i < ingredients.length; i++) {
      ingredients[i]['checked'] = false;
    }

    setState(() {
      ingredients = ingredients;
    });
  }

  Widget ingredientCard(Map ingredient) {
    double quantity = ingredient['quantity'] * (noOfServings / recipe!.servings!);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.grey,
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: ingredient['checked'] ?? false,
                      onChanged: (val) {
                        setState(() {
                          ingredient['checked'] = val;
                        });
                      }
                    ),
                    Text(
                      ingredient['title'],
                      style: const TextStyle(
                          fontSize: 20
                      ),
                    ),
                  ],
                ),
                Text(
                  numberToString(quantity) + " " + ingredient['unit'],
                  style: const TextStyle(
                    fontSize: 20
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }

  String numberToString(double value) {
    double roundValue = value.roundToDouble();

    return value == roundValue ? value.toStringAsFixed(0) : value.toString();
  }

  Widget buildIngredientChecklistPage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      bottomNavigationBar: checkForAd(),
      body: ingredients.isEmpty ? const Center(child: Text("Loading..."),) : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Card(
                color: Colors.grey,
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Servings",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                noOfServings--;
                                if (noOfServings <= 1) noOfServings = 1;
                              });
                            },
                            child: const Icon(Icons.remove,),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              noOfServings.toString(),
                              style: const TextStyle(
                                fontSize: 20
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                noOfServings++;
                              });
                            },
                            child: const Icon(Icons.add,),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Text(
              "Get ready with ingredients",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...ingredients.map((ing) => ingredientCard(ing)).toList(),
            const SizedBox(height: 80,)
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton.extended(
            heroTag: 'checkAll',
            onPressed: () {
              if (areAllIngredientChecked()) {
                uncheckAllIngredients();
              } else {
                checkAllIngredients();
              }
            },
            icon: const Icon(Icons.check_circle_outline_outlined,),
            label: Text(areAllIngredientChecked() ? "Uncheck all" : "Check all"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FloatingActionButton.extended(
            heroTag: 'startCooking',
            onPressed: () {
              if (!areAllIngredientChecked()) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Check all the boxes to continue.")));
                return;
              }

              moveNextState();
            },
            icon: Icon(
              Icons.restaurant,
              color: areAllIngredientChecked() ? Colors.black : Colors.grey[700],
            ),
            label: Text(
              "Start cooking",
              style: TextStyle(
                color: areAllIngredientChecked() ? Colors.black : Colors.grey[700],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      )
    );
  }

  Widget buildInstructionPage(int state) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                instructions[state]['image_url'] != null && instructions[state]['image_url'] != '' ? Image.network(
                  instructions[state]['image_url'] as String,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                ) : const SizedBox.shrink(),
                Text(
                  instructions[state]['value'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton.extended(
              heroTag: 'previous',
              onPressed: () {
                movePrevState();
              },
              icon: const Icon(
                Icons.arrow_left,
              ),
              label: const Text("Previous"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // FloatingActionButton.extended(
            //   heroTag: 'action',
            //   onPressed: () {/* Do something */},
            //   label: const Text("Completed"),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            // ),
            FloatingActionButton.extended(
              heroTag: 'next',
              onPressed: () {
                moveNextState();
              },
              icon: const Icon(
                Icons.arrow_right,
              ),
              label: const Text("Next"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        )
    );
  }

  Widget completedPage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Center(
        child: Text(
          "Delicious ${recipe?.title}\nis ready now!",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton.extended(
            heroTag: 'previous',
            onPressed: () {
              movePrevState();
            },
            icon: const Icon(
              Icons.arrow_left,
            ),
            label: const Text("Previous"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FloatingActionButton.extended(
            heroTag: 'action',
            onPressed: () {
              Navigator.pop(context);
            },
            label: const Text("Go back to recipe"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context)?.settings.arguments as Map;
    getRecipeDetails(args['slug']);

    if (state <= -1) {
      return buildIngredientChecklistPage();
    } else if (state >= instructions.length) {
      return completedPage();
    } else {
      return buildInstructionPage(state);
    }
  }
}

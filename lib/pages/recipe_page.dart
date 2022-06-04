import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import models
import 'package:recipes/models/recipe.dart';

// Import controllers
import 'package:recipes/controllers/recipes_controller.dart';

// Import Services
import 'package:recipes/services/auth_service.dart';
import 'package:recipes/services/share_service.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({Key? key}) : super(key: key);

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  Map data = {};
  Recipe? recipe;
  Map currentUser = {};

  late BannerAd _ad;
  late InterstitialAd _interstitialAd;
  bool adLoaded = false;
  bool intAdLoaded = false;

  getRecipeDetails(String slug, { bool force = false }) async {
    if (recipe != null && !force) return;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('auth:access_token');

    recipe = Recipe(slug: slug);
    await recipe?.setDetails(token);
    setState(() {
      recipe = recipe;
    });
  }

  void setCurrentUser() async {
    AuthService auth = AuthService();
    currentUser = await auth.currentUserDetails();
    setState(() {
      currentUser = currentUser;
    });
  }

  @override
  void initState() {
    super.initState();
    setCurrentUser();

    loadAds();
  }

  void loadAds() async {
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

    InterstitialAd.load(
      adUnitId: dotenv.env['INTERSTITIAL_AD_UNIT_ID'] ?? "",
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
          setState(() {
            intAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments as Map;
    getRecipeDetails(data['slug']);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (intAdLoaded) {
            _interstitialAd.show();
          }
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(const SnackBar(content: Text("New feature coming soon!")));
          Navigator.pushNamed(
            context,
            '/play-recipe',
            arguments: { 'slug': recipe!.slug },
          );
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text(recipe?.title ?? ''),
        actions: <Widget>[
          recipe != null && currentUser.isNotEmpty && recipe!.authorId == currentUser['userId'] ? GestureDetector(
            child: const Icon(Icons.edit),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add-edit-recipe',
                arguments: { 'slug': recipe?.slug }
              );
            },
          ) : const SizedBox.shrink(),
          const SizedBox(width: 20.0,),
          GestureDetector(
            child: recipe != null && recipe!.isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
            onTap: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              String? token = pref.getString('auth:access_token');

              if (token == null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("You need to login")));
                return;
              }

              RecipesController recipesController = RecipesController();
              Recipe updatedRecipe = await recipesController.setFavorite(recipe!, !recipe!.isFavorite, token);
              setState(() {
                recipe = updatedRecipe;
              });
            },
          ),
          const SizedBox(width: 20.0,),
          GestureDetector(
            child: const Icon(Icons.share),
            onTap: () {
              bool sameUser = currentUser.isNotEmpty && recipe!.authorId == currentUser['userId'];
              String appUrl = 'https://play.google.com/store/apps/details?id=com.fireflies.kuky';

              String shareText = sameUser ? '${recipe!.title}\n\nThis is my recipe available in Ku-Ky app.\n\n$appUrl' : '${recipe!.title}\n\nI found this recipe on Ku-Ky.\n\n$appUrl';

              ShareService shareService = ShareService();
              shareService.share(recipe?.imageUrl ?? '', shareText);
            },
          ),
          const SizedBox(width: 30.0,),
        ],
      ),
      body: recipe?.title == null ?
        const Center(child: Text("Loading...")) :
        RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 2));
            getRecipeDetails(data['slug'], force: true);
          },
          child: SingleChildScrollView(child: RecipeDetails(recipe: recipe, bannerAd: _ad, adLoaded: adLoaded,))
        )
    );
  }
}

class RecipeDetails extends StatelessWidget {
  const RecipeDetails({
    Key? key,
    required this.recipe,
    required this.bannerAd,
    required this.adLoaded,
  }) : super(key: key);

  final Recipe? recipe;
  final BannerAd? bannerAd;
  final bool? adLoaded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.network(
          recipe?.imageUrl as String,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
          height: 300,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            recipe?.title as String,
            style: const TextStyle(
              fontSize: 28.0,
              letterSpacing: 2.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(recipe?.description as String),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text((recipe?.durationInMin.toString() as String) + ' minutes'),
            ),
          ],
        ),
        const Divider(
          thickness: 2.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            'Added By',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text((recipe?.authorFirstName ?? '')[0].toUpperCase() + (recipe?.authorLastName ?? '')[0].toUpperCase(), style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),),
              ),
              Text((recipe?.authorFirstName ?? '') + ' ' + (recipe?.authorLastName ?? ''))
            ],
          ),
        ),
        const Divider(
          thickness: 2.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              Row(
                children: [
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 10.0),
                  //   child: Text(
                  //     '-',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.black,
                  //     ),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      '${recipe?.servings ?? ''} Servings',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 10.0),
                  //   child: Text(
                  //     '+',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w500,
                  //       color: Colors.black,
                  //     ),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // ),
                ],
              )
            ],
          )
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: recipe!.ingredients!.map((ing) => ingredientTableRow(ing)).toList(),
          ),
        ),
        const Divider(
          thickness: 2.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: const Text(
                'Tags',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.crop_square_rounded,
                    color: recipe?.dietType == "veg" ? Colors.green : Colors.red,
                    size: 36,
                  ),
                  Icon(
                    Icons.circle,
                    color: recipe?.dietType == "veg" ? Colors.green : Colors.red,
                    size: 14
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          width: MediaQuery.of(context).size.width,
          child: Wrap(
            children: recipe!.recipeTags!.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: Text(tag),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.orangeAccent,
                ),
              );
            }).toList()
          ),
        ),
        checkForAd(),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10.0),
          child: const Text(
            'Directions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recipe!.instructions!.map((ins) => instructionStep(ins)).toList(),
          ),
        ),
        const SizedBox(height: 60.0,)
      ],
    );
  }

  Widget checkForAd() {
    if (bannerAd != null && adLoaded == true) {
      return SizedBox(
        height: bannerAd!.size.height.toDouble(),
        width: bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: bannerAd!,),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget ingredientTableRow(Map ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(ingredient['title'], textAlign: TextAlign.left,),
          Expanded(child: Text('.' * 100, maxLines: 1)),
          Text(numberToString(ingredient['quantity']) + " " + ingredient['unit'], textAlign: TextAlign.left,),
        ]
      ),
    );
  }

  String numberToString(num value) {
    double roundValue = value.roundToDouble();

    return value == roundValue ? value.toStringAsFixed(0) : value.toString();
  }

  Widget instructionStep(Map instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
            child: Text("Step ${instruction['order'] + 1}",
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                // decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(instruction['value']),
        ],
      ),
    );
  }
}

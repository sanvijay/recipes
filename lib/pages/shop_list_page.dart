import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

// Import Components
import 'package:recipes/components/bottom_navigator.dart';
import 'package:recipes/components/left_drawer.dart';

class CircularButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  CircularButton({
    required this.color,
    required this.width,
    required this.height,
    required this.icon,
    required this.onClick
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color,shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(icon: icon, enableFeedback: true, onPressed: () => onClick()),
    );
  }
}

class ShopListPage extends StatefulWidget {
  const ShopListPage({Key? key}) : super(key: key);

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> with SingleTickerProviderStateMixin {
  List ingredients = [];
  bool isLoading = true;
  bool animLoaded = false;

  late AnimationController animationController;
  late Animation degOneTranslationAnimation,degTwoTranslationAnimation,degThreeTranslationAnimation;
  late Animation rotationAnimation;


  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getHiveData();

    animationController = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2,end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.4,end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(tween: Tween<double >(begin: 0.0,end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.75,end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0,end: 0.0).animate(CurvedAnimation(parent: animationController
        , curve: Curves.easeOut));
    super.initState();
    animationController.addListener((){
      setState(() {

      });
    });
    setState(() {
      animLoaded = true;
    });
  }

  void getHiveData() async {
    var box = await Hive.openBox('shoppingList');

    setState(() {
      ingredients = box.keys.map((key) => box.get(key)).toList();
      isLoading = false;
    });
    box.close();
  }

  String convertToSlug(String text)
  {
    return text
      .toLowerCase()
      .replaceAll(RegExp(r' '), '-')
      .replaceAll(RegExp(r'[^\w-]+'), '');
  }

  Widget ingredientCard(Map ingredient) {
    final String prevSlug = ingredient['slug'];
    Set<String> existingTags = Set.from(ingredient["tags"]);

    TextEditingController titleCntl = TextEditingController();
    TextEditingController quantityCntl = TextEditingController();

    titleCntl.text = ingredient['title'];
    quantityCntl.text = ingredient['quantity'];

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      var box = await Hive.openBox('shoppingList');
                      await box.delete(prevSlug);
                      setState(() {
                        ingredients = box.keys.map((key) => box.get(key)).toList();
                      });
                      box.close();

                      Navigator.pop(context, 'Delete');
                    },
                    child: const Text('delete'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('cancel'),
                  ),
                  TextButton(
                    child: const Text('save'),
                    onPressed: () async {
                      var box = await Hive.openBox('shoppingList');

                      await box.delete(prevSlug);
                      String newSlug = convertToSlug(titleCntl.text);
                      await box.put(newSlug, {
                        "slug": newSlug,
                        "title": titleCntl.text,
                        "quantity": quantityCntl.text,
                        "checked": false,
                        "tags": existingTags.toList(),
                      });

                      setState(() {
                        ingredients = box.keys.map((key) => box.get(key)).toList();
                      });
                      box.close();
                      Navigator.pop(context, 'Save');
                    },
                  ),
                ],
                content: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: titleCntl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Title',
                          labelText: 'Enter Title',
                        ),
                      ),
                      const SizedBox(height: 8.0,),
                      TextField(
                        controller: quantityCntl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter Quantity',
                          labelText: 'Enter Quantity',
                        ),
                      ),
                      const SizedBox(height: 8.0,),
                      List<String>.from(ingredient['tags']).isEmpty ? SizedBox.shrink() : Text("Tags:", style: TextStyle(fontWeight: FontWeight.bold),),
                      Wrap(
                        children: List<String>.from(ingredient['tags']).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            margin: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                            child: Text(tag, style: const TextStyle(color: Colors.black),),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orangeAccent,
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              );
            }
          );
        },
        child: Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          shape: const CircleBorder(),
                          value: ingredient['checked'] ?? false,
                          onChanged: (val) async {
                            setState(() {
                              ingredient['checked'] = val;
                            });
                            var box = await Hive.openBox('shoppingList');

                            box.put(ingredient['slug'], ingredient);
                            box.close();
                          }
                        ),
                        Text(
                          ingredient['title'],
                          style: TextStyle(
                            fontSize: 16,
                            decoration: ingredient['checked'] ?? false ? TextDecoration.lineThrough : TextDecoration.none
                          ),
                        ),
                      ],
                    ),
                    Text(
                      ingredient['quantity'],
                      style: const TextStyle(
                          fontSize: 16
                      ),
                    ),
                  ]
                ),
                Wrap(
                  children: List<String>.from(ingredient['tags']).map<Widget>((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      margin: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                      child: Text(tag, style: const TextStyle(color: Colors.black),),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orangeAccent,
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavigator(currentIndex: 2,),
      drawer: const LeftDrawer(),
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          IgnorePointer(
            child: Container(
              color: Colors.transparent,
              height: 150.0,
              width: 150.0,
            ),
          ),
          Transform.translate(
            offset: Offset.fromDirection(getRadiansFromDegree(270),degOneTranslationAnimation.value * 100),
            child: Transform(
              transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degOneTranslationAnimation.value),
              alignment: Alignment.center,
              child: CircularButton(
                color: Colors.blue,
                width: 50,
                height: 50,
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onClick: (){
                  TextEditingController titleCntl = TextEditingController();
                  TextEditingController quantityCntl = TextEditingController();

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('cancel'),
                            ),
                            TextButton(
                              child: const Text('save'),
                              onPressed: () async {
                                var box = await Hive.openBox('shoppingList');

                                String newSlug = convertToSlug(titleCntl.text);
                                await box.put(newSlug, {
                                  "slug": newSlug,
                                  "title": titleCntl.text,
                                  "quantity": quantityCntl.text,
                                  "checked": false,
                                  "tags": [],
                                });

                                setState(() {
                                  ingredients = box.keys.map((key) => box.get(key)).toList();
                                });
                                box.close();
                                Navigator.pop(context, 'Save');
                              },
                            ),
                          ],
                          content: Form(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextField(
                                  controller: titleCntl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter Title',
                                    labelText: 'Enter Title',
                                  ),
                                ),
                                const SizedBox(height: 8.0,),
                                TextField(
                                  controller: quantityCntl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Enter Quantity',
                                    labelText: 'Enter Quantity',
                                  ),
                                ),
                                const SizedBox(height: 8.0,),
                              ],
                            ),
                          ),
                        );
                      }
                  );
                },
              ),
            ),
          ),
          // Transform.translate(
          //   offset: Offset.fromDirection(getRadiansFromDegree(225),degTwoTranslationAnimation.value * 100),
          //   child: Transform(
          //     transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degTwoTranslationAnimation.value),
          //     alignment: Alignment.center,
          //     child: CircularButton(
          //       color: Colors.black,
          //       width: 50,
          //       height: 50,
          //       icon: Icon(
          //         Icons.camera_alt,
          //         color: Colors.white,
          //       ),
          //       onClick: (){
          //         print('Second button');
          //       },
          //     ),
          //   ),
          // ),
          Transform.translate(
            offset: Offset.fromDirection(getRadiansFromDegree(180),degThreeTranslationAnimation.value * 100),
            child: Transform(
              transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value))..scale(degThreeTranslationAnimation.value),
              alignment: Alignment.center,
              child: CircularButton(
                color: Colors.orangeAccent,
                width: 50,
                height: 50,
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onClick: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Warning!'),
                      content: const Text('Are you sure you want to delete all data? This action cannot be undo.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            var box = await Hive.openBox('shoppingList');
                            box.clear();

                            setState(() {
                              ingredients = [];
                            });

                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Transform(
            transform: Matrix4.rotationZ(getRadiansFromDegree(rotationAnimation.value)),
            alignment: Alignment.center,
            child: CircularButton(
              color: Colors.redAccent,
              width: 60,
              height: 60,
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onClick: () {
                if (animationController.isCompleted) {
                  animationController.reverse();
                } else {
                  animationController.forward();
                }
              },
            ),
          )
        ],
      ),
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: const [
          Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: 'Long press to edit the list',
            child: Icon(Icons.question_mark_rounded),
          ),
          SizedBox(width: 20.0,),
        ],
      ),
      body: getBodyWidget(),
    );
  }

  Widget getBodyWidget() {
    if (isLoading && !animLoaded) {
      return const Center(child: Text("Loading..."),);
    }
    else if (ingredients.isEmpty) {
      return const Center(child: Text("Add your shopping check list."),);
    }
    else {
      return SingleChildScrollView(
        child: Column(
          children: [
            ...ingredients.where((ing) => !(ing['checked'] ?? false)).map((ing) => ingredientCard(ing)).toList(),
            ...ingredients.where((ing) => ing['checked'] ?? false).map((ing) => ingredientCard(ing)).toList(),
          ]
        ),
      );
    }
  }
}

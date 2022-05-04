// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      title: 'Pierced',
      theme: ThemeData.light(),
      home: TakePhoto(
        camera: firstCamera,
      ),
    ),
  );
}

// https://docs.flutter.dev/cookbook/plugins/picture-using-camera
class TakePhoto extends StatefulWidget {
  const TakePhoto({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  late CameraController _controller;
  late Future<void> _intializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _intializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(140, 69, 164, 232),
          title: const Text('Please take a photo of your ear')),
      body: FutureBuilder<void>(
        future: _intializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _intializeControllerFuture;
            final image = await _controller.takePicture();
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPhotoScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPhotoScreen extends StatefulWidget {
  final String imagePath;
  const DisplayPhotoScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<DisplayPhotoScreen> createState() => _DisplayPhotoScreenState();
}

class _DisplayPhotoScreenState extends State<DisplayPhotoScreen> {
  String _map = 'images/blank.png';
  bool isPressedL = false;
  bool isPressedR = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(140, 69, 164, 232),
        leading: IconButton(
          onPressed: (() => Navigator.pop(context)),
          icon: Image.asset('images/back.png'),
        ),
        title: const Text('Photo Preview'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CurateEarScreen(
                      imagePath: widget.imagePath,
                      map: _map,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward))
        ],
      ),
      body: Column(children: [
        Image.file(File(widget.imagePath)),
        const Padding(
            padding: EdgeInsets.only(left: 45.0),
            child: SizedBox(
                width: 400,
                child: ListTile(
                  title: Text('Is this your right ear or left ear?'),
                ))),
        Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 110.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _map = 'images/leftMap.png';
                      isPressedL = !isPressedL;
                      isPressedR = false;
                    });
                  },
                  child: const Text('Left'),
                  style: ElevatedButton.styleFrom(
                    primary: isPressedL
                        ? const Color.fromARGB(137, 57, 162, 125)
                        : const Color.fromARGB(140, 69, 164, 232),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _map = 'images/rightMap.png';
                      isPressedR = !isPressedR;
                      isPressedL = false;
                    });
                  },
                  child: const Text('Right'),
                  style: ElevatedButton.styleFrom(
                    primary: isPressedR
                        ? const Color.fromARGB(137, 57, 162, 125)
                        : const Color.fromARGB(140, 69, 164, 232),
                  ),
                )),
          ],
        ),
      ]),
    );
  }
}

// ignore: must_be_immutable
class CurateEarScreen extends StatefulWidget {
  final String imagePath;
  String map;

  CurateEarScreen({Key? key, required this.imagePath, required this.map})
      : super(key: key);

  @override
  _CurateEarScreenState createState() => _CurateEarScreenState();
}

class _CurateEarScreenState extends State<CurateEarScreen> {
  List<Widget> movable = [];
  bool _isPressed = false;
  String map = 'images/blank.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(140, 69, 164, 232),
          title: SizedBox(height: 75, child: Image.asset('images/logo.png')),
          actions: [
            IconButton(
              icon: Image.asset('images/time.png'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealingScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Image.asset('images/aftercare.png'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AftercareScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Image.asset('images/map.png'),
              onPressed: () {
                setState(
                  () {
                    _isPressed = !_isPressed;
                  },
                );
                if (_isPressed) {
                  map = widget.map;
                } else {
                  map = 'images/blank.png';
                }
              },
            ),
          ]),
      body: Column(children: [
        Stack(
          children: [
            Center(
              child: SizedBox(
                height: 400.0,
                width: 304.0,
                child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [Image.asset(widget.imagePath)],
                    )),
              ),
            ),
            Center(
                child: SizedBox(
                    height: 370.0,
                    width: 450.0,
                    child: Row(
                      children: [Image.asset(map)],
                    ))),
            SizedBox(
                height: 700.0,
                width: 500.0,
                child: Stack(children: const [
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/ball.png',
                        xPosition: -40.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/ball.png',
                        xPosition: -40.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/ball.png',
                        xPosition: -40.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/blueStud.png',
                        xPosition: 20.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/blueStud.png',
                        xPosition: 20.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/blueStud.png',
                        xPosition: 20.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/pearl.png',
                        xPosition: 80.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/pearl.png',
                        xPosition: 80.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/pearl.png',
                        xPosition: 80.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/stud.png',
                        xPosition: 140.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/stud.png',
                        xPosition: 140.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    child: MovableStack(
                        imagePath: 'images/stud.png',
                        xPosition: 140.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    width: 400,
                    child: MovableStack(
                        imagePath: 'images/silverHoop.png',
                        xPosition: 200.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    width: 400,
                    child: MovableStack(
                        imagePath: 'images/silverHoop.png',
                        xPosition: 200.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    width: 400,
                    child: MovableStack(
                        imagePath: 'images/silverHoop.png',
                        xPosition: 200.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    width: 400,
                    child: MovableStack(
                        imagePath: 'images/hoop.png',
                        xPosition: 260.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    width: 400,
                    child: MovableStack(
                        imagePath: 'images/hoop.png',
                        xPosition: 260.0,
                        yPosition: 0.0),
                  ),
                  SizedBox(
                    height: 900.0,
                    width: 400,
                    child: MovableStack(
                        imagePath: 'images/hoop.png',
                        xPosition: 260.0,
                        yPosition: 0.0),
                  ),
                ])),
          ],
        ),
      ]),
    );
  }
}

// https://medium.com/flutter-community/create-a-draggable-widget-in-flutter-50b61f12635d
class MovableStack extends StatefulWidget {
  final String imagePath;
  final double xPosition;
  final double yPosition;

  const MovableStack({
    Key? key,
    required this.imagePath,
    required this.xPosition,
    required this.yPosition,
  }) : super(key: key);

  @override
  State<MovableStack> createState() => _MovableStackState();
}

class _MovableStackState extends State<MovableStack> {
  late double xPos = widget.xPosition;
  late double yPos = widget.yPosition;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: yPos,
          left: xPos,
          child: GestureDetector(
            onPanUpdate: (tapInfo) {
              setState(() {
                xPos += tapInfo.delta.dx;
                yPos += tapInfo.delta.dy;
              });
            },
            child: Container(
              width: 110,
              height: 640,
              padding: const EdgeInsets.only(top: 590.0),
              child: Image.asset(widget.imagePath),
            ),
          ),
        ),
      ],
    );
  }
}

class HealingScreen extends StatelessWidget {
  const HealingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(140, 69, 164, 232),
          leading: IconButton(
              icon: Image.asset('images/back.png'),
              onPressed: () => Navigator.pop(context)),
          title: const Text('Healing Times'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnatomyScreen(),
                  ),
                );
              },
            ),
          ]),
      body: const HealingWidget(),
    );
  }
}

class HealingWidget extends StatefulWidget {
  const HealingWidget({Key? key}) : super(key: key);

  @override
  State<HealingWidget> createState() => _HealingWidgetState();
}

class _HealingWidgetState extends State<HealingWidget> {
  @override
  Widget build(BuildContext context) {
    // https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html
    // https://medium.flutterdevs.com/expansion-panel-widget-in-flutter-7a331a0865ac
    return ListView.builder(
      itemCount: itemData.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 5.0),
          child: ExpansionPanelList(
            dividerColor: Colors.blue,
            expandedHeaderPadding: const EdgeInsets.only(top: 25.0),
            children: [
              ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Text(
                      itemData[index].headerItem,
                      style: const TextStyle(fontSize: 18),
                    );
                  },
                  body: Text(itemData[index].description),
                  isExpanded: itemData[index].expanded,
                  canTapOnHeader: true)
            ],
            expansionCallback: (int item, bool status) {
              setState(() {
                itemData[index].expanded = !itemData[index].expanded;
              });
            },
          ),
        );
      },
    );
  }

  List<ItemModel> itemData = <ItemModel>[
    ItemModel(
        headerItem: 'Lobe',
        description: 'Location: On the earlobe '
            '                                                                              '
            ' Hardware: Any style of jewellery'
            '                                                                              '
            ' Suggested Healing Time: 1-2 Months'),
    ItemModel(
        headerItem: 'Helix',
        description: 'Location: Rim of upper cartilage '
            '                                                                              '
            ' Hardware: Hoops or studs with standard size being 18G or 16G'
            '                                                                              '
            ' Suggested Healing Time: 6-12 months'),
    ItemModel(
        headerItem: 'Forward Helix',
        description:
            'Location: Portion of upper ear cartilage closest to head is pierced '
            '                                                                              '
            ' Hardware: Stud with flat disc back(labret) or hoops'
            '                                                                              '
            ' Suggested Healing Time: 6-12 Months'),
    ItemModel(
        headerItem: 'Industrial - Anatomy Dependant',
        description:
            'Location: Two piercings going from forward helix to lower section of helix '
            '                                                                              '
            ' Hardware: 14G or 16G industrial barbell'
            '                                                                              '
            ' Suggested Healing Time: 6-12 Months'),
    ItemModel(
        headerItem: 'Tragus - Anatomy Dependant',
        description:
            'Location: Center of cartilage located directly in front of ear canal '
            '                                                                              '
            ' Hardware: Stud with flat disc back(labret) or hoops'
            '                                                                              '
            ' Suggested Healing Time: 4 weeks - 6 months'),
    ItemModel(
        headerItem: 'Anti-Tragus - Anatomy Dependant',
        description: 'Location: Opposite tragus piercing '
            '                                                                              '
            ' Hardware: Stud with flat disc back(labret) or hoops'
            '                                                                              '
            ' Suggested Healing Time: 6-12 Months'),
    ItemModel(
        headerItem: 'Rook - Anatomy dependant',
        description: 'Location: Anti-helix of ear '
            '                                                                              '
            ' Hardware: Curved barbell or hoop'
            '                                                                              '
            ' Suggested Healing Time: 12-18 Months'),
    ItemModel(
        headerItem: 'Daith - Anatomy Dependant',
        description: 'Location: Fold of ear cartilage directly above ear canal '
            '                                                                              '
            ' Hardware: Curved barbell or hoops'
            '                                                                              '
            ' Suggested Healing Time: 4-12 Months'),
    ItemModel(
        headerItem: 'Snug - Anatomy Dependant',
        description:
            'Location: Middle fold of inner ear cartilage towards rim of ear '
            '                                                                              '
            ' Hardware: Small earrings such as curved barbells or hoops'
            '                                                                              '
            ' Suggested Healing Time: 1-12 Months'),
    ItemModel(
        headerItem: 'Flat',
        description: 'Location: Flat area of cartilage below upper rim of ear '
            '                                                                              '
            ' Hardware: Stud with flat disc back(labret)'
            '                                                                              '
            ' Suggested Healing Time: 6-12 Months'),
    ItemModel(
        headerItem: 'Conch',
        description: 'Location: Cartilage at center of ear '
            '                                                                              '
            ' Hardware: Barbells or hoops'
            '                                                                              '
            ' Suggested Healing Time: 12-18 Months'),
    ItemModel(
        headerItem: 'Transverse Lobe - Anatomy Dependant',
        description:
            'Location: From edge of lobe closest to cheek to middle edge of lobe '
            '                                                                              '
            ' Hardware: Curved or straight barbell depending on anatomy'
            '                                                                              '
            ' Suggested Healing Time: 2-10 Months'),
  ];
}

class AftercareScreen extends StatelessWidget {
  const AftercareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () => showAlert(context));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(140, 69, 164, 232),
        leading: IconButton(
            icon: Image.asset('images/back.png'),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Aftercare Advice'),
      ),
      body: const AftercareWidget(),
    );
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => const AlertDialog(
              content: Text(
                  "If you suspect you have an infection visit your piercing practitioner or seek medical attention immediately"),
            ));
  }
}

class AftercareWidget extends StatefulWidget {
  const AftercareWidget({Key? key}) : super(key: key);

  @override
  State<AftercareWidget> createState() => _AftercareWidgetState();
}

class _AftercareWidgetState extends State<AftercareWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: 700.0,
          child: ListView(
            children: ListTile.divideTiles(context: context, tiles: [
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: Image.asset('images/wash.png'),
                    subtitle: const Text(
                        'Wash hands and dry thoroughly before handling piercing,'
                        ' else can cause an infection.'),
                    isThreeLine: true,
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: Padding(
                        padding: const EdgeInsets.only(left: 9.0),
                        child: Image.asset('images/saline.png')),
                    subtitle: const Text(
                        'Clean piercing at least twice a day till healed,'
                        ' should do for a minimum of 4 weeks and whenever piercing is irritated'),
                    isThreeLine: true,
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    subtitle: Text(
                        'Saline solution consists of 250 ml warm water and 1/4 teaspoon sea salt.'
                        ' Soak cotton pad in solution and place on ear for 5 minutes followed by a rinse.'
                        ' Saline solution can also be purchased at drug stores.'),
                    isThreeLine: true,
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Image.asset('images/change.png'),
                    ),
                    subtitle: const Text(
                        'Do not change piercings too soon, earlobe piercings can be changed after min. 6 weeks'
                        ' and cartilage piercings can be changed after min. 12 weeks'),
                    isThreeLine: true,
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: SizedBox(
                            height: 45.0,
                            child: Image.asset('images/swim.png'))),
                    subtitle: const Text(
                        'Avoid swimming till around 4 weeks after your piercing.'
                        ' Also try to avoid swimming in public baths or the sea.'),
                    isThreeLine: true,
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Image.asset('images/sleep.png')),
                    subtitle: const Text(
                        'Avoid sleeping on piercing as this may cause irritation and therefore prolong healing,'
                        ' using a travel pillow to sleep will allow you to suspend healing ear within the hole.'),
                    isThreeLine: true,
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: Image.asset('images/pick.png')),
                    subtitle: const Text(
                        'Do not pick, scratch or fiddle  with piercing as this can lead to scabbing or keloid formation.'
                        ' Any crust that forms around piercing site is the bodys way of protecting it.'),
                    isThreeLine: true,
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    leading: Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: Image.asset('images/cotton.png')),
                    subtitle: const Text(
                        'Do not use cotton wool to clean piercing as fibres may get caught.'),
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    title: Text('Signs of Infection:'),
                    subtitle: Text(
                        '* Swelling and redness increased around wound'
                        '         * Severe burning and throbbing around wound'
                        '         * Increased tenderness and increasingly painful'
                        '         * Unusual discharge(yellow/green) with offensive smell'
                        '                                                                  '
                        '           * High temperature'),
                    isThreeLine: true,
                  )),
              const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: ListTile(
                    subtitle: Text(
                        'If you suspect you have an infection do not take out the piercings as this can cause infection to enter bloodstream.'
                        ' Visit piercing artists or seek medical attention immediately.'),
                    isThreeLine: true,
                  )),
            ]).toList(),
          )),
    ]);
  }
}

class AnatomyScreen extends StatelessWidget {
  const AnatomyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(140, 69, 164, 232),
        leading: IconButton(
            icon: Image.asset('images/back.png'),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Anatomy'),
      ),
      body: const AnatomyWidget(),
    );
  }
}

class AnatomyWidget extends StatefulWidget {
  const AnatomyWidget({Key? key}) : super(key: key);

  @override
  State<AnatomyWidget> createState() => _AnatomyWidgetState();
}

class _AnatomyWidgetState extends State<AnatomyWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: const [
      Center(
        child: Card(
            child: ListTile(
          title: Text('What does Anatomy Dependant mean?'),
          subtitle: Text(
              'Certain piercings require a conversation with your piercing artist first where you will need to discuss the anatomy of your ear.'
              ' This is because some piercings are anatomy specific and require certain features to ensure the piercing can be safely and correctly done.'
              ' If a piercing is anatomy dependant and your piercing artist discovers you do not have the required anatomy then you will be unable to get that piercing.'
              ' The two anatomical factors that determine whether you can get a piercing are shape and size.'),
          isThreeLine: true,
        )),
      )
    ]);
  }
}

class ItemModel {
  bool expanded;
  String headerItem;
  String description;

  ItemModel({
    this.expanded = false,
    required this.headerItem,
    required this.description,
  });
}

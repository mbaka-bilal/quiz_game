import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sqflite/sqflite.dart';

import '../controllers/db.dart';
import '../controllers/questions_map.dart';
import '../controllers/stages_map.dart';
import '../controllers/useful_functions.dart';
import '../controllers/usersinfo_map.dart';
import '../helpers/connect_to_database.dart';
import '../helpers/retrieve_from_database.dart';
import '../views/home.dart';
import '../views/select_user.dart';
import '../views/widgets/doublecurvedcontainer.dart';
import '../views/widgets/gamelevelbutton.dart';
import '../views/widgets/shadowedtext.dart';
import '../views/widgets/shineeffect.dart';

class SelectStage extends StatefulWidget {
  final List<StagesMap> stagesInfo;
  final UsersInfoMap playerInfo;

  SelectStage({Key? key, required this.stagesInfo, required this.playerInfo})
      : super(key: key);

  @override
  _SelectStageState createState() => _SelectStageState();
}

class _SelectStageState extends State<SelectStage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  List<Widget> stagesWidget = [];
  List<StagesMap> listOfStag = [];
  bool isFormerStageCleared = false;
  bool isDisplayAlert = false;
  int accessStage = 0;
  int usersLife = 0;
  List<Widget> widgetList = [];
  int id = 0;
  RetrieveTablesInformation _retrieveTablesInformationObj =
      RetrieveTablesInformation();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initGoogleMobileAds();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.6,
          1.0,
          curve: Curves.easeOut,
        )));

    setStagesInformation();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  Future<List<StagesMap>> getPlayerStagesInfo() async {
    /* get the players stages info */

    List<StagesMap> _playerStagesInfo = [];

    var _dbInstance =
        await ConnectToDatabase(databaseName: widget.playerInfo.playerName)
            .connect();
    var _retrieveInfoDb = RetrieveTablesInformation();

    _playerStagesInfo = await _retrieveInfoDb.playerStagesInfo(_dbInstance);

    return _playerStagesInfo;
  }

  setStagesInformation() async {
    /* retrieve the players information */
    var _obj = RetrieveTablesInformation();
    Database _dbInstance =
        await ConnectToDatabase(databaseName: "playersDB").connect();
    List<UsersInfoMap> playerInformation =
        await _obj.playerInfo(_dbInstance, widget.playerInfo.playerName);
    widgetList = await createWidgeList(await getPlayerStagesInfo(),
        playerInformation[0].livesLeft, playerInformation[0].sound);
    /* done getting the players information */

    setState(() {
      // for some reason build completes before init state, so this as
      // my work around for updating my widgetList.
    });
  }

  // int findIndex(List<QuestionsMap> questions) {
  //   /* TO do
  //     fix the logic of this issue
  //    */

  //   int index = 0;

  //   for (var i in questions) {
  //     //check if user has solved a question keep adding up the count
  //     // else stop once it isn't solve.
  //     if (i.solved == 0) {
  //       index++;
  //     } else {
  //       break;
  //     }
  //   }

  //   if (index == questions.length - 1) {
  //     index =
  //         0; // if user has solved all the questions always restart from the beg
  //   }

  //   // print ("to be returned to position $index");
  //   return index;
  // }

  // int toLastStop(List<QuestionsMap> questions, int index) {
  //   //where should the user resume to?

  //   if (questions.length - 1 == index && questions[index].solved == 0) {
  //     return 0; //back to the first questions if user has solved all the questions in the current stage
  //   } else if (questions.length - 1 == index && questions[index].solved == 1) {
  //     return index;
  //   } else if (questions[index].solved == 0) {
  //     return index +
  //         1; // if question is not the last one and user has solved the current stop move on to the next one
  //   } else {
  //     return index; //if user has not solved the current question;
  //   }
  // }

  Future<List<Widget>> createWidgeList(List<StagesMap> stagesInformation,
      int playerLives, int soundStatus) async {
    List<Widget> tempList = [];
    ConnectToDatabase _connectToDatabaseObj =
        ConnectToDatabase(databaseName: "questions");
    Database _dbInstance = await _connectToDatabaseObj.connect();

    for (int i = 0; i < 20; i++) {
      // if (i == 0) {
      //   tempList.add(
      //     GameLevelButton(
      //       width: 80.0,
      //       height: 60.0,
      //       borderRadius: 50.0,
      //       onTap: () async {
      //         int questionIndex = 0;

      //         List<QuestionsMap> questions =
      //             await DatabaseAccess.stage1Questions();

      //         questionIndex =
      //             findIndex(questions); //get the index of the question

      //         print("The sound status is $soundStatus");

      //         if (mapList[0].locked == 0) {
      //           Navigator.of(context).pushReplacement(createRoute(Home(
      //             playerName: widget.playerName,
      //             questions: questions,
      //             numOfLivesLeft: lives,
      //             stageNumber: 1,
      //             stageName: mapList[0].stagename,
      //             soundState: soundStatus,
      //             userId: id,
      //             usersIndex: toLastStop(questions, listOfStag[0].lastStop),
      //           )));
      //         }
      //       },
      //       text: "Stage 1",
      //       icon: (mapList[i].locked == 0)
      //           ? Icon(
      //               Icons.lock_open,
      //               color: Colors.green,
      //             )
      //           : Icon(
      //               Icons.lock,
      //               color: Colors.red,
      //             ),
      //     ),
      //   );
      // } else {
      tempList.add(GameLevelButton(
        width: 80.0,
        height: 60.0,
        borderRadius: 50.0,
        onTap: () async {
          // int questionIndex = 0;

          List<QuestionsMap> questions = await _retrieveTablesInformationObj
              .getStageQuestions(_dbInstance, i + 1); // get a stage questions

          // print("THe questiosn for the stage ${i} is ${questions}");

          // questionIndex = findIndex(widget.stagesInfo[index]); //get the index for the question

          if (i == 0) {
            Navigator.of(context).pushReplacement(createRoute(Home(
                playerInformation: widget.playerInfo,
                questions: questions,
                numOfLivesLeft: playerLives,
                soundState: soundStatus,
                stageNumber: i + 1,
                stageName: stagesInformation[i].stagename,
                userId: widget.playerInfo.id,

                // if user has solved the last question take the user back to question 1
                // else let the user solve the last question
                usersIndex:
                    ((stagesInformation[i].lastStop == questions.length - 1)
                        ? 0
                        : stagesInformation[i].lastStop))));
          }

          if (i > 0) {
            // print("THe value of number is ${i}");
            if (stagesInformation[i].locked == 0 &&
                stagesInformation[i - 1].locked == 0) {
              Navigator.of(context).pushReplacement(createRoute(Home(
                  playerInformation: widget.playerInfo,
                  questions: questions,
                  numOfLivesLeft: playerLives,
                  soundState: soundStatus,
                  stageNumber: i + 1,
                  stageName: stagesInformation[i].stagename,
                  userId: widget.playerInfo.id,

                  /* fix this !!!! */
                  // if user has solved the last question take the user back to question 1
                  // else let the user solve the last question
                  usersIndex:
                      (stagesInformation[i].lastStop == questions.length - 1)
                          ? 0
                          : stagesInformation[i].lastStop)));
            } else {
              scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
                content: Text("Clear Stage ${i} to unlock"),
              ));
            }

            //   if ((stagesInformation[i].locked == 0 &&
            //       stagesInformation[i - 1].locked == 1) || ()) {
            //     scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
            //       content: Text("Clear Stage ${i} to unlock"),
            //     ));
            //   } else {
            //     Navigator.of(context).pushReplacement(createRoute(Home(
            //         playerInformation: widget.playerInfo,
            //         questions: questions,
            //         numOfLivesLeft: playerLives,
            //         soundState: soundStatus,
            //         stageNumber: i + 1,
            //         stageName: stagesInformation[i].stagename,
            //         userId: widget.playerInfo.id,
            //
            //         /* fix this !!!! */
            //         // if user has solved the last question take the user back to question 1
            //         // else let the user solve the last question
            //         usersIndex:
            //             (stagesInformation[i].lastStop == questions.length - 1)
            //                 ? 0
            //                 : stagesInformation[i].lastStop)));
            //   }
            // }
          }
        },
        text: "Stage ${i + 1}",
        icon: (stagesInformation[i].locked == 0)
            ? Icon(
                Icons.lock_open,
                color: Colors.green,
              )
            : Icon(
                Icons.lock,
                color: Colors.red,
              ),
      ));
    }

    return tempList;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size screenSize = mediaQueryData.size;
    double levelsWidth = -100.0 +
        ((mediaQueryData.orientation == Orientation.portrait)
            ? screenSize.width
            : screenSize.height);

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (_) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              content: Container(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      child: Card(
                        color: Colors.black,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Container(
                                margin: EdgeInsets.all(0.0),
                                width: 200,
                                color: Colors.white30,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color: Colors.white30,
                                    ),
                                    Text(
                                      "Back",
                                      style: TextStyle(
                                        color: Colors.white30,
                                        fontFamily: "Lobster",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Text("Want to quit",
                                style: TextStyle(
                                  color: Colors.white30,
                                  fontFamily: "Lobster",
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.green)),
                                    onPressed: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                          createRoute(SelectUser()),
                                          (Route<dynamic> route) => false);
                                    },
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(
                                        fontFamily: "RoadRage",
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.red)),
                                      onPressed: () {
                                        //The user chooses not to quit the game
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "No",
                                        style: TextStyle(
                                          fontFamily: "RoadRage",
                                          fontSize: 25,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );

        return false;
      },
      child: SafeArea(
          child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/background2.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                top: (_animation.value * 250) + 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: DoubleCurvedContainer(
                    width: screenSize.width - 60.0,
                    height: 150.0,
                    outerColor: Colors.blue.shade700,
                    innerColor: Colors.blue,
                    child: Stack(
                      children: <Widget>[
                        ShineEffect(
                          offset: const Offset(100.0, 100.0),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: ShadowedText(
                            text: 'Word class',
                            color: Colors.white,
                            fontSize: 26.0,
                            shadowOpacity: 1.0,
                            offset: const Offset(1.0, 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    width: levelsWidth,
                    height: levelsWidth,
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: widgetList,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

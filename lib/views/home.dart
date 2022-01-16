import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';

import '../controllers/ad_helper.dart';
import '../controllers/db.dart';
import '../controllers/questions_map.dart';
import '../controllers/stages_map.dart';
import '../controllers/useful_functions.dart';
import '../controllers/usersinfo_map.dart';
import '../helpers/connect_to_database.dart';
import '../helpers/retrieve_from_database.dart';
import '../helpers/update_table.dart';
import '../views/select_stage.dart';
import '../views/widgets/audio.dart';
import '../views/widgets/gamesplash.dart';

class Home extends StatefulWidget {
  final List<QuestionsMap> questions;
  final int numOfLivesLeft;
  final int stageNumber;
  final String stageName;
  final int userId;
  final int usersIndex;
  final int soundState;
  final UsersInfoMap playerInformation;

  const Home({
    Key? key,
    required this.playerInformation,
    required this.questions,
    required this.numOfLivesLeft,
    required this.stageNumber,
    required this.stageName,
    required this.userId,
    required this.usersIndex,
    required this.soundState,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  int currentQuestionIndex = 0;
  List<String> answerArray = [];
  List<String> answerArrayCopy = [];
  List<String> withHintAnswer = [];
  List<bool> buttonStates = [];
  List<String> alphabets = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ];
  var rng = new Random();
  List<String> solution = [];
  List<int> dragTargetIndex = [];
  bool _allowGesture = true;
  late OverlayEntry? _gameSplash;
  List<Widget> a = [];
  int currentLivesLeft = 0;
  String playerAnswer = "";
  List<String> hintArray = [];
  bool showHint = false;
  late BannerAd _bannerAd;
  bool _isBannerReady = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  bool _hintPressed = false;
  bool undoPressed = false;
  bool _isGetLives = false;
  late Timer bannerTimer;
  late Timer rewardTimer;
  int lastPosition = 0;
  String lastLetter = "";
  bool undo = false;
  bool isWumupsCryButtonPressed = false;
  bool isWumupsCryButtonActive = false;
  int indexOfLivesPressed = 0;
  List<Widget> livesList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentIndex = 0; //keep track of occupied answer box
  int currentHintIndex = 0;
  Color notClickedColor =
      Colors.white; //the color for when my option was not clicked
  Color clickedColor =
      Colors.green.shade300; //the color for when my option has been clicked
  List<int> lastButtonClicked = [];
  List<int> hintLocations = []; // all the locations of the hint in the array
  List<int> noHintLocations = []; // all the locations without hint in the array
  bool isTryAgain = false;
  bool isLifeFinishedDialogActive = false;
  StreamController<List<int>>? _events;
  int minutes = 0;
  bool isLifeFinishedButton = false;
  bool _isSoundOn = true;
  List<StagesMap> playerStagesInfo = [];
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldMessengerState> popUpScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  Future<List<Widget>>? createOptionsFuture;
  List<Widget> _answerOptionsWidgets = [];
  List<String> answerList = [];
  AudioPlayer cutestBunnySound = AudioPlayer();
  late AppLifecycleState _notification;

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  void getPlayerStagesInfo() async {
    /* get the players stages info */

    var _dbInstance = await ConnectToDatabase(
            databaseName: widget.playerInformation.playerName)
        .connect();
    var _retrieveInfoDb = RetrieveTablesInformation();

    playerStagesInfo = await _retrieveInfoDb.playerStagesInfo(_dbInstance);
  }

  Future<void> updateLife() async {
    DateTime lastDate;
    int minutesDifference;

    //get the last date
    currentLivesLeft = widget.numOfLivesLeft;
    var _dbInstance =
        await ConnectToDatabase(databaseName: "playersDB").connect();
    lastDate = DateTime.parse(
        await RetrieveTablesInformation().getPlayerLastPlayTime(_dbInstance));

    //increment the life depending on the number of hours that has passed
    // since the user last played the game with at least 1 life

    minutesDifference = (DateTime.now().difference(lastDate).inMinutes).abs();

    while (currentLivesLeft < 5 && (minutesDifference >= 10)) {
      updatePlayerLifeStatus(true);
      minutesDifference = (minutesDifference ~/ 10);
    }
  }

  void updateStageInfomation(String dbName) async {
    var _dbInstance = await ConnectToDatabase(databaseName: dbName).connect();
    var _retrieveInfoDb = RetrieveTablesInformation();
    /* get the selected player stages information */
    playerStagesInfo = await _retrieveInfoDb.playerStagesInfo(_dbInstance);
    /* done getting the selected player stages inforamation */

    /* update the last stop for the user in any given stage */
    UpdateTableInformation updateTableInfoObj = UpdateTableInformation();
    updateTableInfoObj.updateTable("stagesInformation",
        {"laststop": currentQuestionIndex}, (widget.stageNumber - 1),
        db: _dbInstance);
    /* done updating the players last stop */
  }

  void updateClearedStageInformation(String dbName, int stageNumber) async {
    /* change the state of a stage to cleared */
    var _dbInstance = await ConnectToDatabase(databaseName: dbName).connect();
    UpdateTableInformation updateTableInfoObj = UpdateTableInformation();
    updateTableInfoObj.updateTable(
        "stagesInformation", {"locked": 0}, stageNumber - 1,
        db: _dbInstance);
  }

  void updatePlayerSoundStatus(String dbName, int status) async {
    /* set the sound to on or off */
    var _dbInstance =
        await ConnectToDatabase(databaseName: "playersDB").connect();
    UpdateTableInformation _updateTableInfoDb = UpdateTableInformation();
    _updateTableInfoDb.updateTable("players", {"sound": status}, widget.userId,
        db: _dbInstance);
  }

  void updatePlayerLifeStatus(bool action) async {
    /* if it is true increment the life, else decrement the life by 1 */
    int _playerLife = 0;

    if (action) {
      _playerLife = currentLivesLeft + 1;
      currentLivesLeft = currentLivesLeft + 1;
    } else {
      _playerLife = currentLivesLeft - 1;
      currentLivesLeft = currentLivesLeft - 1;
    }

    var _dbInstance =
        await ConnectToDatabase(databaseName: "playersDB").connect();
    UpdateTableInformation _updateTableInfoDb = UpdateTableInformation();
    _updateTableInfoDb.updateTable("players",
        {"life": (action) ? _playerLife : _playerLife}, widget.userId,
        db: _dbInstance);
  }

  void stageClearedLifeUpdate() async {
    /* give user 2 lives for clearing a stage */
    int _playerLife = 0;

    if (currentLivesLeft < 4) {
      _playerLife = currentLivesLeft + 2;
      currentLivesLeft = currentLivesLeft + 2;
    } else if (currentLivesLeft == 4) {
      _playerLife = currentLivesLeft + 1;
      currentLivesLeft = currentLivesLeft + 1;
    } else {
      _playerLife = 5;
    }

    var _dbInstance =
        await ConnectToDatabase(databaseName: "playersDB").connect();
    UpdateTableInformation _updateTableInfoDb = UpdateTableInformation();
    _updateTableInfoDb.updateTable(
        "players", {"life": _playerLife}, widget.userId,
        db: _dbInstance);
  }

  void updateTime() async {
    var _dbInstance =
        await ConnectToDatabase(databaseName: "playersDB").connect();
    UpdateTableInformation _updateTableInfoDb = UpdateTableInformation();
    _updateTableInfoDb.updateTable(
        "players", {"date": DateTime.now().toString()}, widget.userId,
        db: _dbInstance);
  }

  lifeFinished(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return ScaffoldMessenger(
            key: popUpScaffoldMessengerKey,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: AlertDialog(
                backgroundColor: Color(0xFF255958),
                actionsPadding: EdgeInsets.all(0),
                actionsOverflowButtonSpacing: 0,
                content: StreamBuilder<List<int>>(
                    initialData: [1],
                    stream: _events!.stream,
                    builder: (context, snapshot) {
                      return Container(
                        height: 200,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(padding: EdgeInsets.only(right: 10)),
                                Text("You get a life in 30 Minutes")
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 10)),
                            Container(
                                width: 90,
                                height: 90,
                                child:
                                    Image.asset("lib/images/wumpus_cry.gif")),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: (isWumupsCryButtonPressed)
                                        ? null
                                        : () {
                                            isWumupsCryButtonPressed = true;
                                            isWumupsCryButtonActive = true;
                                            isLifeFinishedButton = true;
                                            setState(() {});

                                            _loadRewardedAd(context);

                                            resetGame();
                                          },
                                    child: Stack(children: [
                                      Text("Get A life"),
                                      (snapshot.data![0] == 0)
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Container()
                                    ])),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.red)),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      if (_isRewardedAdReady) {
                                        _rewardedAd!.dispose();
                                      }
                                      _events!.close();
                                      updateStageInfomation(
                                          widget.playerInformation.playerName);
                                      Audio.stopAsset(
                                          cutestBunnySound); //stop all music
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          createRoute(SelectStage(
                                            stagesInfo: playerStagesInfo,
                                            playerInfo:
                                                widget.playerInformation,
                                          )),
                                          (route) => false);
                                    },
                                    child: Text("Exit")),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
          );
        }).then((value) {
      if (currentLivesLeft == 0) {
        updateStageInfomation(widget.playerInformation.playerName);
        Audio.stopAsset(cutestBunnySound); //stop all music
        Navigator.of(context).pushAndRemoveUntil(
            createRoute(SelectStage(
              stagesInfo: playerStagesInfo,
              playerInfo: widget.playerInformation,
            )),
            (route) => false);
      } else {
        //refresh the page, meaning the user must have requested for more life
        setState(() {});
      }
    });
  }

  void checkAnswer() {
    if (showHint) {
      // if the user want to see a hint
      if (currentIndex == noHintLocations.length) {
        // if the hint index equals the non Arrayed part

        if (withHintAnswer.join("") ==
            widget.questions[currentQuestionIndex].answer) {
          bool toNextQuestion =
              ((widget.questions.length - 1) == currentQuestionIndex)
                  ? true
                  : false; //Is user at the maximum question for that stage

          (!toNextQuestion)
              ? setState(() {
                  /* Logic if the user gets this question move on to the next one */
                  //play an audio
                  if (_isSoundOn) {
                    Audio.playAsset(AudioType.swap);
                  } else {
                    null;
                  }

                  //save the progress of the player
                  updateStageInfomation(widget.playerInformation.playerName);
                  currentQuestionIndex++;
                  shuffleAnswer(currentQuestionIndex);
                  showHint = false;
                  resetGame();
                })
              : showDialog(
                  context: context,
                  builder: (_) {
                    if (_isSoundOn) {
                      Audio.playAsset(AudioType.win);
                    } else {
                      null;
                    }
                    /* update the stage status because the user has answered all questions correctly */
                    // we assume that the for the user to reach this point the user must have
                    // answered all the questions correctly

                    return nextStageDialog();
                  });
        } else {
          if (_isSoundOn) {
            Audio.playAsset(AudioType.lost);
          } else {
            null;
          }

          //user failed the question
          updatePlayerLifeStatus(false); //decrement the life in the database

          // if lives left is 0, show the alertdialog without the option to tryagain
          // else show the alert dialog with option to try again

          (currentLivesLeft == 0)
              ? setState(
                  () {}) // rebuild the page, it will make the alertDialog build
              : showDialog(
                  barrierColor: Colors.transparent,
                  barrierDismissible: false,
                  context: (context),
                  builder: (_) {
                    return Alert(currentLivesLeft, context);
                  }).then((value) {
                  //incase the player clicks the back button on mobile phone
                  // instead of the one in the app.
                  resetGame();
                });

          createLives(currentLivesLeft);
        }
      }
    } else {
      if (currentIndex ==
          widget.questions[currentQuestionIndex].answer.length) {
        if (playerAnswer == widget.questions[currentQuestionIndex].answer) {
          bool toNextQuestion =
              ((widget.questions.length - 1) == currentQuestionIndex)
                  ? true
                  : false; //Is user at the maximum question for that stage

          (!toNextQuestion)
              ? setState(() {
                  /* Logic if the user gets this question move on to the next one */
                  //play an audio
                  if (_isSoundOn) {
                    Audio.playAsset(AudioType.swap);
                  } else {
                    null;
                  }

                  //save the progress of the player
                  updateStageInfomation(widget.playerInformation.playerName);

                  currentQuestionIndex++;
                  shuffleAnswer(currentQuestionIndex);
                  resetGame();
                })
              : showDialog(
                  context: context,
                  builder: (_) {
                    if (_isSoundOn) {
                      Audio.playAsset(AudioType.win);
                    } else {
                      null;
                    }
                    /* update the stage status because the user has answered all questions correctly */
                    // we assume that the for the user to reach this point the user must have
                    // answered all the questions correctly

                    return nextStageDialog();
                  });
        } else {
          if (_isSoundOn) {
            Audio.playAsset(AudioType.lost);
          } else {
            null;
          }

          //user failed the question
          updatePlayerLifeStatus(
              false); //decrement the life in the database and in the current game
          showHint = false;

          // if lives left is 0, show the alertdialog without the option to tryagain
          // else show the alert dialog with option to try again

          (currentLivesLeft == 0)
              ? setState(() {})
              : showDialog(
                  barrierColor: Colors.transparent,
                  barrierDismissible: false,
                  context: (context),
                  builder: (_) {
                    return Alert(currentLivesLeft, context);
                  }).then((value) {
                  //incase the player clicks the back button on mobile phone
                  // instead of the one in the app.

                  resetGame();
                });

          createLives(currentLivesLeft);
        }
      }
    }
  }

  void createHint(String answer) {
    /* function to create the hint */
    hintLocations = [];
    String hintText = widget.questions[currentQuestionIndex].hint;
    showHint = true;
    currentIndex = 0;

    noHintLocations = [];
    withHintAnswer = [];
    a = [];

    resetButtonState(); //remove all colors from the button

    for (int i = 0; i < answer.length; i++) {
      //create the answer array
      withHintAnswer.add("o");

      // get the locations of the hint and store it in an array
      if (hintText.contains(answer[i])) {
        hintLocations.add(i);
      } else {
        noHintLocations.add(i);
      }
    }

    answerGaps();

    for (int i = 0; i < a.length; i++) {
      // find all the locations of hint and replace it
      if (hintLocations.contains(i)) {
        withHintAnswer[i] = answer[i]; //create the answer for hint

        a[i] = Container(
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(
            answer[i],
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                fontFamily: "Lobster"),
          ),
        );
      }
    }

    setState(() {});
  }

  void shuffleAnswer(int index) {
    answerList = [];
    if (widget.questions[index].answer.length < 9) {
      for (int i = 0; i < 2; i++) {
        answerList.add(alphabets[rng.nextInt(alphabets.length - 1)]);
      }
      answerList.addAll(widget.questions[index].answer.split(""));
    } else {
      answerList = widget.questions[index].answer.split("");
      answerList.shuffle(); //shuffle the options
    }
  }

  List<Widget> createOptions() {
    /* function to create the options for user to press as solution */
    buttonStates = [];
    _answerOptionsWidgets = [];

    for (int index = 0; index < answerList.length; index++) {
      buttonStates.add(false); //initialize the buttonStates to all false
    }

    for (int index = 0; index < answerList.length; index++) {
      _answerOptionsWidgets.add(Container(
          padding: const EdgeInsets.all(5.0),
          width: 10,
          height: 10,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              if (_isSoundOn) {
                Audio.playAsset(AudioType.click_sound);
              } else {
                null;
              }

              buttonStates[index] = true; //change the color of the button
              lastButtonClicked.add(index); // so undo can work

              if (showHint) {
                /* if the user has activated the hint */
                // int location = noHintLocations[currentHintIndex];

                a[noHintLocations[currentIndex]] = Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(
                    answerList[index],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: "Lobster"),
                  ),
                );

                // get the location of the array that is empty and place
                // the letter in that location
                withHintAnswer[noHintLocations[currentIndex]] =
                    answerList[index];

                // currentHintIndex++; //increase the hint location.
                currentIndex++;
                checkAnswer();
                setState(() {});
              } else {
                // hint is not on
                a[currentIndex] = Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(
                    answerList[index],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: "Lobster"),
                  ),
                );
                playerAnswer = playerAnswer + answerList[index];
                currentIndex++;
                setState(() {});
                checkAnswer();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: (buttonStates[index]) ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(
                answerList[index],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: "Lobster"),
              ),
            ),
          )));
    }

    setState(() {});

    return _answerOptionsWidgets;
  }

  void answerGaps() {
    for (int i = 0;
        i < widget.questions[currentQuestionIndex].answer.length;
        i++) {
      a.add(Container(
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(""),
      ));
    }
  }

  void _showGameStartSplash(_) {
    // No gesture detection during the splash
    _allowGesture = false;

    // Show the splash
    _gameSplash = OverlayEntry(
        opaque: false,
        builder: (BuildContext context) {
          return GameSplash(
            audioStatus: _isSoundOn,
            level: widget.stageNumber.toString(),
            onComplete: () {
              _gameSplash!.remove();
              _gameSplash = null;

              // allow gesture detection
              _allowGesture = true;
            },
          );
        });

    Overlay.of(context)!.insert(_gameSplash!);
  }

  // void answerToArray(String answer) {
  //   /* turn the answer to an array of answers */
  //   this.answerArray = [];

  //   for (int i = 0; i < answer.length; ++i) {
  //     this.answerArray.add(answer[i]);
  //   }
  //   this.answerArrayCopy = this.answerArray;

  //   //create the options for the users
  // }

  Widget Alert(int numOfLives, BuildContext context) {
    /* The dialog with an option to quit the game or try again */
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
                    Container(
                      width: 200,
                      color: Colors.white30,
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.white30),
                        ],
                      ),
                    ),
                    Text(
                      "InCorrect",
                      style: TextStyle(
                        color: Colors.white30,
                        fontFamily: "Lobster",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green)),
                              onPressed: () {
                                // isTryAgain = true;
                                resetGame();
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Try Again",
                                style: TextStyle(
                                  fontFamily: "RoadRage",
                                  fontSize: 25,
                                ),
                              )),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green)),
                              onPressed: () {
                                updateStageInfomation(
                                    widget.playerInformation.playerName);
                                Audio.stopAsset(
                                    cutestBunnySound); //stop all music
                                Navigator.of(context)
                                    .pushReplacement(createRoute(SelectStage(
                                  stagesInfo: playerStagesInfo,
                                  playerInfo: widget.playerInformation,
                                )));
                              },
                              child: Text(
                                "Quit",
                                style: TextStyle(
                                  fontFamily: "RoadRage",
                                  fontSize: 25,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nextStageDialog() {
    return Container(
      child: AlertDialog(
        insetPadding: EdgeInsets.all(0),
        backgroundColor: Colors.transparent,
        content: Container(
          height: 100,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded(
                    //   child: IconButton(
                    //     //replay the level
                    //     onPressed: () async {
                    //       currentQuestionIndex = 0;
                    //       this.showHint =
                    //       false;
                    //       setState(() {
                    //          //reset the show hint option to be false;
                    //         // guessesArray = [];
                    //         // answerArrayCopy = [];
                    //         // answerArray = [];
                    //
                    //       });
                    //       resetGame();
                    //
                    //       updateClearedStageInformation(
                    //           widget.playerInformation.playerName,widget.stageNumber);
                    //       updateClearedStageInformation(widget.playerInformation.playerName, widget.stageNumber + 1);
                    //
                    //       Navigator.of(context).pop();
                    //     },
                    //     icon: Icon(
                    //       Icons.repeat,
                    //       color: Colors.red,
                    //     ),
                    //     iconSize: 45,
                    //   ),
                    // ),
                    // Padding(
                    //   padding: EdgeInsets.only(right: 10),
                    // ),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          // await DatabaseAccess.updateTable(
                          //     "stages", {"done": 0}, widget.stageNumber - 1);

                          // await DatabaseAccess.updateTable(
                          //     // change the state of the current question to answered
                          //     "stage${widget.stageNumber}",
                          //     {"solved": 0},
                          //     widget.questions[currentQuestionIndex].id);

                          // await DatabaseAccess.updateTable(
                          //     //save the progress of the player
                          //     "stages",
                          //     {"laststop": currentQuestionIndex},
                          //     (widget.stageNumber - 1));

                          // // we assume that the for the user to reach this point the user must have
                          // // answered all the questions correctly
                          // await DatabaseAccess.updateTable(
                          //     "stages", {"done": 0}, widget.stageNumber - 1);

                          // DatabaseAccess.updateTable("stages", {"locked": 0},
                          //     widget.stageNumber); //unlock the next stage

                          // Give user 2 extra lives for passing a stage
                          // if (this.currentLivesLeft < 4) {
                          //   await DatabaseAccess.updateTable(
                          //       "users",
                          //       {"life": (this.currentLivesLeft + 2)},
                          //       widget.userId);
                          //
                          //   this.currentLivesLeft + 2;
                          // } else if (this.currentLivesLeft == 4) {
                          //   await DatabaseAccess.updateTable(
                          //       "users",
                          //       {"life": (this.currentLivesLeft + 1)},
                          //       widget.userId);
                          //
                          //   this.currentLivesLeft++;
                          // }

                          stageClearedLifeUpdate();

                          updateClearedStageInformation(
                              widget.playerInformation.playerName,
                              widget.stageNumber);
                          updateClearedStageInformation(
                              widget.playerInformation.playerName,
                              widget.stageNumber + 1);
                          Audio.stopAsset(cutestBunnySound); //stop all music
                          Navigator.of(context)
                              .pushReplacement(createRoute(SelectStage(
                            stagesInfo: playerStagesInfo,
                            playerInfo: widget.playerInformation,
                          )));
                        },
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Colors.green,
                        ),
                        iconSize: 45,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void undoLastEntry() {
    if (showHint) {
      // logic if the user has enabled the hint
      if (currentHintIndex > 0) {
        //because each time the user presses a button
        // the index is increased by a value of 1

        // List<int> tempLast =
        //     lastButtonClicked.removeLast(); //remove the last entry from
        // the list of clicked buttons

        //uncolor the last option entry
        // buttonStates[tempLast[0]][tempLast[1]] = false;

        print("THe value of ?????? ${currentHintIndex}");

        a[noHintLocations[currentHintIndex - 1]] = Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(""),
        ); //remove the last entry from the visible user entered box

        //remove the last answer

        currentHintIndex--; //reduce the number of currentHintIndex

      }
    } else {
      if (playerAnswer.length > 0) {
        //as long as player has tapped an option
        // List<int> tempLast = lastButtonClicked.removeLast();

        //undo the players last entry
        playerAnswer = playerAnswer.substring(0,
            playerAnswer.length - 1); //remove the last letter from the answer
        a[currentIndex - 1] = Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(""),
        ); //remove the last option entry

        currentIndex--; //reduce the current index by 1

        //uncolor the last option entry
        // buttonStates[tempLast[0]][tempLast[1]] = false;
      }
    }
  }

  void resetGame() {
    /* reset the game so the user can try again */

    // if player failed the question
    playerAnswer = ""; //reset the players answer
    // guessesArray = []; //reset the guesses
    a = []; //empty the array that displays the pressed buttons
    solution = []; //empty the solutions array
    hintArray = []; //reset the hints array

    answerList.shuffle(); //shuffle the options

    undoPressed = false;
    currentIndex = 0;
    currentHintIndex = 0;

    createOptions();
    createLives(currentLivesLeft);

    setState(() {});

    //if the user has
    // already wanted to see hint keep hint on always.
    if (showHint) {
      createHint(widget.questions[currentQuestionIndex].answer);
    } else {
      answerGaps();
    }

    resetButtonState();
    // answerToArray(widget.questions[currentQuestionIndex].answer);
  }

  resetButtonState() {
    //change all the colors of the button back to the original state
    for (int i = 0; i < buttonStates.length; i++) {
      for (int v = 0; v < 5; v++) {
        // buttonStates[i][v] = false;
      }
    }

    setState(() {});
  }

  createLives(int lives) {
    /* Create the lives list */
    livesList = [];

    if (lives > 5) {
      print("Error lives is greater than 5////////////////");
    }

    for (int i = 1; i <= 5; i++) {
      //create the five default hearts
      if (i <= lives) {
        // while we are still in good lives
        livesList.add(Icon(
          Icons.favorite,
          color: Colors.red,
          size: 23,
        ));
        // });
      } else {
        //if no more lives add the get life icon.
        livesList.add(GestureDetector(
            onTap: () {
              getMoreLife(context, i - 1);
            },
            child: HeartIcon(isClicked: false) // the hearts widget
            ));
        // });
      }
    }

    setState(() {});
  }

  void getMoreLife(BuildContext context, int index) {
    // replace the pressed heart with a loading heart temporarily

    livesList[index] = HeartIcon(isClicked: true);
    _isGetLives = true;
    setState(() {});

    _loadRewardedAd(context);
  }

  // lifeFinished(BuildContext context) {

  // }

  Timer? _timer;

  Future<void> _startTimer() async {
    _events = new StreamController<List<int>>.broadcast();
    // _counter = 60;
    // minutes = 30;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // if (minutes == 0) {
      //   if (_timer != null) {
      //     _timer!.cancel();
      //   }
      //   // since 30 minutes has elased increment time **/
      //   DatabaseAccess.updateTable(
      //       "users", {"life": (currentLivesLeft + 1)}, widget.userId);
      // } else {
      //   _counter--;
      //   if (_counter == 0) {
      //     _counter = 60;
      //     minutes--;
      //   }
      // }

      _events!.add([(isWumupsCryButtonPressed) ? 0 : 1]);
    });
  }

  void _loadBannerAd() {
    this._bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerReady = true;
          });
        }, onAdFailedToLoad: (ad, err) {
          _isBannerReady = false;
          ad.dispose();
        }));
  }

  void _loadRewardedAd(BuildContext context) {
    //get a reward ad ready

    if (MobileAds.instance == null) {
      MobileAds.instance.initialize();
    }

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          // setState(() {});
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Container(
                    child: ElevatedButton(
                      child: Text("Get reward"),
                      onPressed: () {
                        if (_isRewardedAdReady) {
                          _rewardedAd!.show(
                            onUserEarnedReward:
                                (RewardedAd ad, RewardItem item) {
                              if (_hintPressed) {
                                /* handle creation of hint */
                                createHint(widget
                                    .questions[currentQuestionIndex].answer);
                                showHint = true;
                                _hintPressed = false;
                                setState(() {});
                              }

                              if (_isGetLives) {
                                /* handle getting of a new life from the heart icons in game play */
                                // DatabaseAccess.updateTable(
                                //     "users",
                                //     {"life": (currentLivesLeft + 1)},
                                //     widget
                                //         .userId); //give the user one extra life

                                // print("In get lives part //////////////////");

                                updatePlayerLifeStatus(
                                    true); //give the user one extra life

                                // currentLivesLeft++; //increase the current lives by 1

                                _isGetLives = false;

                                setState(() {});

                                createLives(currentLivesLeft);
                              }

                              if (isLifeFinishedButton) {
                                /* handle getting a new life when life has finished */

                                // DatabaseAccess.updateTable(
                                //     "users",
                                //     {"life": (currentLivesLeft + 1)},
                                //     widget
                                //         .userId); //give the user one extra life

                                updatePlayerLifeStatus(
                                    true); //give the user one extra life

                                // currentLivesLeft++; //increase the current lives by 1

                                print(
                                    "The number of lives is ////////////// $currentLivesLeft");

                                isWumupsCryButtonPressed = false;
                                isWumupsCryButtonActive = false;

                                setState(() {});

                                createLives(currentLivesLeft);
                              }
                            },
                          );

                          _rewardedAd!.fullScreenContentCallback =
                              FullScreenContentCallback(
                                  onAdShowedFullScreenContent: (ad) {
                            _isRewardedAdReady =
                                false; // so we can get a new Ad
                            // if (_isSoundOn) {
                            //   Audio.stopAsset(cutestBunnySound);
                            // }
                            if (_timer != null) {
                              _timer!.cancel();
                            }
                            setState(() {});
                          }, onAdDismissedFullScreenContent: (ad) async {
                            _isRewardedAdReady = false;
                            _isGetLives = false;

                            // if (_isSoundOn) {
                            //   Audio.init();
                            //   cutestBunnySound = await Audio.playAsset(
                            //       AudioType.the_cutest_bunny); //play the sound
                            // }

                            // if (_isSoundOn) {
                            //   Audio.stopAsset(cutestBunnySound);
                            // }

                            if (_timer != null) {
                              _timer!.cancel();
                            }

                            setState(() {});

                            Navigator.of(context)
                                .pop(); //remove the alert dialog

                            if (isLifeFinishedButton) {
                              Navigator.of(context)
                                  .pop(); // if user has recevied a life

                              // remove the alertDialog
                              // isLifeFinishedButton = false;

                            }

                            _rewardedAd!.dispose();
                          }, onAdFailedToShowFullScreenContent: (ad, error) {
                            _rewardedAd!.dispose();
                            setState(() {});
                          });
                        }
                      },
                    ),
                  ),
                );
              }).then((value) {
            _hintPressed = false;
            _isRewardedAdReady = false;
            _isGetLives = false;
            isWumupsCryButtonPressed = false;
            isWumupsCryButtonActive = false;
            setState(() {});
          });
        },
        onAdFailedToLoad: (err) {
          if (_rewardedAd != null) {
            _rewardedAd!.dispose();
          }

          _isRewardedAdReady = false;
          // isWumupsCryButtonActive = false;
          // _isLoadingRewardAd = false;
          _hintPressed = false;
          _isGetLives = false;

          if (isLifeFinishedButton) {
            popUpScaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
              content: Text("No Internet"),
            ));

            // isLifeFinishedDialogActive = false;
            isWumupsCryButtonPressed = false;

            // Navigator.of(context).pop();

            setState(() {});

            // Navigator.of(popUpScaffoldMessengerKey).pop();

            // Navigator.of(context).pop();
          } else {
            scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
              content: Text("No Internet"),
            ));

            setState(() {});

            createLives(currentLivesLeft);
          }
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState

    _notification = state;

    print("the notification is ------------------ $_notification");
    if (_notification == AppLifecycleState.paused) {
      if (_isSoundOn) {
        cutestBunnySound.pause();
      }
    }
    if (_notification == AppLifecycleState.resumed) {
      if (_isSoundOn) {
        print("resumed ---------------------");
        cutestBunnySound.resume();
      } else {
        return;
        print("sound is off------------");
      }
    }

    if (_notification == AppLifecycleState.inactive) {
      if (_isSoundOn) {
        print("It has been detached-----------");
        cutestBunnySound.stop();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback(_showGameStartSplash);
    WidgetsBinding.instance!.addObserver(this);
    print("THe user life left is ${widget.numOfLivesLeft}");
    // optionsFuture(); //create the future for the FutureBulilder widget, so it will not rebuild
    shuffleAnswer(widget.usersIndex); //shuffle the answer
    createOptions();
    getPlayerStagesInfo();
    updateLife();

    // answerToArray(widget.questions[widget.usersIndex].answer);

    // currentLivesLeft = widget.numOfLivesLeft;
    currentQuestionIndex = widget
        .usersIndex; //set the index the user was at so the user can continue

    _initGoogleMobileAds();

    _loadBannerAd();

    answerGaps();

    _bannerAd.load();

    bannerTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (!_isBannerReady) {
        _loadBannerAd();
        _bannerAd.load();
      }
    });

    createLives(currentLivesLeft);

    if (widget.soundState == 1) {
      _isSoundOn = false;
      Audio.stopAsset(cutestBunnySound);
    } else {
      _isSoundOn = true;
      Audio.init();
      initializeBackgroundMusic();
    }
  }

  Future<void> initializeBackgroundMusic() async {
    cutestBunnySound = await Audio.playAsset(AudioType.the_cutest_bunny);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    bannerTimer.cancel();
    if (_timer != null) {
      _timer!.cancel();
    }
    if (_isRewardedAdReady) {
      _rewardedAd!.dispose();
    }

    Audio.stopAsset(cutestBunnySound); //stop all music
  }

  @override
  Widget build(BuildContext context) {
    // print("THe state of lifeFinished is $isLifeFinishedDialogActive");
    // print("The state of currentLives is $currentLivesLeft");
    Future.delayed(Duration.zero, () async {
      if (currentLivesLeft == 0 && !isLifeFinishedDialogActive) {
        // only show this dialog when isLifeFinishedDialogActive is false
        // else this dialog keeps building on each call to buil
        // and this app calls build a lot !!!! "Smiley,, smiley"
        // maybe use PostFrameCallBack?, it works like this so i didn't have
        // a reason to change it.

        // @thepocketmerlin

        await _startTimer();

        lifeFinished(context);
        isLifeFinishedDialogActive = true;
      }
    });

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
                                      if (_rewardedAd != null) {
                                        _rewardedAd!.dispose();
                                      }

                                      bannerTimer.cancel();
                                      // rewardTimer.cancel();

                                      _isRewardedAdReady = false;

                                      //increment the time every time the user quits the game
                                      updateTime();
                                      // DatabaseAccess.updateTable(
                                      //     "users",
                                      //     {"date": DateTime.now().toString()},
                                      //     widget.userId);

                                      //the user chooses to quit the game, take the user back to the select stage page
                                      updateStageInfomation(
                                          widget.playerInformation.playerName);
                                      Audio.stopAsset(
                                          cutestBunnySound); //stop all music
                                      Navigator.of(context).pushAndRemoveUntil(
                                          createRoute(SelectStage(
                                            stagesInfo: playerStagesInfo,
                                            playerInfo:
                                                widget.playerInformation,
                                          )),
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
            key: _scaffoldKey,
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        // color: Colors.red,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              "lib/images/background.jpg",
                            ))),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 7.0, top: 5, left: 5, right: 5),
                          child: //Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // children: [
                              Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              decoration: BoxDecoration(),
                              width: 120,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: GestureDetector(
                                            onTap: () async {
                                              showDialog(
                                                barrierColor:
                                                    Colors.transparent,
                                                context: context,
                                                builder: (_) {
                                                  return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    content: Container(
                                                      height: 200,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: Card(
                                                              color:
                                                                  Colors.black,
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            0.0),
                                                                    child:
                                                                        Container(
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              0.0),
                                                                      width:
                                                                          200,
                                                                      color: Colors
                                                                          .white30,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.home,
                                                                            color:
                                                                                Colors.white30,
                                                                          ),
                                                                          Text(
                                                                            "Back",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white30,
                                                                              fontFamily: "Lobster",
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      "Want to quit",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white30,
                                                                        fontFamily:
                                                                            "Lobster",
                                                                        fontSize:
                                                                            30,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      )),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          style:
                                                                              ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                                                                          onPressed:
                                                                              () async {
                                                                            //the user chooses to quit the game, take the user back to the select stage page
                                                                            var _dbInstance =
                                                                                await ConnectToDatabase(databaseName: widget.playerInformation.playerName).connect();
                                                                            var _retrieveInfoDb =
                                                                                RetrieveTablesInformation();
                                                                            /* get the selected player stages information */
                                                                            List<StagesMap>
                                                                                _stagesInformation =
                                                                                await _retrieveInfoDb.playerStagesInfo(_dbInstance);

                                                                            updateStageInfomation(widget.playerInformation.playerName);
                                                                            Audio.stopAsset(cutestBunnySound); //stop all music
                                                                            Navigator.of(context).pushReplacement(createRoute(SelectStage(
                                                                              stagesInfo: playerStagesInfo,
                                                                              playerInfo: widget.playerInformation,
                                                                            )));
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            "Yes",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: "RoadRage",
                                                                              fontSize: 25,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        ElevatedButton(
                                                                            style:
                                                                                ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
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
                                            },
                                            child: Icon(Icons.home,
                                                color: Colors.white38,
                                                size: 30)),
                                      ),
                                    ],
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 13)),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: livesList,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Padding(padding: EdgeInsets.only(bottom: 5)),
                          // ],
                          // ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  if (_isSoundOn) {
                                    updatePlayerSoundStatus(
                                        widget.playerInformation.playerName, 1);
                                    _isSoundOn = false;

                                    Audio.stopAsset(cutestBunnySound);
                                  } else {
                                    updatePlayerSoundStatus(
                                        widget.playerInformation.playerName, 0);
                                    _isSoundOn = true;
                                    Audio.init();
                                    cutestBunnySound = await Audio.playAsset(
                                        AudioType
                                            .the_cutest_bunny); //play the sound
                                  }
                                  setState(() {});
                                },
                                child: Icon(
                                  (_isSoundOn)
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                  color: Colors.white38,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: (this._hintPressed)
                                ? null
                                : () {
                                    _hintPressed = true;

                                    setState(() {});

                                    _loadRewardedAd(context);
                                  },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                  height: 70,
                                  width: 50,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                            "lib/images/bulb_light_bulb.gif"),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text("HINT",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF228B22),
                                            )),
                                      ),
                                      if (this._hintPressed)
                                        CircularProgressIndicator()
                                    ],
                                  )),
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                    width: 5.0,
                                    color: Colors.black.withOpacity(0.5)),
                              ),
                              width: MediaQuery.of(context).size.width / 1.02,
                              height: MediaQuery.of(context).size.height / 1.4,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Question ${currentQuestionIndex + 1}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "RoadRage",
                                      fontSize: 60,
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 2)),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    child: Text(
                                      widget.questions[currentQuestionIndex]
                                          .question,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                        fontFamily: "RoadRage",
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: Answers(
                                          key: UniqueKey(), answerLength: a)),
                                  if (_isBannerReady)
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 50,
                                      child: Container(
                                        child: AdWidget(ad: _bannerAd),
                                      ),
                                    ),
                                  Expanded(
                                      child: OptionsWidget(
                                          key: UniqueKey(),
                                          answerOptionsWidgets:
                                              _answerOptionsWidgets)
                                      // child: FutureBuilder(
                                      //   future: createOptionsFuture,
                                      //   initialData: Null,
                                      //   builder: (ctx, snapShot) {
                                      //     if (snapShot.hasData) {
                                      //       return Container(
                                      //         width: 250,
                                      //         height: 250,
                                      //         child: GridView.count(
                                      //           crossAxisCount: 4,
                                      //           padding: EdgeInsets.all(5),
                                      //           mainAxisSpacing: 8,
                                      //           crossAxisSpacing: 5,
                                      //           shrinkWrap: true,
                                      //           children: _answerOptionsWidgets,
                                      //         ),
                                      //       );
                                      //     }
                                      //     if (snapShot.hasError) {
                                      //       print(
                                      //           "Error rendering the data ${snapShot.error}");
                                      //     }
                                      //     return Container();
                                      //   },
                                      // ),
                                      ),
                                ],
                              ),
                            )),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                    width: 5.0,
                                    color: Colors.black.withOpacity(0.5)),
                              ),
                              width: 40.0,
                              height: 40.0,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          contentPadding: EdgeInsets.all(0),
                                          backgroundColor: Colors.transparent,
                                          content: Container(
                                            height: 500,
                                            child: Scrollbar(
                                              isAlwaysShown: true,
                                              child: ListView(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 700,
                                                        child: Card(
                                                          color: Colors.black,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                width: 600,
                                                                color: Colors
                                                                    .white30,
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .help,
                                                                        color: Colors
                                                                            .white30),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            8.0),
                                                                child: Text.rich(
                                                                    TextSpan(
                                                                  text: "",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white30,
                                                                    fontFamily:
                                                                        "RoadRage",
                                                                    fontSize:
                                                                        30,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "What is world class \n",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            25,
                                                                        decoration:
                                                                            TextDecoration.underline,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                        text: "Word class is a puzzle of root words and players are expected to" +
                                                                            " find the root word from which the given word is formed. Every English word is gotten from a Greek" +
                                                                            " or Latin word that can either stand alone on its own or with the support of other letter \n\n\n"),
                                                                    TextSpan(
                                                                      text:
                                                                          "How to play \n",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            25,
                                                                        decoration:
                                                                            TextDecoration.underline,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text: " 1. Tap the correct letters to spell out the correct answer \n" +
                                                                          " 2. Tap the undo button (bottom right) to undo your last tap \n" +
                                                                          " 3. Tap the reset button (bottom left) to reset the question  \n" +
                                                                          " 4. Tap the hint (top right, the light bulb) for a hint, not that the hint is ever changing \n " +
                                                                          " 5. You can get more life by clicking on the hearts with a plus in the middle, but you have to watch an Ad. \n " +
                                                                          " 6. You get an 2 extra lives every time you clear a stage. \n" +
                                                                          "7. You get 1 extra life every 10 Minutes. \n ",
                                                                    )
                                                                  ],
                                                                )),

                                                                // Text(
                                                                //   " " +
                                                                //       "What is world class \n" +
                                                                //       " Word class is a puzzle of root words and players are expected to " +
                                                                //       " find the root word from which the given word is formed. Every English word is gotten from a Greek" +
                                                                //       " or Latin word that can either stand alone on its own or with the support of other letter \n" +
                                                                //       "How to play the game \n"
                                                                //       " 1. Tap the correct letters to spell out the correct answer \n " +
                                                                //       " 2. Tap the undo button (bottom right) to undo your last tap \n " +
                                                                //       " 3. Tap the reset button (bottom left) to reset the question \n " +
                                                                //       " 4. Tap the hint (top right, the light bulb) for a hint, not that the hint is ever changing \n " +
                                                                //       " 5. You can get more life by clicking on the hearts with a plus in the middle, but you have to watch an Ad. \n " +
                                                                //       " 6. You get an 2 extra lives every time you clear a stage. \n " +
                                                                //       "7. You get 1 extra life every 5 hours. \n ",
                                                                //   style:
                                                                //       TextStyle(
                                                                //     color: Colors
                                                                //         .white30,
                                                                //     fontFamily:
                                                                //         "RoadRage",
                                                                //     fontSize:
                                                                //         30,
                                                                //     fontWeight:
                                                                //         FontWeight
                                                                //             .bold,
                                                                //   ),
                                                                // ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    ElevatedButton(
                                                                        style: ButtonStyle(
                                                                            backgroundColor: MaterialStateProperty.all(Colors
                                                                                .green)),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Cancel",
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                "RoadRage",
                                                                            fontSize:
                                                                                25,
                                                                          ),
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Icon(
                                  Icons.help,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                    width: 5.0,
                                    color: Colors.black.withOpacity(0.5)),
                              ),
                              width: 40.0,
                              height: 40.0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // showHint = false;
                                    hintArray = [];
                                  });
                                  resetGame();
                                },
                                child: const Icon(
                                  Icons.refresh,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 8.0, right: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.grey.shade300.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                        width: 5.0,
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                                  width: 40.0,
                                  height: 40.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      undoLastEntry();
                                      setState(() {});
                                    },
                                    child: Icon(
                                      Icons.undo,
                                      size: 30,
                                    ),
                                  ),
                                ))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionsWidget extends StatefulWidget {
  const OptionsWidget({
    Key? key,
    required List<Widget> answerOptionsWidgets,
  })  : _answerOptionsWidgets = answerOptionsWidgets,
        super(key: key);

  final List<Widget> _answerOptionsWidgets;

  @override
  State<OptionsWidget> createState() => _OptionsWidgetState();
}

class _OptionsWidgetState extends State<OptionsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      // height: 150,
      child: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.all(5),
        mainAxisSpacing: 8,
        crossAxisSpacing: 5,
        shrinkWrap: true,
        children: widget._answerOptionsWidgets,
      ),
    );
  }
}

class Answers extends StatefulWidget {
  List<Widget> answerLength;

  Answers({Key? key, required this.answerLength}) : super(key: key);

  @override
  State<Answers> createState() => _AnswersState();
}

class _AnswersState extends State<Answers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      child: GridView.count(
        shrinkWrap: true,
        padding: EdgeInsets.all(5),
        mainAxisSpacing: 8,
        crossAxisSpacing: 5,
        crossAxisCount: 5,
        children: widget.answerLength,
      ),
    );
  }
}

class HeartIcon extends StatelessWidget {
  // int index;
  bool isClicked;

  HeartIcon({required this.isClicked});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Icon(
        Icons.favorite_outline,
        color: Colors.red,
        size: 23,
      ),
      Positioned(
          left: 3,
          bottom: 5,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 15,
          )),
      (isClicked)
          ? Positioned(
              right: 8,
              bottom: 5,
              child: Container(
                  width: 10, height: 10, child: CircularProgressIndicator()))
          : Container()
    ]);
  }
}

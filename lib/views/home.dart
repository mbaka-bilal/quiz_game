import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:just_audio/just_audio.dart';
import 'package:quiz_game/controllers/ad_helper.dart';
import 'package:quiz_game/controllers/db.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/views/select_stage.dart';
import 'package:quiz_game/views/widgets/audio.dart';
import 'dart:math';

import 'package:quiz_game/views/widgets/gamesplash.dart';

class Home extends StatefulWidget {
  final List<QuestionsMap> questions;
  final int numOfLivesLeft;
  final int stageNumber;
  final String stageName;
  final int userId;
  final int usersIndex;

  // final int lastIndex;

  const Home({
    Key? key,
    required this.questions,
    required this.numOfLivesLeft,
    required this.stageNumber,
    required this.stageName,
    required this.userId,
    required this.usersIndex,
    // required this.lastIndex,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentQuestionIndex = 0;
  List<String> answerArray = [];
  List<String> answerArrayCopy = [];
  List<List<String>> guessesArray = [];
  List<List<bool>> buttonStates = [
    [false, false, false, false, false],
    [false, false, false, false, false]
  ];
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
  late bool _allowGesture;
  late OverlayEntry? _gameSplash;

  List<Widget> a = [];
  int currentLivesLeft = 0;
  String playerAnswer = "";
  List<String> hintArray = [];
  bool showHint = false;
  late BannerAd _bannerAd;
  bool _isBannerReady = false;
  late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;
  bool _hintPressed = false;
  bool undoPressed = false;
  bool _isGetLivesPressed = false;
  late Timer timer;
  // late AudioPlayer player;
  int lastPosition = 0;
  String lastLetter = "";
  bool undo = false;
  bool isWumupsCryButtonPressed = false;
  bool isWumupsCryButtonActive = false;
  bool _isHearIconPressed = false;
  int indexOfLivesPressed = 0;
  List<Widget> livesList = [];
  GlobalKey _key = GlobalKey();
  int currentIndex = 0;
  Color notClickedColor = Colors.white;
  Color clickedColor = Colors.green.shade300;
  List<List<int>> lastButtonClicked = [];
  List<int> hintLocations = [];

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  // void undo() {
  //   //undo the last drag entry
  //
  //   setState(() {
  //     this.a[0] =
  //
  //         DragTarget(onWillAccept: (value) {
  //       return true;
  //     }, onAccept: (value) {
  //       setState(() {
  //
  //         this.lastPosition = 0;
  //         this.lastLetter = value as String;
  //         solution[lastPosition] = value as String;
  //         playerAnswer = playerAnswer + solution[lastPosition]; //use this to know if user has put something in all the
  //         //available answer spaces.
  //       });
  //
  //       if (showHint &&
  //           playerAnswer.length ==
  //               (widget.questions[currentQuestionIndex].answer
  //                   .length -
  //                   hintArray.length)) {
  //         // if user has used hint to enter
  //         // if the hint == the answer - the number of hints given
  //
  //         if (solution.join("") ==
  //             widget.questions[currentQuestionIndex].answer) {
  //           bool toNextQuestion = ((widget.questions.length - 1) ==
  //               currentQuestionIndex)
  //               ? true
  //               : false; //Is user at the maximum question for that stage
  //
  //           (!toNextQuestion)
  //               ? setState(() {
  //             // should user progress?
  //             DatabaseAccess.updateTable(
  //               // change the state of the current question to answered
  //                 "stage${widget.stageNumber}",
  //                 {"solved": 0},
  //                 widget.questions[currentQuestionIndex].id);
  //
  //             DatabaseAccess.updateTable(
  //               //save the progress of the player
  //                 "stages",
  //                 {"laststop": currentQuestionIndex},
  //                 (widget.stageNumber - 1));
  //
  //             currentQuestionIndex++;
  //             showHint = false; //reset the hint state
  //             resetGame();
  //           })
  //               : showDialog(
  //               barrierDismissible: false,
  //               context: context,
  //               builder: (_) {
  //                 /* update the stage status because the user has answered all questions correctly */
  //
  //                 // print ("In Build of show Dialog");
  //
  //                 /** play cheering sound because user has passed a stage **/
  //                 player.setAsset("lib/audio/cheering.mp3");
  //                 player.play();
  //                 /** play cheering because user has passed a stage **/
  //
  //                 // Give user 2 extra lives for passing a stage
  //                 if (this.currentLivesLeft < 4) {
  //                   DatabaseAccess.updateTable(
  //                       "users",
  //                       {"life": (this.currentLivesLeft + 2)},
  //                       widget.userId);
  //
  //                   this.currentLivesLeft + 2;
  //                 } else if (this.currentLivesLeft == 4) {
  //                   DatabaseAccess.updateTable(
  //                       "users",
  //                       {"life": (this.currentLivesLeft + 1)},
  //                       widget.userId);
  //
  //                   this.currentLivesLeft++;
  //                 }
  //
  //                 return nextStageDialog();
  //               });
  //           // resetGame();
  //         } else {
  //           DatabaseAccess.updateTable("users",
  //               {"life": (currentLivesLeft - 1)}, widget.userId);
  //
  //           setState(() {
  //             currentLivesLeft--;
  //             this.showHint = false;
  //           });
  //           // if lives left is 0, show the alertdialog without the option to tryagain
  //           // else show the alert dialog with option to try again
  //           (currentLivesLeft == 0)
  //               ? lifeFinished(context)
  //               : print("Failed to question -------------");
  //           showDialog(
  //               barrierColor: Colors.transparent,
  //               barrierDismissible: false,
  //               context: context,
  //               builder: (_) {
  //                 return Alert(3, context);
  //               });
  //         }
  //       }
  //
  //       /* This one is for an answer without a hint */
  //       if (playerAnswer.length ==
  //           widget.questions[currentQuestionIndex].answer.length) {
  //         // checks to see if the answers are the same length
  //         // if they are the same length then check to see if they are the same answer
  //
  //         if (solution.join("") ==
  //             widget.questions[currentQuestionIndex].answer) {
  //           bool toNextQuestion = ((widget.questions.length - 1) ==
  //               currentQuestionIndex)
  //               ? true
  //               : false; //Is user at the maximum question for that stage
  //
  //           (!toNextQuestion)
  //               ? setState(() {
  //             /* Logic if the user gets this question move on to the next one */
  //
  //             DatabaseAccess.updateTable(
  //               // change the state of the current question to answered
  //                 "stage${widget.stageNumber}",
  //                 {"solved": 0},
  //                 widget.questions[currentQuestionIndex].id);
  //
  //             DatabaseAccess.updateTable(
  //               //save the progress of the player
  //                 "stages",
  //                 {"laststop": currentQuestionIndex + 1},
  //                 (widget.stageNumber - 1));
  //
  //             currentQuestionIndex++;
  //
  //             resetGame();
  //             // playerAnswer = ""; //reset the players answer
  //             // guessesArray = []; //reset the guesses
  //             // a = []; //empty array a first
  //             // solution = []; //empty the solutions array
  //             //
  //             // answerToArray(widget
  //             //     .questions[currentQuestionIndex]
  //             //     .answer); //to recreate the options box with the new answer
  //           })
  //               : showDialog(
  //               context: context,
  //               builder: (_) {
  //                 /* update the stage status because the user has answered all questions correctly */
  //                 // we assume that the for the user to reach this point the user must have
  //                 // answered all the questions correctly
  //
  //                 /** play cheering sound because user has failed a question **/
  //                 player = AudioPlayer();
  //                 player.setAsset("lib/audio/cheering.mp3");
  //                 player.play();
  //                 /** play cheering because user has failed a question **/
  //
  //                 return nextStageDialog();
  //               });
  //         } else {
  //           // print ("user has failed it -------------");
  //
  //           DatabaseAccess.updateTable("users",
  //               {"life": (currentLivesLeft - 1)}, widget.userId);
  //           //user failed the question
  //           setState(() {
  //             currentLivesLeft = currentLivesLeft - 1;
  //
  //             showHint = false; //reset the hint state
  //           });
  //
  //           createLives(this.currentLivesLeft);
  //
  //           // if lives left is 0, show the alertdialog without the option to tryagain
  //           // else show the alert dialog with option to try again
  //
  //           (currentLivesLeft == 0)
  //               ? lifeFinished(context)
  //               : showDialog(
  //               barrierColor: Colors.transparent,
  //               barrierDismissible: false,
  //               context: (context),
  //               builder: (_) {
  //                 return Alert(currentLivesLeft, context);
  //               }).then((value) {
  //             //incase the player clicks the back button on mobile phone
  //             // instead of the one in the app.
  //
  //             resetGame();
  //             setState(() {
  //               this.showHint =
  //               false; //reset the show hint option to be false;
  //             });
  //           });
  //           //to recreate the options box
  //         }
  //       }
  //     }, builder: (context, candidateData, rejectedData) {
  //       return Container(
  //         width: 40,
  //         height: 40,
  //         decoration: BoxDecoration(
  //           // image: DecorationImage(
  //           //   image: AssetImage('lib/images/background_image.png'),
  //           // ),
  //             color: Colors.black,
  //             border: Border.all(color: Colors.black)),
  //         child: Center(
  //             child: Text(
  //               "Z",
  //               style: TextStyle(
  //                   color: Colors.brown,
  //                   fontSize: 40,
  //                   fontWeight: FontWeight.bold),
  //             )),
  //       );
  //     });
  //
  //   });
  //
  //   setState(() {
  //
  //   });
  // }

  // void undo() {
  //   solution.removeLast(); //remove the last answer from the list
  //
  //
  // }

  void checkAnswer() {
    if (currentIndex == widget.questions[currentQuestionIndex].answer.length) {
      if (playerAnswer == widget.questions[currentQuestionIndex].answer) {
        // print("Go to next question");
        bool toNextQuestion =
            ((widget.questions.length - 1) == currentQuestionIndex)
                ? true
                : false; //Is user at the maximum question for that stage

        (!toNextQuestion)
            ? setState(() {
                /* Logic if the user gets this question move on to the next one */
                //play an audio
                // AudioCache player = AudioCache();
                // player.play("audio/water_drop.mp3");
                Audio.playAsset(AudioType.swap);
                DatabaseAccess.updateTable(
                    // change the state of the current question to answered
                    "stage${widget.stageNumber}",
                    {"solved": 0},
                    widget.questions[currentQuestionIndex].id);

                DatabaseAccess.updateTable(
                    //save the progress of the player
                    "stages",
                    {"laststop": currentQuestionIndex + 1},
                    (widget.stageNumber - 1));

                currentQuestionIndex++;

                resetGame();
              })
            : showDialog(
                context: context,
                builder: (_) {
                  Audio.playAsset(AudioType.win);
                  /* update the stage status because the user has answered all questions correctly */
                  // we assume that the for the user to reach this point the user must have
                  // answered all the questions correctly

                  /** play cheering sound because user has failed a question **/
                  // player = AudioPlayer();
                  // player.setAsset("lib/audio/cheering.mp3");
                  // player.play();
                  /** play cheering because user has failed a question **/

                  return nextStageDialog();
                });
      } else {
        // print ("user has failed it -------------");
        Audio.playAsset(AudioType.lost);

        DatabaseAccess.updateTable(
            "users", {"life": (currentLivesLeft - 1)}, widget.userId);
        //user failed the question
        setState(() {
          currentLivesLeft = currentLivesLeft - 1;

          showHint = false; //reset the hint state
        });

        createLives(this.currentLivesLeft);

        // if lives left is 0, show the alertdialog without the option to tryagain
        // else show the alert dialog with option to try again

        (currentLivesLeft == 0)
            ? lifeFinished(context)
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
                setState(() {
                  this.showHint =
                      false; //reset the show hint option to be false;
                });
              });
        //to recreate the options box
      }
    }
  }

  void createHint(String answer) {
    hintLocations = [];
    String hintText = widget.questions[currentQuestionIndex].hint;

    // print("THe hint text is $hintText");

    for (int i = 0; i < answer.length; i++) {
      // get the locations of the hint and store it in an array
      if (hintText.contains(answer[i])) {
        // print("The location of i is $i");
        hintLocations.add(i);
      }
    }

    print("The hint locations $hintLocations");

    for (int i = 0; i < a.length; i++) {
      // find all the locations of hint and replace it
      if (hintLocations.contains(i)) {
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

    // int numberOfHints = (answer.length / 2).floor();

    // var toArrayAnswer = answer.split("");
    // for (int i = 0; i < numberOfHints; i++) {
    //   String temp = toArrayAnswer[rng.nextInt(toArrayAnswer.length - 1)];
    //   hintArray.add(temp);
    //   toArrayAnswer.removeAt(toArrayAnswer.indexOf(temp));
    // }
  }

  void answerGaps() {
    for (int i = 0;
        i < widget.questions[currentQuestionIndex].answer.length;
        i++) {
      a.add(Container(
        padding: const EdgeInsets.all(5.0),
        // width: 30,
        // height: 30,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(""),
      ));
    }
  }

  Future<void> options() async {
    // create my DragTargets for putting my answers in.

    this.a = [];

    // print ("THe value of undo pressed is $undoPressed");

    if (!undoPressed) {
      for (int i = 0; i < answerArray.length; i++) {
        // create place holder for DragTarget Widgets
        if (hintArray.contains(answerArray[i]) && showHint) {
          solution.add(answerArray[i]); // add my hints to the solutions array
        } else {
          solution.add("");
        }
      }
    }

    for (int i = 0; i < answerArray.length; i++) {
      this.a.add(
          // if hint is in
          (hintArray.contains(answerArray[i]) && showHint)
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('lib/images/background_image.png'),
                      ),
                      border: Border.all(color: Colors.blueAccent)),
                  child: Center(child: Text(answerArray[i])),
                )
              : DragTarget(onWillAccept: (value) {
                  return true;
                }, onAccept: (value) {
                  setState(() {
                    // this.a[i] = Container(child: Text("H"));
                    // this.lastPosition = 0;
                    // this.lastLetter = value as String;
                    dragTargetIndex.add(i);

                    print(
                        "THe new size of drag target is ${dragTargetIndex.length}");
                    solution[i] = value as String;
                    playerAnswer = playerAnswer +
                        solution[
                            i]; //use this to know if user has put something in all the
                    //available answer spaces.
                  });

                  if (showHint &&
                      playerAnswer.length ==
                          (widget.questions[currentQuestionIndex].answer
                                  .length -
                              hintArray.length)) {
                    // if user has used hint to enter
                    // if the hint == the answer - the number of hints given

                    if (solution.join("") ==
                        widget.questions[currentQuestionIndex].answer) {
                      bool toNextQuestion = ((widget.questions.length - 1) ==
                              currentQuestionIndex)
                          ? true
                          : false; //Is user at the maximum question for that stage

                      (!toNextQuestion)
                          ? setState(() {
                              // should user progress?
                              DatabaseAccess.updateTable(
                                  // change the state of the current question to answered
                                  "stage${widget.stageNumber}",
                                  {"solved": 0},
                                  widget.questions[currentQuestionIndex].id);

                              DatabaseAccess.updateTable(
                                  //save the progress of the player
                                  "stages",
                                  {"laststop": currentQuestionIndex},
                                  (widget.stageNumber - 1));

                              currentQuestionIndex++;
                              showHint = false; //reset the hint state
                              resetGame();
                            })
                          : showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) {
                                /* update the stage status because the user has answered all questions correctly */

                                // print ("In Build of show Dialog");

                                /** play cheering sound because user has passed a stage **/
                                // player.setAsset("lib/audio/cheering.mp3");
                                // player.play();
                                /** play cheering because user has passed a stage **/

                                // Give user 2 extra lives for passing a stage
                                if (this.currentLivesLeft < 4) {
                                  DatabaseAccess.updateTable(
                                      "users",
                                      {"life": (this.currentLivesLeft + 2)},
                                      widget.userId);

                                  this.currentLivesLeft + 2;
                                } else if (this.currentLivesLeft == 4) {
                                  DatabaseAccess.updateTable(
                                      "users",
                                      {"life": (this.currentLivesLeft + 1)},
                                      widget.userId);

                                  this.currentLivesLeft++;
                                }

                                return nextStageDialog();
                              });
                      // resetGame();
                    } else {
                      DatabaseAccess.updateTable("users",
                          {"life": (currentLivesLeft - 1)}, widget.userId);

                      setState(() {
                        currentLivesLeft--;
                        this.showHint = false;
                      });
                      // if lives left is 0, show the alertdialog without the option to tryagain
                      // else show the alert dialog with option to try again
                      (currentLivesLeft == 0)
                          ? lifeFinished(context)
                          : print("Failed to question -------------");
                      showDialog(
                          barrierColor: Colors.transparent,
                          barrierDismissible: false,
                          context: context,
                          builder: (_) {
                            return Alert(3, context);
                          });
                    }
                  }

                  /* This one is for an answer without a hint */
                  if (playerAnswer.length ==
                      widget.questions[currentQuestionIndex].answer.length) {
                    // checks to see if the answers are the same length
                    // if they are the same length then check to see if they are the same answer

                    if (solution.join("") ==
                        widget.questions[currentQuestionIndex].answer) {
                      bool toNextQuestion = ((widget.questions.length - 1) ==
                              currentQuestionIndex)
                          ? true
                          : false; //Is user at the maximum question for that stage

                      (!toNextQuestion)
                          ? setState(() {
                              /* Logic if the user gets this question move on to the next one */

                              DatabaseAccess.updateTable(
                                  // change the state of the current question to answered
                                  "stage${widget.stageNumber}",
                                  {"solved": 0},
                                  widget.questions[currentQuestionIndex].id);

                              DatabaseAccess.updateTable(
                                  //save the progress of the player
                                  "stages",
                                  {"laststop": currentQuestionIndex + 1},
                                  (widget.stageNumber - 1));

                              currentQuestionIndex++;

                              resetGame();
                              // playerAnswer = ""; //reset the players answer
                              // guessesArray = []; //reset the guesses
                              // a = []; //empty array a first
                              // solution = []; //empty the solutions array
                              //
                              // answerToArray(widget
                              //     .questions[currentQuestionIndex]
                              //     .answer); //to recreate the options box with the new answer
                            })
                          : showDialog(
                              context: context,
                              builder: (_) {
                                /* update the stage status because the user has answered all questions correctly */
                                // we assume that the for the user to reach this point the user must have
                                // answered all the questions correctly

                                /** play cheering sound because user has failed a question **/
                                // player = AudioPlayer();
                                // player.setAsset("lib/audio/cheering.mp3");
                                // player.play();
                                /** play cheering because user has failed a question **/

                                return nextStageDialog();
                              });
                    } else {
                      // print ("user has failed it -------------");

                      DatabaseAccess.updateTable("users",
                          {"life": (currentLivesLeft - 1)}, widget.userId);
                      //user failed the question
                      setState(() {
                        currentLivesLeft = currentLivesLeft - 1;

                        showHint = false; //reset the hint state
                      });

                      createLives(this.currentLivesLeft);

                      // if lives left is 0, show the alertdialog without the option to tryagain
                      // else show the alert dialog with option to try again

                      (currentLivesLeft == 0)
                          ? lifeFinished(context)
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
                              setState(() {
                                this.showHint =
                                    false; //reset the show hint option to be false;
                              });
                            });
                      //to recreate the options box
                    }
                  }
                }, builder: (context, candidateData, rejectedData) {
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        // image: DecorationImage(
                        //   image: AssetImage('lib/images/background_image.png'),
                        // ),
                        color: Colors.black,
                        border: Border.all(color: Colors.black)),
                    child: Center(
                        child: Text(
                      dragTargetValue(i),
                      style: TextStyle(
                          color: Colors.brown,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    )),
                  );
                }));
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

  String dragTargetValue(int index) {
    if (undoPressed && index == dragTargetIndex[dragTargetIndex.length - 1]) {
      return "";
    } else {
      if (!(solution[index] == "")) {
        return solution[index];
      } else {
        return "";
      }
    }
  }

  assignSounds() async {
    // AudioPlayer player = AudioPlayer();
    // await player.setAsset("lib/audio/water_drop.mp3");
  }

  void answerToArray(String answer) {
    assignSounds();
    this.answerArray = [];

    for (int i = 0; i < answer.length; ++i) {
      this.answerArray.add(answer[i]);
    }
    this.answerArrayCopy = this.answerArray;

    // createHint(answer); //create the hint

    // options(); //create the DragTargets.
  }

  Widget Alert(int numOfLives, BuildContext context) {
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
                                Navigator.of(context).pushReplacement(
                                    createRoute(SelectStage()));
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
                    Expanded(
                      child: IconButton(
                        //replay the level
                        onPressed: () async {
                          setState(() {
                            this.showHint =
                                false; //reset the show hint option to be false;
                            guessesArray = [];
                            answerArrayCopy = [];
                            answerArray = [];
                            this.currentQuestionIndex = 0;
                          });
                          resetGame();

                          //set the stage finished to false
                          await DatabaseAccess.updateTable(
                              "stages", {"done": 1}, widget.stageNumber - 1);

                          //set the state of all the questions to not answered
                          for (int i = 0; i < widget.questions.length; i++) {
                            await DatabaseAccess.updateTable(
                                // change the state of the current question to answered
                                "stage${widget.stageNumber}",
                                {"solved": 0},
                                widget.questions[currentQuestionIndex].id);
                          }

                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.repeat,
                          color: Colors.red,
                        ),
                        iconSize: 45,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          await DatabaseAccess.updateTable(
                              "stages", {"done": 0}, widget.stageNumber - 1);

                          await DatabaseAccess.updateTable(
                              // change the state of the current question to answered
                              "stage${widget.stageNumber}",
                              {"solved": 0},
                              widget.questions[currentQuestionIndex].id);

                          await DatabaseAccess.updateTable(
                              //save the progress of the player
                              "stages",
                              {"laststop": currentQuestionIndex},
                              (widget.stageNumber - 1));

                          // we assume that the for the user to reach this point the user must have
                          // answered all the questions correctly
                          await DatabaseAccess.updateTable(
                              "stages", {"done": 0}, widget.stageNumber - 1);

                          // Give user 2 extra lives for passing a stage
                          if (this.currentLivesLeft < 4) {
                            await DatabaseAccess.updateTable(
                                "users",
                                {"life": (this.currentLivesLeft + 2)},
                                widget.userId);

                            this.currentLivesLeft + 2;
                          } else if (this.currentLivesLeft == 4) {
                            await DatabaseAccess.updateTable(
                                "users",
                                {"life": (this.currentLivesLeft + 1)},
                                widget.userId);

                            this.currentLivesLeft++;
                          }

                          Navigator.of(context)
                              .pushReplacement(createRoute(SelectStage()));
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

  // adDialog(BuildContext context, int popnumber, bool isHint) {
  //   int count = 0;
  //   showGeneralDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       pageBuilder: (context, animation, secondaryAnimation) {
  //         return Container(
  //           color: Colors.blue,
  //           child: Column(
  //             children: [
  //               ElevatedButton(
  //                   onPressed: () {
  //                     setState(() {
  //                       //give a user one life for the video watched or add clicked
  //
  //                       DatabaseAccess.updateTable("users",
  //                           {"life": (currentLivesLeft + 1)}, widget.userId);
  //                       if (!isHint) {
  //                         //if it is not a hint, it means the user want more life,
  //                         // when user has watched video or ad has shown
  //                         // increase the life
  //                         this.currentLivesLeft++;
  //                       }
  //                     });
  //                     resetGame();
  //                     Navigator.popUntil(context, (route) {
  //                       // remove the two top most pages from the stack
  //                       return count++ == popnumber;
  //                     });
  //                   },
  //                   child: Text("done"))
  //             ],
  //           ),
  //         );
  //       });
  // }

  void undoLastEntry() {
    if (playerAnswer.length > 0) {
      //as long as player has tapped an option
      List<int> tempLast = lastButtonClicked.removeLast();
      // print("The player answer is $playerAnswer");

      //undo the players last entry
      playerAnswer = playerAnswer.substring(
          0, playerAnswer.length - 1); //remove the last letter from the answer
      a[currentIndex - 1] = Container(
        padding: const EdgeInsets.all(5.0),
        // width: 30,
        // height: 30,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        alignment: Alignment.center,
        child: Text(""),
      ); //remove the last option entry

      currentIndex--; //reduce the current index by 1

      //uncolor the last option entry
      buttonStates[tempLast[0]][tempLast[1]] = false;
    }
  }

  void resetGame() {
    /* reset the game so the user can try again */
    setState(() {
      // if player failed the question
      this.playerAnswer = ""; //reset the players answer
      this.guessesArray = []; //reset the guesses
      this.a = []; //empty array a first for the drag targets
      this.solution = []; //empty the solutions array
      this.hintArray = []; //reset the hints array
      this.undoPressed = false;
      currentIndex = 0;

      // options(); //recall this function to recreate the solutions box.
    });
    createLives(this.currentLivesLeft);
    if (showHint) {
      createHint(widget.questions[currentQuestionIndex].answer);
    } else {
      answerGaps();
    } //if the user has
    // already wanted to see hint keep hint on always.
    resetButtonState();
    answerToArray(widget.questions[currentQuestionIndex].answer);
  }

  resetButtonState() {
    for (int i = 0; i < buttonStates.length; i++) {
      for (int v = 0; v < 5; v++) {
        buttonStates[i][v] = false;
      }
    }

    setState(() {});
  }

  callCreateLives() {
    print("In here");
    createLives(this.currentLivesLeft);
  }

  createLives(int lives) {
    /* Create the lives list */
    this.livesList = [];

    for (int i = 1; i <= 5; i++) {
      //create the five default hearts
      if (i <= lives) {
        // while we are still in good lives
        // setState(() {
        livesList.add(Icon(
          Icons.favorite,
          color: Colors.red,
          size: 23,
        ));
        // });
      } else {
        //if no more lives add the get life icon.
        // setState(() {
        livesList.add(GestureDetector(
            onTap: () {
              print("Get --------------- more life button pressed ----------");
              getMoreLife(context, i - 1);
              // _loadRewardedAd(context);
              // _isGetLivesPressed = true;
              // _isHearIconPressed = false;
              // indexOfLivesPressed = i;
              // // callCreateLives();
              // setState(() {});

              // if (_isRewardedAdReady) {
              //   _rewardedAd.show(
              //       onUserEarnedReward: (RewardedAd ad, RewardItem item) {
              //     //if the user has viewed the rewarded Ad
              //     DatabaseAccess.updateTable(
              //         "users",
              //         {"life": (currentLivesLeft + 1)},
              //         widget.userId); //give the user one extra life

              //     this.currentLivesLeft++; //increase the current lives by 1
              //     _isGetLivesPressed = false;
              //     setState(() {
              //       // DummyWidget();
              //     });

              // resetGame();
              // });
              // }
            },
            child: HeartIcon(isClicked: false) // the hearts widget
            ));
        // });
      }
    }

    // setState(() {});
  }

  void getMoreLife(BuildContext context, int index) {
    // replace the pressed heart with a loading heart temporarily
    livesList[index] = HeartIcon(isClicked: true);
    setState(() {});

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _rewardedAd.dispose();
            },
          );

          _isRewardedAdReady = true;
          setState(() {});
        },
        onAdFailedToLoad: (err) {
          // replace the heart with the default
          createLives(currentLivesLeft);
          _isRewardedAdReady = false;
          setState(() {});

          print("Unable to load aD ${err.message}");

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("No Internet, Please Watch an Ad to get Life")));

          _rewardedAd.dispose();
        },
      ),
    );

    if (_isRewardedAdReady) {
      _rewardedAd.show(onUserEarnedReward: (RewardedAd ad, RewardItem item) {
        //if the user has viewed the rewarded Ad

        DatabaseAccess.updateTable("users", {"life": (currentLivesLeft + 1)},
            widget.userId); //give the user one extra life

        currentLivesLeft++; //increase the current lives by 1

        createLives(currentLivesLeft);

        // _isGetLivesPressed = false;
        setState(() {});
      });
    }
  }

  lifeFinished(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Color(0xFF255958),
            actionsPadding: EdgeInsets.all(0),
            actionsOverflowButtonSpacing: 0,
            content: Container(
              height: 200,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      Text("0 lives left")
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 10)),
                  Container(
                      width: 90,
                      height: 90,
                      child: Image.asset("lib/images/wumpus_cry.gif")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: (isWumupsCryButtonPressed)
                              ? null
                              : () {
                                  isWumupsCryButtonPressed = true;
                                  isWumupsCryButtonActive = true;
                                  Navigator.pop(context);
                                  setState(() {});

                                  _loadRewardedAd(context);

                                  if (_isRewardedAdReady) {
                                    _rewardedAd.show(onUserEarnedReward:
                                        (RewardedAd ad, RewardItem item) {
                                      //if the user has viewed the rewarded Ad
                                      DatabaseAccess.updateTable(
                                          "users",
                                          {"life": (currentLivesLeft + 1)},
                                          widget
                                              .userId); //give the user one extra life
                                      setState(() {
                                        this.currentLivesLeft++; //increase the current lives by 1
                                      });
                                      resetGame();
                                      Navigator.of(context).pop();
                                    });
                                  }
                                },
                          child: Stack(children: [
                            Text("Get More Life"),
                            if (isWumupsCryButtonActive)
                              Align(
                                alignment: Alignment.centerRight,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                          ])),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            Navigator.pushAndRemoveUntil(context,
                                createRoute(SelectStage()), (route) => false);
                          },
                          child: Text("Exit")),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).then((value) {
      if (currentLivesLeft == 0) {
        setState(() {});
      } else {
        //refresh the page, meaning the user must have requested for more life
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback(_showGameStartSplash);

    answerToArray(widget.questions[widget.usersIndex].answer);
    currentLivesLeft = widget.numOfLivesLeft;
    currentQuestionIndex = widget
        .usersIndex; //set the index the user was at so the user can continue

    _initGoogleMobileAds();

    _loadBannerAd();

    answerGaps();

    // _loadRewardedAd(context);

    RewardedAd.load(
        adUnitId: AdHelper.rewardedAdUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            this._rewardedAd = ad;
          },
          onAdFailedToLoad: (err) {},
        ));

    _bannerAd.load();

    timer = Timer.periodic(Duration(seconds: 30), (_) {
      if (!_isBannerReady) {
        _loadBannerAd();
        _bannerAd.load();
      }
    });

    createLives(currentLivesLeft);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    // player.dispose(); //throw the player away
    _rewardedAd.dispose();
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

  recallLoadRewardAd() {
    _loadRewardedAd(context); // confusing line ? why call it again?
  }

  void _loadRewardedAd(BuildContext context) {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          this._rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                // if (_hintPressed) {
                //   // if the user wants to see a hint
                //   showHint = true;
                // }
                _isRewardedAdReady = false;
                _hintPressed = false;
                this._isHearIconPressed = false;
                _isGetLivesPressed = false;
                _rewardedAd.dispose();
              });
              recallLoadRewardAd();
            },
          );

          setState(() {
            _isRewardedAdReady = true;
            this._isHearIconPressed = false;
            _isGetLivesPressed = false;
            _hintPressed = false; //done fetching the ad
          });
        },
        onAdFailedToLoad: (err) {
          _rewardedAd.dispose();
          print("Unable to load aD $err");

          if (this.isWumupsCryButtonActive) {
            _isRewardedAdReady = false;
            _isGetLivesPressed = false;
            _hintPressed = false;
            this._isHearIconPressed = false;

            this.isWumupsCryButtonActive = false;
            this.isWumupsCryButtonPressed = false;
            setState(() {});

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("No Internet, Please Watch an Ad to get Life")));
          } else {
            setState(() {
              _isRewardedAdReady = false;
              _isGetLivesPressed = false;
              _hintPressed = false;
              this._isHearIconPressed = false;

              this.isWumupsCryButtonActive = false;
              this.isWumupsCryButtonPressed = false;
            });
            showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                      content: Container(
                    height: 100,
                    child: Column(
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: "No Internet\n\n\n",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              )),
                          TextSpan(
                              text: "Please, watch an AD to continue",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ))
                        ])),
                      ],
                    ),
                  ));
                }).then((value) {
              _isGetLivesPressed = false;
            });
          }
          _rewardedAd.dispose();
        },
      ),
    );
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero,
        () => {if (this.currentLivesLeft == 0) lifeFinished(context)});

    return WillPopScope(
      onWillPop: () async {
        // _popKey = _key.currentWidget!.key;
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (_) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              content: Container(
                // color: Colors.black38,
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
                                      //the user chooses to quit the game, take the user back to the select stage page
                                      Navigator.of(context).pushAndRemoveUntil(
                                          createRoute(SelectStage()),
                                          (Route<dynamic> route) => false);

                                      Navigator.of(context).pushReplacement(
                                          createRoute(SelectStage()));
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
        child: Scaffold(
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
                        child: Align(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(),
                                width: 120,
                                child: Column(
                                  children: [
                                    Row(
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
                                                                color: Colors
                                                                    .black,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              0.0),
                                                                      child:
                                                                          Container(
                                                                        margin:
                                                                            EdgeInsets.all(0.0),
                                                                        width:
                                                                            200,
                                                                        color: Colors
                                                                            .white30,
                                                                        child:
                                                                            Row(
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
                                                                    Text(
                                                                        "Want to quit",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white30,
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
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          ElevatedButton(
                                                                            style:
                                                                                ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                                                                            onPressed:
                                                                                () {
                                                                              //the user chooses to quit the game, take the user back to the select stage page
                                                                              Navigator.of(context).pushReplacement(createRoute(SelectStage()));
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              "Yes",
                                                                              style: TextStyle(
                                                                                fontFamily: "RoadRage",
                                                                                fontSize: 25,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          ElevatedButton(
                                                                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
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
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 13)),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: livesList,
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: (this._hintPressed)
                                        ? null
                                        : () {
                                            _loadRewardedAd(context);
                                            _hintPressed = true;
                                            setState(() {});
                                            if (_isRewardedAdReady) {
                                              _rewardedAd.show(
                                                onUserEarnedReward:
                                                    (RewardedAd ad,
                                                        RewardItem item) {
                                                  createHint(widget
                                                      .questions[
                                                          currentQuestionIndex]
                                                      .answer);
                                                  showHint = true;
                                                  _hintPressed = false;
                                                  // _rewardedAd.dispose();
                                                  setState(() {});
                                                },
                                              );
                                            }
                                          },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Container(
                                          width: 50,
                                          height: 50,
                                          child: Stack(
                                            children: [
                                              Image.asset(
                                                  "lib/images/bulb_light_bulb.gif"),
                                              if (this._hintPressed)
                                                CircularProgressIndicator()
                                            ],
                                          )),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 5)),
                                ],
                              ),
                              //To be clipped for a nice ui
                            ],
                          ),
                        ),
                      ),
                      // Padding(padding: EdgeInsets.only(bottom: 3)),
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
                                // Padding(
                                //     padding: EdgeInsets.only(
                                //   bottom: 12,
                                // )),
                                // Padding(padding: EdgeInsets.only(top: 10)),
                                if (_isBannerReady)
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 50,
                                    child: Container(
                                      child: AdWidget(ad: _bannerAd),
                                    ),
                                  ),
                                Expanded(
                                  flex: 1,
                                  child: ListView.separated(
                                    itemCount: 2,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      List<String> guesses = [];

                                      for (int i = 0; i <= 4; i++) {
                                        if (this.answerArrayCopy.length == 1) {
                                          /*
                                         once the loop is equal to 1, then assign it
                                         like that because no ranging
                                    */

                                          guesses.add(this.answerArrayCopy[0]);
                                          this.answerArrayCopy.removeAt(0);
                                        } else if (this.answerArrayCopy.length >
                                            0) {
                                          /*
                                        Loop through the answersCopy if the length
                                        is greater than 0 add it to the array
                                    */

                                          int arrayIndex = rng.nextInt(
                                              this.answerArrayCopy.length -
                                                  1); //randomly pick an answer

                                          guesses.add(this.answerArrayCopy[
                                              arrayIndex]); //add the randomly picked answer to the array

                                          this.answerArrayCopy.removeAt(
                                              arrayIndex); //remove the randomly picked letter from the list of answers
                                        } else {
                                          guesses.add(this.alphabets[
                                              rng.nextInt(
                                                  this.alphabets.length - 1)]);
                                        }
                                      }

                                      //add the guesses to the global array containing all guesses
                                      guessesArray.add(guesses);

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              width: 40,
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: GestureDetector(
                                                onTap: () {
                                                  buttonStates[index][0] = true;
                                                  lastButtonClicked
                                                      .add([index, 0]);
                                                  a[currentIndex] = Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      guessesArray[index][0],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          fontFamily:
                                                              "Lobster"),
                                                    ),
                                                  );
                                                  playerAnswer = playerAnswer +
                                                      guessesArray[index][0];
                                                  currentIndex++;
                                                  setState(() {});
                                                  checkAnswer();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          (buttonStates[index]
                                                                  [0])
                                                              ? Colors.blue
                                                              : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    guessesArray[index][0],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        fontFamily: "Lobster"),
                                                  ),
                                                ),
                                              )),
                                          Container(
                                            padding: const EdgeInsets.all(5.0),
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                              onTap: () {
                                                lastButtonClicked
                                                    .add([index, 1]);
                                                buttonStates[index][1] = true;
                                                a[currentIndex] = Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    guessesArray[index][1],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        fontFamily: "Lobster"),
                                                  ),
                                                );
                                                playerAnswer = playerAnswer +
                                                    guessesArray[index][1];
                                                currentIndex++;
                                                setState(() {});
                                                checkAnswer();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: (buttonStates[index]
                                                            [1])
                                                        ? Colors.blue
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  guessesArray[index][1],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      fontFamily: "Lobster"),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5.0),
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                onTap: () {
                                                  buttonStates[index][2] = true;
                                                  lastButtonClicked
                                                      .add([index, 2]);
                                                  a[currentIndex] = Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      guessesArray[index][2],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          fontFamily:
                                                              "Lobster"),
                                                    ),
                                                  );
                                                  playerAnswer = playerAnswer +
                                                      guessesArray[index][2];
                                                  currentIndex++;
                                                  setState(() {});
                                                  checkAnswer();
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            (buttonStates[index]
                                                                    [2])
                                                                ? Colors.blue
                                                                : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      guessesArray[index][2],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          fontFamily:
                                                              "Lobster"),
                                                    ))),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5.0),
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                                onTap: () {
                                                  buttonStates[index][3] = true;
                                                  lastButtonClicked
                                                      .add([index, 3]);
                                                  a[currentIndex] = Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      guessesArray[index][3],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          fontFamily:
                                                              "Lobster"),
                                                    ),
                                                  );
                                                  playerAnswer = playerAnswer +
                                                      guessesArray[index][3];
                                                  currentIndex++;
                                                  setState(() {});
                                                  checkAnswer();
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            (buttonStates[index]
                                                                    [3])
                                                                ? Colors.blue
                                                                : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      guessesArray[index][3],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 30,
                                                          fontFamily:
                                                              "Lobster"),
                                                    ))),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5.0),
                                            width: 40,
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: GestureDetector(
                                              onTap: () {
                                                buttonStates[index][4] = true;
                                                lastButtonClicked
                                                    .add([index, 4]);
                                                a[currentIndex] = Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    guessesArray[index][4],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        fontFamily: "Lobster"),
                                                  ),
                                                );
                                                playerAnswer = playerAnswer +
                                                    guessesArray[index][4];
                                                currentIndex++;
                                                setState(() {});
                                                checkAnswer();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: (buttonStates[index]
                                                            [4])
                                                        ? Colors.blue
                                                        : Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  guessesArray[index][4],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      fontFamily: "Lobster"),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Padding(
                                          padding: EdgeInsets.only(bottom: 10));
                                    },
                                  ),
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
                                                      MainAxisAlignment.center,
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
                                                              child: Text(
                                                                " " +
                                                                    " 1. Tap the correct letters to spell out the correct answer \n " +
                                                                    " 2. Tap the undo button (bottom right) to undo your last tap \n " +
                                                                    " 3. Tap the reset button (bottom left) to reset the question \n " +
                                                                    " 4. Tap the hint (top right, the light bulb) for a hint, not that the hint is ever changing \n " +
                                                                    " 5. You can get more life by clicking on the hearts with a plus in the middle, but you have to watch an Ad. \n " +
                                                                    " 6. You get an 2 extra lives every time you clear a stage. \n " +
                                                                    "7. You get 1 extra life every 5 hours. \n ",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white30,
                                                                  fontFamily:
                                                                      "RoadRage",
                                                                  fontSize: 30,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
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
                                  showHint = false;
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
    );
  }
}

// class WumpusStatefulButton extends StatefulWidget {
//   const WumpusStatefulButton({
//     Key? key,
//     required this.isWumupsCryButtonPressed,
//     required this.isWumpusCryButtonActive
//   }) : super(key: key);
//
//   final bool isWumupsCryButtonPressed;
//   final bool isWumpusCryButtonActive;
//
//   @override
//   _WumpusStatefulButtonState createState() => _WumpusStatefulButtonState();
// }
//
// class _WumpusStatefulButtonState extends State<WumpusStatefulButton> {
//   bool buttonActive = true;
//   bool buttonPressed = false;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     buttonActive = widget.isWumpusCryButtonActive;
//     buttonPressed = widget.isWumupsCryButtonPressed;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Container(
//           width: 100,
//           child: ElevatedButton(
//               onPressed: (!buttonActive) ? null : () {
//
//                 setState(() {
//                   buttonActive = false;
//                   buttonPressed = true;
//                 });
//
//                 // Home()._loadRewardedAd();
//                 //
//                 // if (_isRewardedAdReady) {
//                 //   _rewardedAd.show(onUserEarnedReward:
//                 //       (RewardedAd ad, RewardItem item) {
//                 //     //if the user has viewed the rewarded Ad
//                 //     DatabaseAccess.updateTable(
//                 //         "users",
//                 //         {"life": (currentLivesLeft + 1)},
//                 //         widget.userId); //give the user one extra life
//                 //     setState(() {
//                 //       this.currentLivesLeft++; //increase the current lives by 1
//                 //     });
//                 //     resetGame();
//                 //     Navigator.of(context).pop();
//                 //   });
//                 // }
//       // }
//               },
//       child: Stack(children: [
//       Text("Get More Life"),
//       if (buttonPressed)
//         Align(
//           alignment: Alignment.centerRight,
//           child: CircularProgressIndicator(
//             color: Colors.white,
//           ),
//         )
//     ])));
//
//  }
// }
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
          ? Container(
              width: 10,
              height: 10,
              child: Positioned(
                  right: 20, bottom: 5, child: CircularProgressIndicator()))
          : Container()
    ]);
  }
}

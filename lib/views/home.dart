import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quiz_game/controllers/ad_helper.dart';
import 'package:quiz_game/controllers/db.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/views/select_stage.dart';
import 'dart:math';

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
  bool _isGetLivesPressed = false;
  late Timer timer;
  late AudioPlayer player;

  // List<String> menu = ["Settings"];
  List<Widget> livesList = [];
  GlobalKey _key = GlobalKey();
  dynamic _popKey;

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  bool checkAnswer(String answer, String attempt) {
    if (answer == attempt) {
      // print("Go to next question");
      return true;
    } else {
      // print("Remove life");
      return false;
    }
  }

  void createHint(String answer) {
    /* To Do
      1. Make it in such a way that it does not overwrite the already entered users selections,
      except they are wrong.
      2. if they are right it brings hints in other places to reveal the answer.
     */
    int numberOfHints = (answer.length / 2).floor();

    var toArrayAnswer = answer.split("");
    for (int i = 0; i < numberOfHints; i++) {
      String temp = toArrayAnswer[rng.nextInt(toArrayAnswer.length - 1)];
      hintArray.add(temp);
      toArrayAnswer.removeAt(toArrayAnswer.indexOf(temp));
    }
  }

  Future<void> options() async {
    // create my DragTargets for putting my answers in.

    for (int i = 0; i < answerArray.length; i++) {
      // create place holder for DragTarget Widgets
      if (hintArray.contains(answerArray[i]) && showHint) {
        solution.add(answerArray[i]); // add my hints to the solutions array
      } else {
        solution.add("");
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
                      border: Border.all(color: Colors.black)),
                  child: Center(child: Text(answerArray[i])),
                )
              : DragTarget(onWillAccept: (value) {
                  return true;
                }, onAccept: (value) {
                  setState(() {
                    solution[i] = value as String;
                    playerAnswer = playerAnswer + solution[i];
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
                                  {"laststop": currentQuestionIndex + 1},
                                  (widget.stageNumber - 1));

                              currentQuestionIndex++;
                              showHint = false; //reset the hint state
                            })
                          : showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) {
                                /* update the stage status because the user has answered all questions correctly */
                                // we assume that the for the user to reach this point the user must have
                                // answered all the questions correctly
                                DatabaseAccess.updateTable("stages",
                                    {"done": 0}, widget.stageNumber - 1);

                                /** play cheering sound because user has passed a stage **/
                                player = AudioPlayer();
                                player.setAsset("lib/audio/cheering.mp3");
                                player.play();
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
                      resetGame();
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

                    if (playerAnswer ==
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
                              playerAnswer = ""; //reset the players answer
                              guessesArray = []; //reset the guesses
                              a = []; //empty array a first
                              solution = []; //empty the solutions array

                              answerToArray(widget
                                  .questions[currentQuestionIndex]
                                  .answer); //to recreate the options box with the new answer
                            })
                          : showDialog(
                              context: context,
                              builder: (_) {
                                /* update the stage status because the user has answered all questions correctly */
                                // we assume that the for the user to reach this point the user must have
                                // answered all the questions correctly
                                DatabaseAccess.updateTable("stages",
                                    {"done": 0}, widget.stageNumber - 1);

                                /** play cheering sound because user has failed a question **/
                                player = AudioPlayer();
                                player.setAsset("lib/audio/cheering.mp3");
                                player.play();
                                /** play cheering because user has failed a question **/

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
                      solution[i],
                      style: TextStyle(
                          color: Colors.brown,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    )),
                  );
                }));
    }
  }

  void answerToArray(String answer) {
    for (int i = 0; i < answer.length; ++i) {
      this.answerArray.add(answer[i]);
    }
    this.answerArrayCopy = this.answerArray;

    createHint(answer); //create the hint

    options(); //create the DragTargets.
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
                                setState(() {
                                  this.showHint =
                                      false; //reset the show hint option to be false;
                                });
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
        // actionsPadding: EdgeInsets.all(0),
        // actionsOverflowButtonSpacing: 0,
        content: Container(
          height: 100,
          child: Column(
            children: [
              // Container(
              //     width: 150,
              //     height: 150,
              //     child: Image.asset("lib/images/champ_cup.gif")
              //
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Padding(padding: EdgeInsets.only(right: 10)),
              //     Text(
              //       "Hurray Champ, Stage ${widget.stageNumber} cleared",
              //       style: TextStyle(
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // ),
              // Padding(padding: EdgeInsets.only(bottom: 10)),
              // Expanded(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       if (this.currentLivesLeft < 5)
              //         Text("+2  ",
              //             style: TextStyle(
              //               fontSize: 20,
              //               fontWeight: FontWeight.bold,
              //             )),
              //       Icon(
              //         Icons.favorite,
              //         color: Colors.red,
              //       ),
              //     ],
              //   ),
              // ),
              // Padding(padding: EdgeInsets.only(bottom: 10)),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: IconButton(
                        //option to try again with reduced life
                        onPressed: () {
                          setState(() {
                            this.showHint =
                                false; //reset the show hint option to be false;
                            guessesArray = [];
                            answerArrayCopy = [];
                            answerArray = [];
                            this.currentQuestionIndex = 0;
                          });
                          resetGame();
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
                        onPressed: () {
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
              // Padding(padding: EdgeInsets.only(bottom: 20)),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       "To next Stage?",
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         fontStyle: FontStyle.italic,
              //       ),
              //     ),
              //     Padding(padding: EdgeInsets.only(right: 20)),
              //     Container(
              //         width: 50,
              //         height: 50,
              //         child: Image.asset(
              //             "lib/images/mickey_mouse_disney_hats_off.gif"))
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  adDialog(BuildContext context, int popnumber, bool isHint) {
    int count = 0;
    showGeneralDialog(
        barrierDismissible: false,
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Container(
            color: Colors.blue,
            child: Column(
              children: [
                Text("An AD to be displayed"),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        //give a user one life for the video watched or add clicked

                        DatabaseAccess.updateTable("users",
                            {"life": (currentLivesLeft + 1)}, widget.userId);
                        if (!isHint) {
                          //if it is not a hint, it means the user want more life,
                          // when user has watched video or ad has shown
                          // increase the life
                          this.currentLivesLeft++;
                        }
                      });
                      resetGame();
                      Navigator.popUntil(context, (route) {
                        // remove the two top most pages from the stack
                        return count++ == popnumber;
                      });
                    },
                    child: Text("done"))
              ],
            ),
          );
        });
  }

  void resetGame() {
    /* reset the game so the user can try again */
    setState(() {
      // if player failed the question
      playerAnswer = ""; //reset the players answer
      guessesArray = []; //reset the guesses
      a = []; //empty array a first
      solution = []; //empty the solutions array
      hintArray = []; //reset the hints array

      // options(); //recall this function to recreate the solutions box.
    });
    answerToArray(widget.questions[currentQuestionIndex].answer);
  }

  createLives(int lives) {
    /* Create the lives list */
    this.livesList = [];

    for (int i = 1; i <= 5; i++) {
      if (i <= lives) {
        setState(() {
          livesList.add(GestureDetector(
              child: Icon(
            Icons.favorite,
            color: Colors.red,
            size: 23,
          )));
        });
      } else {
        setState(() {
          livesList.add(GestureDetector(
              child: Stack(children: [
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
          ])));
        });
      }
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
                  Container(
                    width: 100,
                    child: ElevatedButton(
                        onPressed: () {
                          // adDialog(context, 2, false);
                          _loadRewardedAd(); //load a reward Ad video
                          _loadRewardedAd();

                          setState(() {
                            _isGetLivesPressed = true;
                          });

                          if (_isRewardedAdReady) {
                            _rewardedAd.show(onUserEarnedReward:
                                (RewardedAd ad, RewardItem item) {
                              //if the user has viewed the rewarded Ad
                              DatabaseAccess.updateTable(
                                  "users",
                                  {"life": (currentLivesLeft + 1)},
                                  widget.userId); //give the user one extra life
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
                          if (_isGetLivesPressed)
                            CircularProgressIndicator(
                              color: Colors.blue,
                            )
                        ])),
                  )
                ],
              ),
            ),
          );
        }).then((value) {
      if (currentLivesLeft == 0) {
        Navigator.of(context).pushReplacement(createRoute(
            SelectStage())); // if the user didn't watch an ad and he pressed back button or
        // dismisses the alert box take him back to select stage
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
    answerToArray(widget.questions[widget.usersIndex].answer);
    currentLivesLeft = widget.numOfLivesLeft;
    currentQuestionIndex = widget
        .usersIndex; //set the index the user was at so the user can continue

    _initGoogleMobileAds();

    _loadBannerAd();

    _bannerAd.load();

    timer = Timer.periodic(Duration(seconds: 30), (_) {
      if (!_isBannerReady) {
        _loadBannerAd();
        _bannerAd.load();
      }
    });

    Future.delayed(Duration.zero,
        () => {if (this.currentLivesLeft == 0) lifeFinished(context)});

    player = AudioPlayer(); //initialize the audio player

    createLives(currentLivesLeft);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    player.dispose(); //throw the player away
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

  void _loadRewardedAd() {
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
                _isGetLivesPressed = false;
                _rewardedAd.dispose();
              });
              _loadRewardedAd(); // confusing line ? why call it again?
            },
          );

          setState(() {
            _isRewardedAdReady = true;
            // put the show hint here
            // if (_hintPressed) {
            //   // if the user wants to see a hint
            //   showHint = true;
            // }
            _isGetLivesPressed = false;
            _hintPressed = false; //done fetching the ad
          });

          // _rewardedAd.dispose();
        },
        onAdFailedToLoad: (err) {
          print("Unable to load aD $err");

          setState(() {
            _isRewardedAdReady = false;
            _isGetLivesPressed = false;
            _hintPressed = false;
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
                            text: "Please, watch an AD to unlock the hint",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))
                      ])),
                    ],
                  ),
                ));
              });
          _rewardedAd.dispose();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (this.currentLivesLeft == 0)
        ? Container(
            color: Colors.white10,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          )
        : WillPopScope(
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
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
                                            Navigator.of(context)
                                                .pushReplacement(
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
                body: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                            "lib/images/wood1.jpeg",
                          ))),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Center(
                            //     child: Padding(
                            //   padding: const EdgeInsets.only(top: 15.0),
                            //   child: Text.rich(TextSpan(
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 32,
                            //       ),
                            //       children: [
                            //         TextSpan(text: "STAGE  "),
                            //         TextSpan(
                            //             text: "${widget.stageNumber}",
                            //             style: TextStyle(color: Colors.red))
                            //       ])),
                            // )),
                            Container(
                              // color: Colors.transparent,
                              decoration: BoxDecoration(
                                  // border: Border.all()
                                  ),
                              width: 120,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: livesList,
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: 15)),
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
                                                      // color: Colors.black38,
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
                                                                              () {
                                                                            //the user chooses to quit the game, take the user back to the select stage page
                                                                            Navigator.of(context).pushReplacement(createRoute(SelectStage()));
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
                                  )
                                ],
                              ),
                            ),

                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _loadRewardedAd();
                                    setState(() {
                                      _hintPressed = true;
                                    });
                                    if (_isRewardedAdReady) {
                                      _rewardedAd.show(
                                        onUserEarnedReward:
                                            (RewardedAd ad, RewardItem item) {
                                          setState(() {
                                            this.showHint = true;
                                            this._hintPressed = false;
                                          });
                                          resetGame();
                                          _rewardedAd.dispose();
                                        },
                                      );
                                    }
                                  },
                                  // child: Container(
                                  //   decoration: BoxDecoration(
                                  //     image: DecorationImage(
                                  //       image: AssetImage(
                                  //         "lib/images/bulb_light_bulb.gif"
                                  //       )
                                  //     )
                                  //   ),
                                  // )
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                            "lib/images/bulb_light_bulb.gif")),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(bottom: 5)),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: GestureDetector(
                                      onTap: () {},
                                      child: Icon(Icons.undo,
                                          size: 35, color: Colors.white38)),
                                )
                              ],
                            ),
                            //To be clipped for a nice ui
                          ],
                        ),
                      ),
                      Text(
                        "Question ${currentQuestionIndex + 1}",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontFamily: "RoadRage",
                          fontSize: 60,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 2)),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        child: Text(
                          widget.questions[currentQuestionIndex].question,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            fontFamily: "RoadRage",
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                        bottom: 15,
                      )),
                      Expanded(
                        flex: 2,
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              List<String> guesses = [];

                              for (int i = 0; i <= 3; i++) {
                                if (this.answerArrayCopy.length == 1) {
                                  /*
                                       once the loop is equal to 1, then assign it
                                       like that because no ranging
                                  */

                                  guesses.add(this.answerArrayCopy[0]);
                                  this.answerArrayCopy.removeAt(0);
                                } else if (this.answerArrayCopy.length > 0) {
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
                                      rng.nextInt(this.alphabets.length - 1)]);
                                }
                              }

                              //add the guesses to the global array containing all guesses
                              guessesArray.add(guesses);

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Draggable(
                                    onDragCompleted: () async {
                                      /** Play audio for when the target is dropped **/
                                      await player
                                          .setAsset("lib/audio/water_drop.mp3");
                                      player.play();
                                      /** play audio **/

                                      setState(() {
                                        guessesArray[index][0] = "";
                                      });
                                    },
                                    data: guessesArray[index][0],
                                    feedback: Center(
                                      child: Text(guessesArray[index][0],
                                          style: TextStyle(
                                            color: Colors.brown,
                                            fontSize: 60,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          )),
                                    ),
                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][0],
                                              style: TextStyle(
                                                color: Colors.brown,
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                    ),
                                  ),
                                  Draggable(
                                    onDragCompleted: () async {
                                      /** Play audio for when the target is dropped **/
                                      player = AudioPlayer();
                                      await player
                                          .setAsset("lib/audio/water_drop.mp3");
                                      player.play();
                                      /** play audio **/

                                      setState(() {
                                        guessesArray[index][1] = "";
                                      });
                                    },
                                    data: guessesArray[index][1],
                                    feedback: Center(
                                        child: Text(guessesArray[index][1],
                                            style: TextStyle(
                                              color: Colors.brown,
                                              fontSize: 60,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none,
                                            ))),
                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // image: DecorationImage(
                                          //   image: AssetImage(
                                          //       'lib/images/background_image.png'),
                                          // ),
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(
                                        guessesArray[index][1],
                                        style: TextStyle(
                                          color: Colors.brown,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                    ),
                                  ),
                                  Draggable(
                                    onDragCompleted: () async {
                                      /** Play audio for when the target is dropped **/
                                      player = AudioPlayer();
                                      await player
                                          .setAsset("lib/audio/water_drop.mp3");
                                      player.play();
                                      /** play audio **/

                                      setState(() {
                                        guessesArray[index][2] = "";
                                      });
                                    },

                                    data: guessesArray[index][2],

                                    feedback: Center(
                                      child: Text(guessesArray[index][2],
                                          style: TextStyle(
                                            color: Colors.brown,
                                            fontSize: 60,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          )),
                                    ),

                                    /* play sound when the user is dragging */
                                    // onDragStarted: () async {
                                    //   player = AudioPlayer();
                                    //   await player.setAsset(
                                    //       "lib/audio/dragging_sound.mp3");
                                    //   player.play();
                                    // },

                                    // onDragEnd:(DraggableDetails draggableDetails) {
                                    //   player.stop();
                                    // } ,

                                    // onDragUpdate: (DragUpdateDetails
                                    // dragUpdateDetails) async {
                                    //   // player.stop();
                                    //   player.play();
                                    // },
                                    // /* end play sound */

                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),

                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // image: DecorationImage(
                                          //   image: AssetImage(
                                          //       'lib/images/background_image.png'),
                                          // ),
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][2],
                                              style: TextStyle(
                                                color: Colors.brown,
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                    ),
                                  ),
                                  Draggable(
                                    onDragCompleted: () async {
                                      /** Play audio for when the target is dropped **/
                                      player = AudioPlayer();
                                      await player
                                          .setAsset("lib/audio/water_drop.mp3");
                                      player.play();
                                      /** play audio **/

                                      setState(() {
                                        guessesArray[index][3] = "";
                                      });
                                    },

                                    data: guessesArray[index][3],

                                    feedback: Center(
                                        child: Text(guessesArray[index][3],
                                            style: TextStyle(
                                              color: Colors.brown,
                                              fontSize: 60,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none,
                                            ))),

                                    /* play sound when the user is dragging */
                                    // onDragStarted: () async {
                                    //   player = AudioPlayer();
                                    //   await player.setAsset(
                                    //       "lib/audio/dragging_sound.mp3");
                                    //   player.play();
                                    // },

                                    // onDragEnd:(DraggableDetails draggableDetails) {
                                    //   player.stop();
                                    // } ,

                                    // onDragUpdate: (DragUpdateDetails
                                    // dragUpdateDetails) async {
                                    //   // player.stop();
                                    //   player.play();
                                    // },
                                    /* end play sound */

                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),

                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // image: DecorationImage(
                                          //   image: AssetImage(
                                          //       'lib/images/background_image.png'),
                                          // ),
                                          color: Colors.black,
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][3],
                                              style: TextStyle(
                                                color: Colors.brown,
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                              ))),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Padding(
                                  padding: EdgeInsets.only(bottom: 10));
                            },
                            itemCount: 2),
                      ),
                      if (_isBannerReady)
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: _bannerAd.size.width.toDouble(),
                            height: 50,
                            child: AdWidget(ad: _bannerAd),
                          ),
                        ),
                      Expanded(
                          flex: 2,
                          child: GridView.count(
                            padding: EdgeInsets.all(10),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            crossAxisCount: 5,
                            children: this.a,
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showHint = false;
                                      hintArray = [];
                                    });
                                    resetGame();
                                  },
                                  child: Icon(Icons.refresh,
                                      color: Colors.white38, size: 30)),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 8.0, bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: GestureDetector(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.volume_off,
                                    size: 30,
                                    color: Colors.white38,
                                  )),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

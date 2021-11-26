import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_game/controllers/ad_helper.dart';
import 'package:quiz_game/controllers/db.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/stages_map.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/controllers/usersinfo_map.dart';
import 'package:quiz_game/views/home.dart';
import 'package:quiz_game/views/widgets/doublecurvedcontainer.dart';
import 'package:quiz_game/views/widgets/gamelevelbutton.dart';
import 'package:quiz_game/views/widgets/shadowedtext.dart';
import 'package:quiz_game/views/widgets/shineeffect.dart';

class SelectStage extends StatefulWidget {
  const SelectStage({Key? key}) : super(key: key);

  @override
  _SelectStageState createState() => _SelectStageState();
}

class _SelectStageState extends State<SelectStage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  List<Widget> stagesWidget = [];
  List<StagesMap> listOfStag = [];
  List<String> test = ["a", "b"];
  bool isFormerStageCleared = false;
  bool isDisplayAlert = false;
  int accessStage = 0;
  int usersLife = 0;
  List<Widget> widgetList = [];
  int id = 0;
  late RewardedAd _rewardedAd;
  bool _isRewardedAdReady = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setStagesInformation();
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
  }

  @override
  void dispose() {
    super.dispose();
    this._loading = false;
    _rewardedAd.dispose();
    _controller.dispose();
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  setStagesInformation() async {
    this.usersLife = 0;
    // get the number of user life left
    List<UsersInfoMap> tempUserInfo = await DatabaseAccess.usersInfo();
    this.usersLife = tempUserInfo[0].livesLeft;
    this.id = tempUserInfo[0].id;

    this.listOfStag = [];
    //get all the stages information
    List<StagesMap> temp = await DatabaseAccess.theStages();
    this.listOfStag.addAll(temp);

    widgetList = await createWidgeList(temp, tempUserInfo[0].livesLeft);

    setState(() {
      // for some reason build completes before init state, so this as
      // my work around for updating my widgetList.
    });
  }

  int findIndex(List<QuestionsMap> questions) {
    /* TO do
      fix the logic of this issue
     */

    int index = 0;

    for (var i in questions) {
      //check if user has solved a question keep adding up the count
      // else stop once it isn't solve.
      if (i.solved == 0) {
        index++;
      } else {
        break;
      }
    }

    if (index == questions.length - 1) {
      index =
          0; // if user has solved all the questions always restart from the beg
    }

    // print ("to be returned to position $index");
    return index;
  }

  int toLastStop(List<QuestionsMap> questions, int index) {
    //where should the user resume to?

    if (questions.length - 1 == index && questions[index].solved == 0) {
      return 0; //back to the first questions if user has solved all the questions in the current stage
    } else if (questions.length - 1 == index && questions[index].solved == 1) {
      return index;
    } else if (questions[index].solved == 0) {
      return index +
          1; // if question is not the last one and user has solved the current stop move on to the next one
    } else {
      return index; //if user has not solved the current question;
    }
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
        Navigator.of(context).pop(); //remove the errorDialog Widget.

        this._rewardedAd = ad;

        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            setState(() {
              _isRewardedAdReady = false;
              _loading = false;
              _rewardedAd.dispose();
            });
            _loadRewardedAd(); // confusing line ? why call it again?
          },
        );

        setState(() {
          _isRewardedAdReady = true;
        });
      }, onAdFailedToLoad: (err) {
        print("Failed to load a rewarded ad: ${err.message}");

        setState(() {
          _isRewardedAdReady = false;
        });

        Navigator.pop(context); //remove the errorDialog from the widget tree.

        showDialog(
            barrierDismissible: true,
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
                          text: "Please, watch an AD to unlock this stage",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ))
                    ])),
                  ],
                ),
              ));
            }).then((value) => setState(() {
              _loading = false;
            }));
        _rewardedAd.dispose();
      }),
    );
  }

  Future<List<Widget>> createWidgeList(
      List<StagesMap> mapList, int lives) async {
    List<Widget> tempList = [];

    for (int i = 0; i < 20; i++) {
      if (i == 0) {
        tempList.add(
          GameLevelButton(
            width: 80.0,
            height: 60.0,
            borderRadius: 50.0,
            onTap: () async {
              int questionIndex = 0;

              List<QuestionsMap> questions =
                  await DatabaseAccess.stage1Questions();

              questionIndex =
                  findIndex(questions); //get the index of the question

              if (mapList[0].locked == 0) {
                Navigator.of(context).pushReplacement(createRoute(Home(
                  questions: questions,
                  numOfLivesLeft: lives,
                  stageNumber: 1,
                  stageName: mapList[0].stagename,
                  userId: id,
                  usersIndex: toLastStop(questions, listOfStag[0].lastStop),
                )));
              }

              if (mapList[0].locked == 1) {
                adDialog(context, 0, mapList);
              }
            },
            text: "Stage 1",
            icon: (mapList[i].locked == 0)
                ? Icon(
                    Icons.lock_open,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.lock,
                    color: Colors.red,
                  ),
          ),
        );
      } else {
        tempList.add(GameLevelButton(
          width: 80.0,
          height: 60.0,
          borderRadius: 50.0,
          onTap: () async {
            setState(() {
              _loading = true;
            });

            int questionIndex = 0;

            List<QuestionsMap> questions =
                await DatabaseAccess.getStageQuestions(i + 1);

            questionIndex =
                findIndex(questions); //get the index for the question

            if (mapList[i - 1].done == 0 && mapList[i].locked == 0) {
              /* is the former stage cleared? */

              setState(() {
                _loading = false;
              });

              Navigator.of(context).pushReplacement(createRoute(Home(
                questions: questions,
                numOfLivesLeft: lives,
                stageNumber: i + 1,
                stageName: mapList[i].stagename,
                userId: id,
                // if user has solved the last question take the user back to question 1
                // else let the user solve the last question
                usersIndex: ((listOfStag[i].lastStop == questions.length - 1) &&
                        (questions[questions.length - 1].solved == 0))
                    ? 0
                    : listOfStag[i].lastStop,
              )));
            } else if (mapList[i - 1].done == 1 && mapList[i].locked == 0) {
              /* is the former stage not cleared, but the current stage has been unlocked, because
              the user watched an Ad?.
               */
              setState(() {
                _loading = false;
              });
              errorDialog(context, i);
            } else {
              /* Has the user not cleared the former stage and has not watched an Ad,
                 then show the user the add
               */

              _loadRewardedAd(); //load the reward Ad

              if (_isRewardedAdReady) {
                _rewardedAd.show(
                    onUserEarnedReward: (RewardedAd ad, RewardItem item) async {
                  /* if the user has watched the video completely */

                  await DatabaseAccess.updateTable("stages", {"locked": 0},
                      i); //set the current stage to cleared

                  /* Expensive but negligible */
                  setStagesInformation(); //update the stages information

                  setState(() {
                    _loading = false; //remove the linear progress indicator.
                  });

                  _rewardedAd.dispose();
                });
              }
            }
          },
          text: "Stage ${i + 1}",
          icon: (mapList[i].locked == 0)
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
    }

    return tempList;
  }

  adDialog(BuildContext context, int index, List<StagesMap> stagesMapList) {
    int count = 0;
    showGeneralDialog(
        barrierDismissible: false,
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) {
          /*****/
          return Container(
            color: Colors.blue,
            child: Column(
              children: [
                Text("An AD to be displayed"),
                ElevatedButton(
                    onPressed: () async {
                      if (stagesMapList[index - 1].done == 0) {
                        // we will never have to run this on the first index so it is safe
                        // if the player has finished all the questions in the stage before the
                        // current stage
                        setState(() {
                          // stagesMapList[index].locked = 0;
                          this.isFormerStageCleared = true;
                          this.isDisplayAlert = false;
                        });
                        //update the value of the locked
                        await DatabaseAccess.updateTable(
                            "stages", {"locked": 0}, index);
                        setStagesInformation();
                        Navigator.of(context).pop();
                      }

                      if (stagesMapList[index - 1].done == 1) {
                        // if the user has not finished the stage before the current one
                        setState(() {
                          this.isFormerStageCleared = false;
                          this.isDisplayAlert = true;
                          this.accessStage = index;
                        });
                        setStagesInformation();
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text("done"))
              ],
            ),
          );
        });
  }

  errorDialog(BuildContext context, int accessStage) {
    int currentStage = accessStage;

    showDialog(
        barrierDismissible: true,
        // routeSettings: ,
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text("Please Finish Stage ${currentStage}"),
          );
        }).then((value) => setState(() {
          // isFormerStageCleared = false;
          isDisplayAlert = false;
        }));
  }

  loadingDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(100),
            backgroundColor: Colors.transparent,
            content: Container(child: CircularProgressIndicator()),
          );
        }).then((value) => setState(() {
          _loading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
        //if the user clicked on the next stage button and
        // the user has not cleared the former stage
        // display this alert, fixes the setState issue
        Duration.zero,
        () => {
              if (!isFormerStageCleared && isDisplayAlert)
                errorDialog(context, accessStage)
            });

    Future.delayed(
        // if the user clicked on the next stage and there is no
        // internet to watch the next stage then show this
        // alert button, also fixes the setState issue.
        Duration.zero,
        () => {if (_loading) loadingDialog()});

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    Size screenSize = mediaQueryData.size;
    double levelsWidth = -100.0 +
        ((mediaQueryData.orientation == Orientation.portrait)
            ? screenSize.width
            : screenSize.height);

    return SafeArea(
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
    ));
  }
}

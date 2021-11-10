import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:quiz_game/controllers/db.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/views/select_stage.dart';
import 'dart:math';

import 'package:quiz_game/views/widgets/triangle_cripple.dart';

// import 'package:quiz_game/views/widgets/alert.dart';

class Home extends StatefulWidget {
  final List<QuestionsMap> questions;
  final int numOfLivesLeft;
  final int stageNumber;
  final String stageName;
  final int userId;
  final int usersIndex;

  const Home({
    Key? key,
    required this.questions,
    required this.numOfLivesLeft,
    required this.stageNumber,
    required this.stageName,
    required this.userId,
    required this.usersIndex,
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

  // String hint = "";

  bool checkAnswer(String answer, String attempt) {
    if (answer == attempt) {
      print("Go to next question");
      return true;
    } else {
      print("Remove life");
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
    print("the size of numer of hints is : : $numberOfHints");
    var toArrayAnswer = answer.split("");
    for (int i = 0; i < numberOfHints; i++) {
      //create the hint randomly
      // this.hint = this.hint + question[rng.nextInt(question.length - 1)];

      print("To arrayquestions ${toArrayAnswer}");
      String temp = toArrayAnswer[rng.nextInt(toArrayAnswer.length - 1)];
      hintArray.add(temp);
      toArrayAnswer.removeAt(toArrayAnswer.indexOf(temp));

      print("The hint array is $hintArray");
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

      // print ("The solution is $solution");

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
                  // print ("THe new solution is $solution");

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
                          : showDialog(
                              barrierColor: Colors.transparent,
                              barrierDismissible: false,
                              context: (context),
                              builder: (_) {
                                return Alert(currentLivesLeft);
                              });
                      //to recreate the options box
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

                              currentQuestionIndex++;
                              playerAnswer = ""; //reset the players answer
                              guessesArray = []; //reset the guesses
                              a = []; //empty array a first
                              solution = []; //empty the solutions array
                            })
                          : showDialog(
                              context: context,
                              builder: (_) {
                                /* update the stage status because the user has answered all questions correctly */
                                // we assume that the for the user to reach this point the user must have
                                // answered all the questions correctly
                                DatabaseAccess.updateTable("stages",
                                    {"done": 0}, widget.stageNumber - 1);

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
                      answerToArray(widget.questions[currentQuestionIndex]
                          .answer); //to recreate the options box with the new answer
                    } else {
                      DatabaseAccess.updateTable("users",
                          {"life": (currentLivesLeft - 1)}, widget.userId);
                      //user failed the question
                      setState(() {
                        currentLivesLeft--;

                        showHint = false; //reset the hint state
                      });

                      // if lives left is 0, show the alertdialog without the option to tryagain
                      // else show the alert dialog with option to try again
                      (currentLivesLeft == 0)
                          ? lifeFinished(context)
                          : showDialog(
                              barrierColor: Colors.transparent,
                              barrierDismissible: false,
                              context: (context),
                              builder: (_) {
                                return Alert(currentLivesLeft);
                              });
                      //to recreate the options box
                    }
                  }
                }, builder: (context, candidateData, rejectedData) {
                  // ab = candidateData[0] as String;
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('lib/images/background_image.png'),
                        ),
                        border: Border.all(color: Colors.black)),
                    child: Center(child: Text(solution[i])),
                  );
                }));
    }
  }

  void answerToArray(String answer) {
    //Put the answer in an array
    for (int i = 0; i < answer.length; ++i) {
      // print ("$i and ${answer[i]}");
      this.answerArray.add(answer[i]);
      // print (this.answerArray);
    }
    // print (answerArray);
    this.answerArrayCopy = this.answerArray;
    // print ("$answerArray is answerarraycopy");

    createHint(answer); //create the hint

    options(); //create the DragTargets.
  }

  Widget Alert(int numOfLives) {
    return Container(
      //     height: 50,
      // width: 50,
      child: AlertDialog(
        // insetPadding: EdgeInsets.all(60),
        backgroundColor: Color(0xFF255958),
        actionsPadding: EdgeInsets.all(0),
        actionsOverflowButtonSpacing: 0,

        // backgroundColor: Colors.transparent,
        // actions: [
        //   IconButton(
        //     padding: EdgeInsets.all(0),
        //     onPressed: () {},
        //     icon: Icon(
        //       Icons.cancel,
        //       color: Colors.red,
        //     ),
        //   )
        // ],
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
                  Text("${numOfLives} lives left")
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),
              Container(
                  width: 90,
                  height: 90,
                  child: Image.asset("lib/images/sad_cat.gif")),
              // Padding(padding: EdgeInsets.only(bottom: 10)),
              Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      //option to try again with reduced life
                      onPressed: () {
                        resetGame();
                        setState(() {
                          this.showHint =
                              false; //reset the show hint option to be false;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.repeat),
                          Text("Try Again"),
                        ],
                      )),
                  // ElevatedButton(
                  //     onPressed: () {
                  //       adDialog(context, 2, false);
                  //     },
                  //     child: Text("Hint"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget nextStageDialog() {
    return Container(
      //     height: 50,
      // width: 50,
      child: AlertDialog(
        insetPadding: EdgeInsets.all(0),
        backgroundColor: Color(0xFF255958),
        actionsPadding: EdgeInsets.all(0),
        actionsOverflowButtonSpacing: 0,

        // backgroundColor: Colors.transparent,
        // actions: [
        //   IconButton(
        //     padding: EdgeInsets.all(0),
        //     onPressed: () {},
        //     icon: Icon(
        //       Icons.cancel,
        //       color: Colors.red,
        //     ),
        //   )
        // ],
        content: Container(
          height: 350,
          // width: 400,
          child: Column(
            children: [
              Container(
                  width: 150,
                  height: 150,
                  child: Image.asset("lib/images/champ_cup.gif")),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.only(right: 10)),
                  Text(
                    "Hurray Champ, Stage ${widget.stageNumber} cleared",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 10)),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("+2  ",style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                    Icon(Icons.favorite,color: Colors.red,),
                  ],
                ),
              ),

              Padding(padding: EdgeInsets.only(bottom: 10)),


              // Padding(padding: EdgeInsets.only(bottom: 10)),
              Expanded(
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
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
                          child: Row(
                            children: [
                              Icon(Icons.repeat),
                              Text("Replay?"),
                            ],
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            // adDialog(context, 1, false);
                            // int count = 0;
                            // Navigator.popUntil(context, (route) {
                            //   // remove the two top most pages from the stack
                            //   return count++ == 2;
                            // });
                            Navigator.of(context)
                                .pushReplacement(createRoute(SelectStage()));
                          },
                          child: Text("Next Stage?")),
                    )
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "To next Stage?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(right: 20)),
                  Container(
                      width: 50,
                      height: 50,
                      child: Image.asset(
                          "lib/images/mickey_mouse_disney_hats_off.gif"))
                ],
              )
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

  lifeFinished(BuildContext context) {
    return showDialog(
        context: context,
        builder: (_) {
          return Container(
            //     height: 50,
            // width: 50,
            child: AlertDialog(
              // insetPadding: EdgeInsets.all(60),
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
                    // Padding(padding: EdgeInsets.only(bottom: 10)),
                    Container(
                      width: 100,
                      child: ElevatedButton(
                          onPressed: () {
                            adDialog(context, 2, false);
                          },
                          child: Text("Get More Life")),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    answerToArray(widget.questions[0].answer);
    currentLivesLeft = widget.numOfLivesLeft;
    currentQuestionIndex = widget.usersIndex; //set the index the user was at so the user can continue
  }

  @override
  Widget build(BuildContext context) {
    // options();
    // answerToArray(widget.questions[0].answer);
    // print ("in build");

    return (widget.numOfLivesLeft == 0)
        ? (lifeFinished(context))
        : WillPopScope(
      onWillPop: () async {


        showDialog(

          barrierColor: Colors.transparent,

          context: context,
          builder: (_) {
            return AlertDialog(
              // actionsPadding: EdgeInsets.all(0),
              // actionsOverflowButtonSpacing: 0,
              contentPadding: EdgeInsets.all(0),
              content: Container(
                color: Color(0xFF255958),
                height: 200,
                // margin: EdgeInsets.all(0),
                // padding: EdgeInsets.all(0),
                child: Column(

                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                          "lib/images/sad_cat.gif"
                      ),
                    ),
                    Padding(

                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              //the user chooses to quit the game, take the user back to the select stage page
                              Navigator.of(context).pushReplacement(createRoute(SelectStage()));
                            },
                            child: Text("Quit"),
                          ),
                          ElevatedButton(onPressed: () {
                            //The user chooses not to quit the game
                            Navigator.of(context).pop();
                          }, child: Text("Cancel"))

                        ],
                      ),
                    ),
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
                  color: Color(0xFF255958),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Stack(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Center(
                                child: Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text.rich(TextSpan(
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                  children: [
                                    TextSpan(text: "STAGE  "),
                                    TextSpan(
                                        text: "${widget.stageNumber}",
                                        style: TextStyle(color: Colors.red))
                                  ])),
                            )),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'lib/images/male_user.png')),
                                    borderRadius: BorderRadius.circular(100),
                                    // color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            Text(
                              "${currentLivesLeft}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        "Question ${currentQuestionIndex + 1}",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 10)),
                      Text(
                        widget.questions[currentQuestionIndex].question,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                        bottom: 25,
                      )),
                      Expanded(
                        child: ListView.separated(
                            itemBuilder: (context, index) {
                              // print("The current index is $index");
                              List<String> guesses = [];

                              for (int i = 0; i <= 3; i++) {
                                if (this.answerArrayCopy.length == 1) {
                                  /* once the loop is equal to 1, then assign it
                          like that because no ranging
                        */

                                  guesses.add(this.answerArrayCopy[0]);
                                  this.answerArrayCopy.removeAt(0);
                                  // print ("length ${this.answerArrayCopy.length}");
                                } else if (this.answerArrayCopy.length > 0) {
                                  /*
                          Loop through the answersCopy if the length
                          is greater than 0 add it to the array
                        */

                                  int arrayIndex = rng
                                      .nextInt(this.answerArrayCopy.length - 1);
                                  guesses.add(this.answerArrayCopy[arrayIndex]);

                                  this.answerArrayCopy.removeAt(arrayIndex);
                                } else {
                                  guesses.add(this.alphabets[
                                      rng.nextInt(this.alphabets.length - 1)]);
                                }
                              }

                              //add the guesses to the global array containing all guesses
                              guessesArray.add(guesses);

                              // print(
                              //     "the size of the guessarray is $guessesArray");
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Draggable(
                                    onDragCompleted: () {
                                      setState(() {
                                        // print ("editing guesses!!");
                                        guessesArray[index][0] = "";
                                      });
                                    },
                                    data: guessesArray[index][0],
                                    feedback: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][0])),
                                    ),
                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][0])),
                                    ),
                                  ),
                                  Draggable(
                                    onDragCompleted: () {
                                      setState(() {
                                        guessesArray[index][1] = "";
                                      });
                                    },
                                    data: guessesArray[index][1],
                                    feedback: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][1])),
                                    ),
                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][1])),
                                    ),
                                  ),
                                  Draggable(
                                    onDragCompleted: () {
                                      setState(() {
                                        guessesArray[index][2] = "";
                                      });
                                    },
                                    data: guessesArray[index][2],
                                    feedback: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][2])),
                                    ),
                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][2])),
                                    ),
                                  ),
                                  Draggable(
                                    onDragCompleted: () {
                                      setState(() {
                                        guessesArray[index][3] = "";
                                      });
                                    },
                                    data: guessesArray[index][3],
                                    feedback: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][3])),
                                    ),
                                    childWhenDragging: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          // color: Colors.blue,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'lib/images/background_image.png'),
                                          ),
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Center(
                                          child: Text(guessesArray[index][3])),
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
                      Expanded(
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
                          // ClipPath(
                          //   clipper: TriangleClipper(),
                          //   child: ElevatedButton(onPressed: () {}, child: Text("Hint")),
                          // )

                          // ClipRRect(
                          //
                          // )
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showHint = false;
                                  hintArray = [];
                                });
                                resetGame();
                              },
                              child: Text("Clear")),
                          ElevatedButton(
                              onPressed: () {
                                adDialog(context, 1, true);
                                resetGame();
                                setState(() {
                                  showHint = true;
                                });
                              },
                              child: Text("Hint")),
                          //To be clipped for a nice ui
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

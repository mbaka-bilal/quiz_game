import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_game/controllers/db.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/stages_map.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/controllers/usersinfo_map.dart';
import 'package:quiz_game/views/home.dart';

class SelectStage extends StatefulWidget {
  const SelectStage({Key? key}) : super(key: key);

  @override
  _SelectStageState createState() => _SelectStageState();
}

class _SelectStageState extends State<SelectStage> {


  List<Widget> stagesWidget = [];
  List<StagesMap> listOfStag = [];
  List<String> test = ["a", "b"];
  bool isFormerStageCleared = false;
  bool isDisplayAlert = false;
  int accessStage = 0;
  int usersLife = 0;
  List<Widget> widgetList = [];
  int id = 0;


  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    setStagesInformation();


  }

  setStagesInformation() async {

    this.usersLife = 0;
    // get the number of user life left
    List<UsersInfoMap> tempUserInfo = await DatabaseAccess.usersInfo();
    this.usersLife = tempUserInfo[0].livesLeft;
    this.id = tempUserInfo[0].id;

    print ("users life left is $usersLife");

    this.listOfStag = [];
    //get all the stages information
    List<StagesMap> temp = await DatabaseAccess.theStages();
    this.listOfStag.addAll(temp);

    print ("The list of stages $listOfStag");

    widgetList = await createWidgeList(temp,tempUserInfo[0].livesLeft);

    setState(() {
      // for some reason build completes before init state, so this as
      // my work around for updating my widgetList.
    });
  }

  int findIndex(List<QuestionsMap> questions){
    /* TO do
      fix the logic of this issue
     */

    int index = 0;

    for (var i in questions){
      //check if user has solved a question keep adding up the count
      // else stop once it isn't solve.
      if (i.solved == 0){
        index++;
      }else{
        break;
      }
    }

    if (index == questions.length - 1){
      index = 0; // if user has solved all the questions always restart from the beg
    }
    return index;
  }



  Future<List<Widget>> createWidgeList(List<StagesMap> mapList, int lives) async{
    List<Widget> tempList = [];

    for (int i = 0; i < 20; i++) {
      if (i == 0) {
        tempList.add(
          GestureDetector(
            onTap: () async {
              // await setStagesInformation();
              int questionIndex = 0;

              List<QuestionsMap> questions =
              await DatabaseAccess.stage1Questions();

              questionIndex = findIndex(questions); //get the index of the question

              if (mapList[0].locked == 0) {
                Navigator.of(context).push(createRoute(Home(
                  questions: questions,
                  numOfLivesLeft: lives,
                  stageNumber: 1,
                  stageName: mapList[0].stagename,
                  userId: id,
                  usersIndex: 0,
                )));
              }

              if (mapList[0].locked == 1) {
                adDialog(context, 0,mapList);
              }
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Stage 1"),
                  Padding(padding: EdgeInsets.only(bottom: 10)),
                  (mapList[0].locked == 0)
                      ? Icon(Icons.lock_open)
                      : Icon(Icons.lock)
                ],
              ),
            ),
          ),
        );
      } else {
        tempList.add(GestureDetector(
          onTap: () async {
            int questionIndex = 0;

            // await setStagesInformation();
            List<QuestionsMap> questions =
            await DatabaseAccess.getStageQuestions(i + 1);

            questionIndex = findIndex(questions); //get the index for the question

            if (mapList[i - 1].locked == 0 && mapList[i].locked == 0) {
              Navigator.of(context).push(createRoute(Home(
                questions: questions,
                numOfLivesLeft: lives,
                stageNumber: i + 1,
                stageName: mapList[i].stagename,
                userId: id,
                usersIndex: 0,
              )));
            }

            if (mapList[i].locked == 1) {
              adDialog(context, i,mapList);
            }
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Stage ${i+1}"),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                (mapList[i].locked == 0)
                    ? Icon(Icons.lock_open)
                    : Icon(Icons.lock)
              ],
            ),
          ),
        ));
      }
    }


    return tempList;

  }

  adDialog(BuildContext context, int index,List<StagesMap> stagesMapList) {
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







  @override
  Widget build(BuildContext context) {
    // print ("THe current life is ${DatabaseAccess.usersInfo().toString()}");

    // show the alert box if user has not finished the former stage, and the user
    // just came from watching an ad to unlock the new stage.
    Future.delayed(
        Duration.zero,
            () => ((!isFormerStageCleared && isDisplayAlert)
            ? errorDialog(context, accessStage)
            : Container()));


    return SafeArea(
        child: Scaffold(
          body: Container(
              color: Color(0xFF255958),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(bottom: 20)),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      padding: EdgeInsets.all(20),

                      children: this.widgetList,
                      // children: [

                      // GestureDetector(
                      //   onTap: () async {
                      //     await setStagesInformation();
                      //     List<QuestionsMap> questions =
                      //         await DatabaseAccess.stage1Questions();
                      //     if (listOfStag[0].locked == 0){
                      //
                      //     Navigator.of(context).push(createRoute(Home(
                      //       questions: questions,
                      //       numOfLivesLeft: this.usersLife,
                      //       stageNumber: 1,
                      //       stageName: listOfStag[0].stagename,
                      //     )));
                      //   }
                      //
                      //     if (listOfStag[0].locked == 1){
                      //       adDialog(context,0);
                      //     }
                      //
                      //     },
                      //   child: Card(
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text("Stage 1"),
                      //         Padding(padding: EdgeInsets.only(bottom: 10)),
                      //         (listOfStag[0].locked == 0) ? Icon(Icons.lock_open) : Icon(Icons.lock)
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // GestureDetector(
                      //   onTap: () async {
                      //     await setStagesInformation();
                      //     // print ("value of second stage state is : ${listOfStag[1].locked}");
                      //
                      //
                      //     if (listOfStag[1].locked == 0){
                      //       List<QuestionsMap> questions =
                      //       await DatabaseAccess.stage2Questions();
                      //       Navigator.of(context).push(createRoute(Home(
                      //         questions: questions,
                      //         numOfLivesLeft: 5,
                      //         stageNumber: 2,
                      //         stageName: listOfStag[1].stagename,
                      //       )));
                      //     }
                      //
                      //     if (listOfStag[1].locked == 1){
                      //       adDialog(context,1);
                      //     }
                      //
                      //     // Navigator.of(context).push(createRoute(Home(
                      //     //   questions: questions,
                      //     //   numOfLivesLeft: 5,
                      //     //   stageNumber: 2,
                      //     // )));
                      //   },
                      //   child: Card(
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text("Stage 2"),
                      //         Padding(padding: EdgeInsets.only(bottom: 10)),
                      //         Icon((listOfStag[1].locked == 0) ?  Icons.lock_open : Icons.lock)
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // GestureDetector(
                      //   onTap: () async {
                      //     await setStagesInformation();
                      //     // print ("value of second stage state is : ${listOfStag[1].locked}");
                      //
                      //
                      //     if (listOfStag[2].locked == 0){
                      //       List<QuestionsMap> questions =
                      //       await DatabaseAccess.stage2Questions();
                      //       Navigator.of(context).push(createRoute(Home(
                      //         questions: questions,
                      //         numOfLivesLeft: 5,
                      //         stageNumber: 3,
                      //         stageName: listOfStag[2].stagename,
                      //       )));
                      //     }
                      //
                      //     if (listOfStag[2].locked == 1){
                      //       adDialog(context,2);
                      //     }
                      //   },
                      //   child: Card(
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text("Stage 3"),
                      //         Padding(padding: EdgeInsets.only(bottom: 10)),
                      //         Icon((listOfStag[1].locked == 0) ?  Icons.lock_open : Icons.lock)
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // ],
                    ),
                  ),
                ],
              )),
        ));

    // return FutureBuilder(
    //
    //   //check if the list of widgets has been created.
    //
    //     future: createWidgeList(),
    //     builder: (context,AsyncSnapshot snapShot) {
    //       if (snapShot.hasData) {
    //         return SafeArea(
    //             child: Scaffold(
    //               body: Container(
    //                   color: Color(0xFF255958),
    //                   child: Column(
    //                     children: [
    //                       Padding(padding: EdgeInsets.only(bottom: 20)),
    //                       Expanded(
    //                         child: GridView.count(
    //                           crossAxisCount: 2,
    //                           padding: EdgeInsets.all(20),
    //
    //                           children: widgetList,
    //                           // children: [
    //
    //                           // GestureDetector(
    //                           //   onTap: () async {
    //                           //     await setStagesInformation();
    //                           //     List<QuestionsMap> questions =
    //                           //         await DatabaseAccess.stage1Questions();
    //                           //     if (listOfStag[0].locked == 0){
    //                           //
    //                           //     Navigator.of(context).push(createRoute(Home(
    //                           //       questions: questions,
    //                           //       numOfLivesLeft: this.usersLife,
    //                           //       stageNumber: 1,
    //                           //       stageName: listOfStag[0].stagename,
    //                           //     )));
    //                           //   }
    //                           //
    //                           //     if (listOfStag[0].locked == 1){
    //                           //       adDialog(context,0);
    //                           //     }
    //                           //
    //                           //     },
    //                           //   child: Card(
    //                           //     child: Column(
    //                           //       mainAxisAlignment: MainAxisAlignment.center,
    //                           //       children: [
    //                           //         Text("Stage 1"),
    //                           //         Padding(padding: EdgeInsets.only(bottom: 10)),
    //                           //         (listOfStag[0].locked == 0) ? Icon(Icons.lock_open) : Icon(Icons.lock)
    //                           //       ],
    //                           //     ),
    //                           //   ),
    //                           // ),
    //
    //                           // GestureDetector(
    //                           //   onTap: () async {
    //                           //     await setStagesInformation();
    //                           //     // print ("value of second stage state is : ${listOfStag[1].locked}");
    //                           //
    //                           //
    //                           //     if (listOfStag[1].locked == 0){
    //                           //       List<QuestionsMap> questions =
    //                           //       await DatabaseAccess.stage2Questions();
    //                           //       Navigator.of(context).push(createRoute(Home(
    //                           //         questions: questions,
    //                           //         numOfLivesLeft: 5,
    //                           //         stageNumber: 2,
    //                           //         stageName: listOfStag[1].stagename,
    //                           //       )));
    //                           //     }
    //                           //
    //                           //     if (listOfStag[1].locked == 1){
    //                           //       adDialog(context,1);
    //                           //     }
    //                           //
    //                           //     // Navigator.of(context).push(createRoute(Home(
    //                           //     //   questions: questions,
    //                           //     //   numOfLivesLeft: 5,
    //                           //     //   stageNumber: 2,
    //                           //     // )));
    //                           //   },
    //                           //   child: Card(
    //                           //     child: Column(
    //                           //       mainAxisAlignment: MainAxisAlignment.center,
    //                           //       children: [
    //                           //         Text("Stage 2"),
    //                           //         Padding(padding: EdgeInsets.only(bottom: 10)),
    //                           //         Icon((listOfStag[1].locked == 0) ?  Icons.lock_open : Icons.lock)
    //                           //       ],
    //                           //     ),
    //                           //   ),
    //                           // ),
    //
    //                           // GestureDetector(
    //                           //   onTap: () async {
    //                           //     await setStagesInformation();
    //                           //     // print ("value of second stage state is : ${listOfStag[1].locked}");
    //                           //
    //                           //
    //                           //     if (listOfStag[2].locked == 0){
    //                           //       List<QuestionsMap> questions =
    //                           //       await DatabaseAccess.stage2Questions();
    //                           //       Navigator.of(context).push(createRoute(Home(
    //                           //         questions: questions,
    //                           //         numOfLivesLeft: 5,
    //                           //         stageNumber: 3,
    //                           //         stageName: listOfStag[2].stagename,
    //                           //       )));
    //                           //     }
    //                           //
    //                           //     if (listOfStag[2].locked == 1){
    //                           //       adDialog(context,2);
    //                           //     }
    //                           //   },
    //                           //   child: Card(
    //                           //     child: Column(
    //                           //       mainAxisAlignment: MainAxisAlignment.center,
    //                           //       children: [
    //                           //         Text("Stage 3"),
    //                           //         Padding(padding: EdgeInsets.only(bottom: 10)),
    //                           //         Icon((listOfStag[1].locked == 0) ?  Icons.lock_open : Icons.lock)
    //                           //       ],
    //                           //     ),
    //                           //   ),
    //                           // ),
    //
    //                           // ],
    //                         ),
    //                       ),
    //                     ],
    //                   )),
    //             ));
    //       }else{
    //         return Scaffold(
    //           body: Container(child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: [
    //               Container(
    //                 width: MediaQuery.of(context).size.width,
    //               ),
    //               LinearProgressIndicator(
    //
    //               ),
    //               Text("Loading..."),
    //             ],
    //           )),
    //         );
    //       }
    //     });
  }
}

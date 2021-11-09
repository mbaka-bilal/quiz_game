import 'package:flutter/material.dart';
import 'package:quiz_game/controllers/db.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/stages_map.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/views/home.dart';

class SelectStage extends StatefulWidget {
  const SelectStage({Key? key}) : super(key: key);

  @override
  _SelectStageState createState() => _SelectStageState();
}

class _SelectStageState extends State<SelectStage> {
  List<Widget> stagesWidget = [];
  List<StagesMap> listOfStag = [];
  List<String> test = ["a","b"];

  /* To Do
    Optimize the code to use less lines,
    maybe a function?
   */

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setStagesInformation();
  }

  void setStagesInformation() async {
    this.listOfStag = [];
    // print (listOfStag);
    this.listOfStag  = await DatabaseAccess.theStages();
  }

  adDialog(BuildContext context,int index) {
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
                       listOfStag[index].locked = 0;
                     });

                      Navigator.of(context).pop();
                    },
                    child: Text("done"))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    setStagesInformation();

    print ("in build ${this.listOfStag[0].locked}");

    // print ("$test");


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
                  children: [



                    GestureDetector(
                      onTap: () async {
                        setStagesInformation();
                        List<QuestionsMap> questions =
                            await DatabaseAccess.stage1Questions();
                        if (listOfStag[0].locked == 0){

                        Navigator.of(context).push(createRoute(Home(
                          questions: questions,
                          numOfLivesLeft: 5,
                          stageNumber: 1,
                          stageName: listOfStag[0].stagename,
                        )));
                      }

                        if (listOfStag[0].locked == 1){
                          adDialog(context,0);
                        }

                        },
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Stage 1"),
                            Padding(padding: EdgeInsets.only(bottom: 10)),
                            // (listOfStag[0].locked == 0) ? Icon(Icons.lock_open) : Icon(Icons.lock)
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () async {
                        setStagesInformation();

                        List<QuestionsMap> questions =
                            await DatabaseAccess.stage2Questions();

                        if (listOfStag[1].locked == 0){

                          Navigator.of(context).push(createRoute(Home(
                            questions: questions,
                            numOfLivesLeft: 5,
                            stageNumber: 2,
                            stageName: listOfStag[1].stagename,
                          )));
                        }

                        if (listOfStag[1].locked == 1){
                          adDialog(context,1);
                        }

                        // Navigator.of(context).push(createRoute(Home(
                        //   questions: questions,
                        //   numOfLivesLeft: 5,
                        //   stageNumber: 2,
                        // )));
                      },
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Stage 2"),
                            Padding(padding: EdgeInsets.only(bottom: 10)),
                            // Icon((listOfStag[1].locked == 0) ?  Icons.lock_open : Icons.lock)
                          ],
                        ),
                      ),
                    ),


                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Stage 3"),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Icon(Icons.lock)
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Stage 4"),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Icon(Icons.lock),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Stage 5"),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Icon(Icons.lock),
                        ],
                      ),
                    ),
                    Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Stage 6"),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Icon(Icons.lock),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    ));
  }
}

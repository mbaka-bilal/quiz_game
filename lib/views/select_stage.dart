import 'package:flutter/material.dart';
import 'package:quiz_game/controllers/db.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/views/home.dart';

class SelectStage extends StatefulWidget {
  const SelectStage({Key? key}) : super(key: key);

  @override
  _SelectStageState createState() => _SelectStageState();
}

class _SelectStageState extends State<SelectStage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Container(
          color: Color(0xFF255958   ),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(bottom: 20)),
            Expanded(
              child: GridView.count(crossAxisCount: 2,
                padding: EdgeInsets.all(20),
                children: [
                GestureDetector(
                  onTap: () async { 
                    List<QuestionsMap> questions = await DatabaseAccess.stage1questions();
                    Navigator.of(context).push(createRoute(Home(questions: questions,numOfLivesLeft: 5,stageNumber: 1,)));
                  
                  
                  
                  },
                  child: Card(

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Stage 1"),
                        Padding(padding: EdgeInsets.only(bottom: 10)),
                        Icon(Icons.lock_open)
                      ],
                    ),
                  ),
                ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Stage 2"),
                        Padding(padding: EdgeInsets.only(bottom: 10)),
                        Icon(Icons.lock)
                      ],
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
              ],),
            ),
          ],
        )
      )
      ,
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/views/new_player.dart';

class SelectUser extends StatelessWidget {
  const SelectUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

          body: Container(
        color: Color(0xFF255958   ),
        // height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
            ),

            // Expanded(child: Center(
            //   child: Text("Let's play",style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),), //This should be an animation to show that we about to begin the game
            // )),

            Expanded(child: Center(
              child: Text.rich(
                TextSpan(
                  children: <TextSpan> [
                    TextSpan(
                      text: "Let's play",
                      style: TextStyle(fontSize: 70,fontWeight: FontWeight.bold)
                    ),
                    TextSpan(
                      text: '\nmake sure you beat the highest score, buddy!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                    )
                  ]
                )
              ),
            )),

            // Text('sdfsdfsdfsdf'),
            Expanded(

                child: Scrollbar(
                  isAlwaysShown: true,
                  // showTrackOnHover: true,
                  child: ListView.separated(

                      // shrinkWrap: true,

                      itemBuilder: (context,index) {
              return Container(
                  // width: MediaQuery.of(context).size.width / 1.5,
                  // color: Colors.red,
                  child: ListTile(

                    leading: Text("${index+1}."),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // AssetImage("lib/images/male_user.png");

                        // Padding(padding: EdgeInsets.only(right: 10),),
                        Container(
                          width: 35,
                          height: 35,

                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('lib/images/male_user.png')
                            ),
                            borderRadius: BorderRadius.circular(100),
                            // color: Colors.red,

                          ),



                        ),
                        Padding(padding: EdgeInsets.only(right: 40)),
                        Text("First User $index")
                      ],
                    ),
                  ),
              );
            }, separatorBuilder: (context,index) {return Divider();}, itemCount: 10),
                )),

            Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: ElevatedButton(

                onPressed: () {
                  // The animation used can be found in useful_functions.dart
                  Navigator.of(context).push(createRoute(NewPlayer()));
                },
                child: Container(
                  // color: Colors.white,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("New Player"),
                        Padding(padding: EdgeInsets.only(left: 10),),
                        Container(
                          // color: Colors.blue,
                            width: 30,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                                image: DecorationImage(
                                image: AssetImage(
                                    "lib/images/alien_waving.gif"
                                )
                              )
                            ),
                            // child: Image.asset("lib/images/alien_waving.gif")

                        ),
                      ],
                  ),
                ),
              ),
            )
          ],
        ),
      )),
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_game/controllers/db.dart';

import 'package:quiz_game/views/select_stage.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('lib/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz App', //dont forget to change this to the app name
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  double opacityLevel = 1.0;
  double divider = 1.3;

  //setUp the database;
  var aD = DatabaseAccess();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // #3734eb
    return Scaffold(
      body: Container(
        // color: Color(0xFF255958), //577575
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage("lib/images/questionmark4.jpeg",

                )
            )
        ),

        child: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(bottom: 10)),
              // Container(
              //   width: 200,
              //   height: 200,
              //   child: Image.asset("lib/images/alien_waving.gif"),
              // ),
              Padding(padding: EdgeInsets.only(bottom: 90)),
              Center(
                  child: Text.rich(TextSpan(children: <TextSpan>[
                TextSpan(
                    text: "Quiz",
                    style:
                        TextStyle(fontSize: 80, fontWeight: FontWeight.bold,
                        fontFamily: 'Lobster',
                        )),
                TextSpan(
                    text: " Game",
                    style: TextStyle(
                        fontFamily: 'Lobster',
                      fontSize: 70,
                        fontWeight: FontWeight.bold,
                      color: Colors.green
                    ))
              ]))),
              Expanded(
                  flex: 1,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Container(
                        //     width: MediaQuery.of(context).size.width / 1.3,
                        //     child: ElevatedButton(onPressed: () {
                        //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectUser()));
                        //     }, child: Text("Play ?"))),

                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushReplacement(_createRoute());
                          },
                          child: Container(
                            width: 200,
                            height: 200,
                            // color: Colors.green,
                            child: Wrap(
                              children: [
                                // Container(
                                //   width: 10,
                                //   height: 10,
                                //   color: Colors.red,
                                // )
                                BouncingBall(),
                              ],
                            ),
                          ),
                        ),

                        // Padding(padding: EdgeInsets.only(bottom: 20),),
                        // Container(
                        //     width: MediaQuery.of(context).size.width / divider,
                        //     child: AnimatedOpacity(
                        //         duration: Duration(seconds: 5),
                        //         opacity: opacityLevel,
                        //         child: ElevatedButton(onPressed: () async {
                        //           setState(() {
                        //             opacityLevel = 0.0;
                        //
                        //           });
                        //           await shrinkButton();
                        //           Timer(Duration(seconds: 5),() {Navigator.of(context).push(_createRoute());});
                        //         }, child: Text("Rankings")))),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
        transitionDuration: Duration(
          seconds: 1,
        ),
        pageBuilder: (context, animation, secondaryAnimation) => SelectStage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
  }

  Future<void> shrinkButton() async {
    Timer.periodic(
        Duration(
          seconds: 1,
        ), (Timer t) {
      setState(() {
        if (this.divider <= 1.6) {
          // print (this.divider);
          this.divider = divider + 0.1;
        } else {
          // print ("maximum reached");
          t.cancel();
        }
      });
    });
  }
}

class BouncingBall extends StatefulWidget {
  const BouncingBall({Key? key}) : super(key: key);

  @override
  _BouncingBallState createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 1,
      ),
      lowerBound: 5,
      upperBound: 30,
    );

    controller.addListener(() {
      setState(() {});
    });

    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      margin: EdgeInsets.only(top: controller.value),
      child: Container(
        child: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(
            "Play",
            style: TextStyle(
              fontFamily: "Lobster",
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        width: 200.0,
        height: 190.0,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Alert extends StatefulWidget {
  final int numOfLives;

  const Alert({Key? key, required this.numOfLives}) : super(key: key);

  @override
  _AlertState createState() => _AlertState();
}

class _AlertState extends State<Alert> {
  @override
  Widget build(BuildContext context) {
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
                  Text("${widget.numOfLives} lives left")
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Icon(Icons.repeat),
                          Text("Try Again"),
                        ],
                      )),
                  ElevatedButton(onPressed: () {}, child: Text("Hint"))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

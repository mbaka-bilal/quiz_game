import 'package:flutter/material.dart';
import 'package:quiz_game/controllers/useful_functions.dart';
import 'package:quiz_game/views/home.dart';

class NewPlayer extends StatefulWidget {
  const NewPlayer({Key? key}) : super(key: key);

  @override
  _NewPlayerState createState() => _NewPlayerState();
}

class _NewPlayerState extends State<NewPlayer> {
  String _sex = "female";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

          body: Container(
            color: Color(0xFF255958   ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 180,
                  width: 180,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        "lib/images/female_user.png"
                    ),
                    
                  ),
                  borderRadius: BorderRadius.circular(360)
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 20)),
            Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: TextFormField(
                decoration: InputDecoration(

                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              // width: MediaQuery.of(context).size.width / 1.1,
              height: 50,
              child: Column(

                children: [
                  Expanded(
                    child: ListTile(
                      leading: Radio(
                        value: "male",
                        groupValue: _sex,
                        onChanged: (value) {
                          setState(() {
                            _sex = value as String;
                          });
                        },
                      ),
                      title: Text("Male"),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: Radio(
                        value: "Female",
                        groupValue: _sex,
                        onChanged: (value) {
                          setState(() {
                            _sex = value as String;
                          });
                        },
                      ),
                      title: Text("Female"),
                    ),
                  )
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 25)),
            Container(
              width: MediaQuery.of(context).size.width / 1.2,
              child: ElevatedButton(onPressed: () {
                // Navigator.of(context).push(createRoute(Home()));
              },child: Text("Begin game"),),
            )
          ],
        )
      )),
    );
  }
}

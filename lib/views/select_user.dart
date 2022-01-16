import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../controllers/stages_map.dart';
import '../helpers/connect_to_database.dart';
import '../helpers/create_database.dart';
import '../helpers/player_manager.dart';
import '../helpers/retrieve_from_database.dart';
import '../views/select_stage.dart';
import '../views/widgets/doublecurvedcontainer.dart';
import '../views/widgets/gamelevelbutton.dart';
import '../views/widgets/shadowedtext.dart';
import '../views/widgets/shineeffect.dart';

class SelectUser extends StatefulWidget {
  @override
  _SelectUserState createState() => _SelectUserState();
}

class _SelectUserState extends State<SelectUser>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  List<Widget> players = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  Future<List<GameLevelButton>> getAllPlayersInfo() async {
    /* get all the information about the available players */

    List<GameLevelButton> _players = [];
    Database _dbInstance =
        await ConnectToDatabase(databaseName: "playersDB").connect();

    var _getFromDatabaseObj = RetrieveTablesInformation();

    var _result = await _getFromDatabaseObj.allPlayerInfo(_dbInstance);

    _result.forEach((element) {
      _players.add(GameLevelButton(
          width: 100,
          height: 100,
          borderRadius: 50.0,
          text: element.playerName,
          onTap: () async {
            _dbInstance =
                await ConnectToDatabase(databaseName: element.playerName)
                    .connect();
            var _retrieveInfoDb = RetrieveTablesInformation();
            /* get the selected player stages information */
            List<StagesMap> _stagesInformation =
                await _retrieveInfoDb.playerStagesInfo(_dbInstance);

            // print("the stages information is ${_stagesInformation}");

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => SelectStage(
                          stagesInfo: _stagesInformation,
                          playerInfo: element,
                        )));
          }));
    });

    return _players;
  }

  @override
  Widget build(BuildContext context) {
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
              child: FutureBuilder(
                  future: getAllPlayersInfo(),
                  builder: (ctx, snapShot) {
                    if (snapShot.hasData) {
                      return Container(
                        width: levelsWidth,
                        height: 200,
                        child: GridView.count(
                          crossAxisCount: 3,
                          children: snapShot.data as List<GameLevelButton>,
                        ),
                      );
                    } else if (snapShot.hasError) {
                      return Container(
                        child: Text("Fatal Error"),
                      );
                    } else {
                      return Container(
                          height: 40,
                          child: LinearProgressIndicator(
                            color: Colors.black,
                          ));
                    }
                  }),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        TextEditingController playername =
                            TextEditingController();
                        GlobalKey<FormState> _formKey = GlobalKey<FormState>();

                        void _validate() {
                          final _form = _formKey.currentState;

                          if (!_form!.validate()) {
                            return;
                          }
                        }

                        return AlertDialog(
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actionsPadding: EdgeInsets.symmetric(horizontal: 10),
                          actions: [
                            ElevatedButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              child: Text("Start Game"),
                              onPressed: () async {
                                _validate();

                                /* add the new player to the database */
                                Database _dbInstance = await ConnectToDatabase(
                                        databaseName: "playersDB")
                                    .connect();
                                var _obj = PlayerManager();
                                _obj.createPlayersTable(_dbInstance);
                                _obj.addPlayer(_dbInstance, playername.text);
                                /* done adding new players to the database */

                                /* create a database with the players name*/
                                var _createUserObj = CreateUserDatabase(
                                    databaseName: playername.text);
                                _createUserObj.makeDatabase();
                                /* done creating user database */

                                Navigator.of(context).pop();

                                setState(() {});
                              },
                            ),
                          ],
                          title: Text("New Player"),
                          content: Form(
                            key: _formKey,
                            child: TextFormField(
                                controller: playername,
                                validator: (text) {
                                  if (text!.isEmpty) {
                                    return "Please enter a name";
                                  }
                                },
                                decoration: InputDecoration(
                                    label: Text("Player Name"))),
                          ),
                        );
                      });
                },
                child: Card(
                  elevation: 100.0,
                  color: Colors.transparent,
                  child: CircleAvatar(
                    radius: 50,
                    child: Text(
                      "New Player",
                      style: TextStyle(
                        fontFamily: "Lobster",
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}

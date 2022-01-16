import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sqflite/sqflite.dart';
import 'package:in_app_update/in_app_update.dart';

import '../helpers/create_questions_table.dart';
import '../helpers/notification_service.dart';
import '../helpers/connect_to_database.dart';
import '../helpers/player_manager.dart';
import '../views/select_user.dart';

void main() async {
  // LicenseRegistry.addLicense(() async* {
  //   final license = await rootBundle.loadString('lib/google_fonts/OFL.txt');
  //   yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  // });

  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService()
      .cancelAllNotifications(); // cancel all formerly active notification
  await NotificationService().init(); // initialize the notification service
  await MobileAds.instance.initialize();
  CreateQuestionsTable _obj = CreateQuestionsTable();
  _obj.makeDatabase(); // create the questions table

  PlayerManager _playerManagerObj = PlayerManager();
  Database _dbInstance =
      await ConnectToDatabase(databaseName: "playersDB").connect();
  await _playerManagerObj.createPlayersTable(_dbInstance);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Class', //dont forget to change this to the app name
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
  AppUpdateInfo? _updateInfo;

  Future<void> checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
        if (_updateInfo?.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          print("Update available --------------");
          InAppUpdate.performImmediateUpdate()
              .then((value) => print("updateing immediately----"))
              .catchError((e) => print("Error updating immediatly-----------"));
        } else {
          print("update not available");
        }
      });
    }).catchError((e) {
      print("Error checking for update ---------- $e");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SelectUser());
  }
}

/*
Music: The Cutest Bunny by Shane Ivers - https://www.silvermansound.com
Licensed under Creative Commons Attribution 4.0 International License
https://creativecommons.org/licenses/by/4.0/
Music promoted by https://www.chosic.com/free-music/all/

and link to the guys ui.
*/
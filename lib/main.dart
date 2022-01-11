import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quiz_game/helpers/connect_to_database.dart';
import 'package:quiz_game/helpers/player_manager.dart';
import 'package:quiz_game/views/select_user.dart';
import 'package:sqflite/sqflite.dart';

import '../helpers/create_questions_table.dart';
import '../helpers/notification_service.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('lib/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  WidgetsFlutterBinding.ensureInitialized();
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
  Widget build(BuildContext context) {
    return Scaffold(body: SelectUser());
  }
}

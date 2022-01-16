import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

import '../controllers/questions_map.dart';
import '../controllers/stages_map.dart';
import '../controllers/usersinfo_map.dart';
import '../models/questions.dart';
import '../models/stages.dart';

class DatabaseAccess {
  static late Database db;

  DatabaseAccess() {
    /* constructor */
    WidgetsFlutterBinding.ensureInitialized();
    makeDatabase();
  }

  Future<void> makeDatabase() async {
    final databasePath = await getDatabasesPath();

    final dbPath = join(databasePath, 'questions.db');

    db = await openDatabase(dbPath, version: 1, onCreate: (db, version) {
      createTables(db, version);
    });
  }

  Future<void> createTables(Database db, int v) async {
    print("in create table");

    // creates the tables.
    await db.execute(
      'CREATE TABLE users (id INTEGER PRIMARY KEY,life INTEGER,sound INTEGER,date TEXT)',
    );
    await db.execute(
      'CREATE TABLE stages (id INTEGER PRIMARY KEY,stagename TEXT,laststop INTEGER,locked INTEGER,done INTEGER)',
    );

    for (int i = 1; i <= 20; i++) {
      await db.execute(
        'CREATE TABLE stage$i (id INTEGER PRIMARY KEY,question TEXT,answer TEXT,hint TEXT,solved INTEGER)',
      );
    }

    // end creation of tables

    insertUsers(db);
    insertQuestions(db);
    insertStages(db);
  }

  Future<void> insertUsers(Database db) async {
    await db.insert("users",
        {"id": 0, "life": 5, "sound": 0, "date": DateTime.now().toString()});
  }

  Future<void> insertQuestions(Database db) async {
    for (int i = 0; i <= 31; i++) {
      //insert stage1 questions
      // this works because stage1 is already in a map format.
      await db.insert("stage1", stage1[i]);
      await db.insert("stage2", stage2[i]);
      await db.insert("stage3", stage3[i]);
      await db.insert("stage4", stage4[i]);
      await db.insert("stage5", stage5[i]);
      await db.insert("stage6", stage6[i]);
      await db.insert("stage7", stage7[i]);
      await db.insert("stage8", stage8[i]);
      await db.insert("stage9", stage9[i]);
      await db.insert("stage10", stage10[i]);
      await db.insert("stage11", stage11[i]);
      await db.insert("stage12", stage12[i]);
      await db.insert("stage13", stage13[i]);
      await db.insert("stage14", stage14[i]);
      await db.insert("stage15", stage15[i]);
      await db.insert("stage16", stage16[i]);
      await db.insert("stage17", stage17[i]);
      await db.insert("stage18", stage18[i]);
      await db.insert("stage19", stage19[i]);
      await db.insert("stage20", stage20[i]);
    }
  }

  Future<void> insertStages(Database db) async {
    for (int i = 0; i < 20; i++) {
      await db.insert("stages", listOfStages[i]);
    }
  }

  static Future<void> updateTable(
      String tablename, Map<String, dynamic> content, int id) async {
    await db.update(tablename, content, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<QuestionsMap>> stage1Questions() async {
    /* Get the stage1 questions and put it in an array */
    final List<Map<String, dynamic>> maps = await db.query("stage1");

    return List.generate(maps.length, (index) {
      return QuestionsMap(
          id: maps[index]["id"],
          question: maps[index]["question"],
          answer: maps[index]["answer"],
          hint: maps[index]["hint"]);
    });
  }

  static Future<List<QuestionsMap>> getStageQuestions(int stage) async {
    final List<Map<String, dynamic>> maps = await db.query("stage$stage");

    return List.generate(maps.length, (index) {
      return QuestionsMap(
          id: maps[index]["id"],
          question: maps[index]["question"],
          answer: maps[index]["answer"],
          hint: maps[index]["hint"]);
    });
  }

  static Future<List<StagesMap>> theStages() async {
    /* get all the stages and their information */
    final List<Map<String, dynamic>> maps = await db.query("stages");
    return List.generate(maps.length, (index) {
      return StagesMap(
          id: maps[index]["id"],
          stagename: maps[index]["stagename"],
          lastStop: maps[index]["laststop"],
          locked: maps[index]["locked"],
          done: maps[index]["done"]);
    });
  }

  static Future<List<UsersInfoMap>> usersInfo() async {
    final List<Map<String, dynamic>> maps = await db.query("users");
    return List.generate(maps.length, (index) {
      return UsersInfoMap(
          playerName: maps[index]["sdfsdf"],
          id: maps[index]["id"],
          livesLeft: maps[index]["life"],
          sound: maps[index]["sound"],
          dateTime: maps[index]["date"]);
    });
  }
}

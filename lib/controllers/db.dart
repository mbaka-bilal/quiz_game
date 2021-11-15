import 'package:path/path.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/controllers/stages_map.dart';
import 'package:quiz_game/controllers/usersinfo_map.dart';
import 'package:quiz_game/models/questions.dart';
import 'package:quiz_game/models/stages.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class DatabaseAccess {
  static late Database db;

  DatabaseAccess() {
    /* constructor */
    WidgetsFlutterBinding.ensureInitialized();
    makeDatabase();
    // print (stage1questions(dbAccess));
  }

  Future<void> makeDatabase() async {
    final databasePath = await getDatabasesPath();

    final dbPath = join(databasePath, 'questions.db');

    db = await openDatabase(dbPath, version: 1, onCreate: (db, version) {
      createTables(db, version);
    });

    // createTables(database, 1);
    // insertQuestions(database);
    // stage1questions(database).then((value) => print(value));

    // return database;
  }

  Future<void> createTables(Database db, int v) async {
    print("in create table");

    // creates the tables.
    await db.execute(
      'CREATE TABLE users (id INTEGER PRIMARY KEY,life INTEGER)',
    );
    await db.execute(
      'CREATE TABLE stages (id INTEGER PRIMARY KEY,stagename TEXT,laststop INTEGER,locked INTEGER,done INTEGER)',
    );
    await db.execute(
      'CREATE TABLE stage1 (id INTEGER PRIMARY KEY,question TEXT,answer TEXT,solved INTEGER)',
    );
    await db.execute(
      'CREATE TABLE stage2 (id INTEGER PRIMARY KEY,question TEXT,answer TEXT,solved INTEGER)',
    );

    // end creation of tables

    insertUsers(db);
    insertQuestions(db);
    insertStages(db);
  }

  Future<void> insertUsers(Database db) async {
    await db.insert("users", {"id": 0, "life": 5});
  }

  Future<void> insertQuestions(Database db) async {
    for (int i = 0; i < stage1.length; i++) {
      //insert stage1 questions
      // this works because stage1 is already in a map format.
      await db.insert("stage1", stage1[i]);
    }

    for (int i = 0; i < stage2.length; i++) {
      //insert stage2 questions
      await db.insert("stage2", stage2[i]);
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
          solved: maps[index]["solved"]);
    });
  }

  // static Future<List<QuestionsMap>> stage2Questions() async {
  //   /* Get the stage2 questions and put it in an array */
  //   final List<Map<String, dynamic>> maps = await db.query("stage2");

  //   return List.generate(maps.length, (index) {
  //     return QuestionsMap(
  //         id: maps[index]["id"],
  //         question: maps[index]["question"],
  //         answer: maps[index]["answer"],
  //         solved: maps[index]["solved"]);
  //   });
  // }

  static Future<List<QuestionsMap>> getStageQuestions(int stage) async {
    final List<Map<String, dynamic>> maps = await db.query("stage$stage");

    return List.generate(maps.length, (index) {
      return QuestionsMap(
          id: maps[index]["id"],
          question: maps[index]["question"],
          answer: maps[index]["answer"],
          solved: maps[index]["solved"]);
    });
  }

  static Future<List<StagesMap>> theStages() async {
    /* get all the stages and their information */
    final List<Map<String, dynamic>> maps = await db.query("stages");

    // print ("in the stages function the map is ${maps}");

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

    // print ("in usersInfo the users info is $maps");

    return List.generate(maps.length, (index) {
      return UsersInfoMap(
          id: maps[index]["id"], livesLeft: maps[index]["life"]);
    });
  }
}

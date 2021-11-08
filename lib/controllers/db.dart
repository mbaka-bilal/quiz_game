import 'package:path/path.dart';
import 'package:quiz_game/controllers/questions_map.dart';
import 'package:quiz_game/models/questions.dart';
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

    final dbPath =
      join (databasePath,'questions.db');


    db = await openDatabase(dbPath,version: 1,onCreate: (db,version)  {
      createTables(db,version);
    }



    );

    // createTables(database, 1);
    // insertQuestions(database);
    // stage1questions(database).then((value) => print(value));


    // return database;
  }


  Future<void> createTables(Database db,int v) async {

    print ("in create table");

          // creates the tables.
          await db.execute(
            'CREATE TABLE users (id INTEGER PRIMARY KEY,life INTEGER)', 
          );
           await db.execute(
            'CREATE TABLE stages (id INTEGER PRIMARY KEY,stagename TEXT,locked INTEGER)',
          );
           await db.execute(
             'CREATE TABLE stage1 (id INTEGER PRIMARY KEY,question TEXT,answer TEXT,solved INTEGER)',
           );
           await db.execute(
             'CREATE TABLE stage2 (id INTEGER PRIMARY KEY,question TEXT,answer TEXT,solved INTEGER)',
           );

           // end creation of tables

    insertQuestions(db);
  }

  Future<void> insertQuestions(Database db) async{
      for (int i = 0; i<stage1.length; i++){
        await db.insert("stage1", stage1[i]);
      }

     
  }

  static Future<List<QuestionsMap>> stage1questions() async {
    final List<Map<String,dynamic>> maps = await db.query("stage1");
    
    return List.generate(maps.length, (index) {
        return QuestionsMap(id: maps[index]["id"], question: maps[index]["question"], answer: maps[index]["answer"], solved: maps[index]["solved"]);

    });


  }

}
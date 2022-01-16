import 'package:sqflite/sqflite.dart';

import '../models/stages.dart';

class CreateUserDatabase {
  /* Create a database containing stages information for each of the players */
  String databaseName;
  Database? _dbInstance;

  CreateUserDatabase({required this.databaseName});

  void makeDatabase() async {
    final String _databasePath = await getDatabasesPath();
    final String _dbPath = _databasePath + databaseName;
    _dbInstance = await openDatabase(_dbPath, version: 1);
    _createTables(_dbInstance!);

    _insertStages(_dbInstance!);
  }

  void _createTables(Database db) async {
    await db.execute(
      'CREATE TABLE stagesInformation (id INTEGER PRIMARY KEY NOT NULL,stagename TEXT,laststop INTEGER,locked INTEGER,done INTEGER)',
    );
  }

  Future<void> _insertStages(Database db) async {
    for (int i = 0; i < 20; i++) {
      await db.insert("stagesInformation", listOfStages[i]);
    }
  }
}

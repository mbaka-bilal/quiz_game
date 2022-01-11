import '../models/questions.dart';
import 'package:sqflite/sqflite.dart';

class CreateQuestionsTable {
  Database? _dbInstance;

  void makeDatabase() async {
    final String _databasePath = await getDatabasesPath();
    final String _dbPath = _databasePath + "questions";

    _dbInstance = await openDatabase(_dbPath, version: 1);
    var _tableExists = await _dbInstance!
        .query('sqlite_master', where: 'name=?', whereArgs: ["stage20"]);

    if (_tableExists.isEmpty) {
      // if the tables does not exist create the table and insert the questions
      createQuestionsTable(_dbInstance!);
      insertQuestions(_dbInstance!);
    }
  }

  void createQuestionsTable(Database db) async {
    for (int i = 1; i <= 20; i++) {
      await db.execute(
        'CREATE TABLE stage$i (id INTEGER PRIMARY KEY,question TEXT,answer TEXT,hint TEXT,solved INTEGER)',
      );
    }
  }

  Future<void> insertQuestions(Database db) async {
    for (int i = 0; i <= 31; i++) {
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
}

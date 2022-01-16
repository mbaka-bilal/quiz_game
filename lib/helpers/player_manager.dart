import 'package:sqflite/sqflite.dart';

class PlayerManager {
  /* class to manage all players information */

  Future<void> createPlayersTable(Database db) async {
    /* create the required information for each player stages */

    var _tableInDatabase = await db
        .query('sqlite_master', where: 'name = ?', whereArgs: ['players']);
    if (_tableInDatabase.isEmpty) {
      await db.execute(
        'CREATE TABLE players (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,name TEXT,life INTEGER,sound INTEGER,date TEXT)',
      );
    }
  }

  Future<void> addPlayer(Database db, String playerName) async {
    /* add a new player to the database */

    await db.insert("players", {
      "name": playerName,
      "life": 5,
      "sound": 0,
      "date": DateTime.now().toString()
    });
  }

  Future<void> updatePlayerInfo(
      /* update the player's information */

      Database db,
      Map<String, dynamic> content,
      int id) async {
    await db.update("players", content, where: 'id = ?', whereArgs: [id]);
  }
}

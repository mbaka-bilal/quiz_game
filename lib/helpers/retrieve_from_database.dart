import 'package:sqflite/sqflite.dart';

import '../controllers/questions_map.dart';
import '../controllers/usersinfo_map.dart';
import '../controllers/stages_map.dart';

class RetrieveTablesInformation {
  Future<List<StagesMap>> playerStagesInfo(Database db) async {
    /* get all the stages and their information */
    final List<Map<String, dynamic>> maps = await db.query("stagesInformation");
    return List.generate(maps.length, (index) {
      return StagesMap(
          id: maps[index]["id"],
          stagename: maps[index]["stagename"],
          lastStop: maps[index]["laststop"],
          locked: maps[index]["locked"],
          done: maps[index]["done"]);
    });
  }

  Future<List<UsersInfoMap>> playerInfo(Database db, String playerName) async {
    /* get a player's information */

    final List<Map<String, dynamic>> maps =
        await db.query("players", where: "name=?", whereArgs: [playerName]);
    return List.generate(maps.length, (index) {
      return UsersInfoMap(
          id: maps[index]["id"],
          playerName: playerName,
          livesLeft: maps[index]["life"],
          sound: maps[index]["sound"],
          dateTime: maps[index]["date"]);
    });
  }

  Future<List<UsersInfoMap>> allPlayerInfo(
    Database db,
  ) async {
    /* get all player's information */

    final List<Map<String, dynamic>> maps = await db.query("players");
    return List.generate(maps.length, (index) {
      return UsersInfoMap(
          id: maps[index]["id"],
          livesLeft: maps[index]["life"],
          playerName: maps[index]["name"],
          sound: maps[index]["sound"],
          dateTime: maps[index]["date"]);
    });
  }

  Future<List<QuestionsMap>> getStageQuestions(
      Database db, int stageNumber) async {
    final List<Map<String, dynamic>> maps = await db.query("stage$stageNumber");

    return List.generate(maps.length, (index) {
      return QuestionsMap(
          id: maps[index]["id"],
          question: maps[index]["question"],
          answer: maps[index]["answer"],
          hint: maps[index]["hint"]);
    });
  }

  Future<String> getPlayerLastPlayTime(Database db) async {
    /* return the last player date */
    final List<Map<String, dynamic>> maps = await db.query("players");

    return maps[0]["date"];
  }
}

import 'package:flutter/foundation.dart';
import 'package:quiz_game/controllers/stages_map.dart';
import 'package:quiz_game/helpers/connect_to_database.dart';
import 'package:quiz_game/helpers/retrieve_from_database.dart';
import 'package:sqflite/sqflite.dart';

class PlayerInfo with ChangeNotifier {
  int _livesLeft = 0;
  List<StagesMap> _stageInfo = [];

  int get livesLeft {
    return _livesLeft;
  }

  List<StagesMap> get stagesInfo {
    return [..._stageInfo];
  }

  void updateStageInfomation(Database db, String dbName) async {
    var _dbInstance = await ConnectToDatabase(databaseName: dbName).connect();
    var _retrieveInfoDb = RetrieveTablesInformation();
    /* get the selected player stages information */
    _stageInfo = await _retrieveInfoDb.playerStagesInfo(_dbInstance);
    // nofityListeners();
  }
}

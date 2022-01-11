import 'package:sqflite/sqflite.dart';

class ConnectToDatabase {
  /* class to connect to a database */

  final String databaseName;

  ConnectToDatabase({required this.databaseName});

  Future<Database> connect() async {
    final String _databasePath = await getDatabasesPath();
    final String _dbPath = _databasePath + databaseName;
    final Database dbInstance = await openDatabase(_dbPath, version: 1);
    return dbInstance;
  }
}

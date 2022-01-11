import 'package:sqflite/sqflite.dart';

class UpdateTableInformation {
  Future<void> updateTable(
      String tablename, Map<String, dynamic> content, int id,
      {required Database db}) async {
    await db.update(tablename, content, where: 'id = ?', whereArgs: [id]);
  }
}

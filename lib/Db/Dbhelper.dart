import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Dbhelper {
  static const db_name = "app.db"; // Correct database file name
  static const version = 1;
  static const db_table = "test";
  static const dt_id = "id";
  static const dt_name = "name";
  static const db_email = "email";

  static final Dbhelper instance = Dbhelper();

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await initDB();
    return _database;
  }

  initDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, db_name); // Use db_name here

    return openDatabase(
      path,
      version: version,
      onCreate: onCreate,
    );
  }

  Future onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $db_table (
        $dt_id INTEGER PRIMARY KEY AUTOINCREMENT,
        $dt_name TEXT NOT NULL,
        $db_email TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRecord(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(db_table, row);
  }

  Future<List<Map<String, dynamic>>> querydatabase() async {
    Database? db = await instance.database;
    return await db!.query(db_table);
  }

  Future<int> updaterecord(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    int id = row[dt_id];
    return await db!.update(
      db_table,
      row,
      where: '$dt_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleterecord(int id) async {
    Database? db = await instance.database;
    return await db!.delete(
      db_table,
      where: '$dt_id = ?',
      whereArgs: [id],
    );
  }
}

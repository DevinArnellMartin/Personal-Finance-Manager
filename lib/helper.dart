import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const database = "Projects.db";
  static const dbVer = 1;
  static const table = 'finance';
  static const id = 'id';
  static const expenses = 'expenses';
  static const income = 'income';
  static const name = 'name';
  late Database db;


  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, database);
    db = await openDatabase(
      path,
      version: dbVer,
      onCreate: initDB,
    );
  }

  
  Future initDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
    $id INTEGER PRIMARY KEY,
    $name TEXT NOT NULL,
    $income DECIMAL(10,2) NOT NULL
    $expenses DECIMAL(10,2) NOT NULL
    )
    ''');
  }
  Future<int> insert(Map<String, dynamic> row) async {
    return await db.insert(table, row);
  }

  Future<Map<String, dynamic>?> queryById(int id) async {
    final res = await db.query(
      table,
      where: '$id = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> update(Map<String, dynamic> row) async { 
    return await db.update(
      table,
      row,
      where: '$id = ?',
      whereArgs: [id],
    );
  }

 
  Future<int> del(int id) async {
    return await db.delete(
      table,
      where: '$id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delAll() async { //truncate
    return await db.delete(table);
  }
}

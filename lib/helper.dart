import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const database = "Projects.db";
  static const dbVer = 2;
  static const table = 'finance';
  static const id = 'id';
  static const expenses = 'expenses';
  static const income = 'income';
  static const name = 'name';
  static const debt = 'debt';
  late Database db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, database);

    db = await openDatabase(
      path,
      version: dbVer,
      onCreate: initDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $table ADD COLUMN $debt DECIMAL(10,2) DEFAULT 0');
        }
      },
    );
  }

  Future<void> initDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
    $id INTEGER PRIMARY KEY AUTOINCREMENT,
    $name TEXT NOT NULL,
    $income DECIMAL(10,2) NOT NULL,
    $expenses DECIMAL(10,2) NOT NULL,
    $debt DECIMAL(10,2) DEFAULT 0
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
      whereArgs: [row[id]],
    );
  }

  Future<int> del(int id) async {
    return await db.delete(
      table,
      where: '$id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getColumnNames() async {
    final List<Map<String, dynamic>> columnsInfo = await db.rawQuery('PRAGMA table_info($table)');

    List<String> columnNames = columnsInfo.map((column) => column['name'] as String).toList();
    return columnNames;
  }

  //Fail-Safe: No name, wrong name querying will just query everything

  Future<double> getIncomeByName([String name = ""]) async {
  List<Map<String, dynamic>> result;

  if (name.isEmpty) {
    result = await db.rawQuery(
      'SELECT SUM($income) as total_income FROM $table',
    );
  } else {
    result = await db.rawQuery(
      'SELECT SUM($income) as total_income FROM $table WHERE name = ?',
      [name],
    );
    if (result.isEmpty || result.first['total_income'] == null) {
      result = await db.rawQuery(
        'SELECT SUM($income) as total_income FROM $table',
      );
    }
  }

  return (result.first['total_income'] as double?) ?? 0.0;
}

Future<double> getExpensesByName([String name = ""]) async {
  List<Map<String, dynamic>> result;
  if (name.isEmpty) {
    result = await db.rawQuery(
      'SELECT SUM($expenses) as total_expenses FROM $table',
    );
  } else {
    result = await db.rawQuery(
      'SELECT SUM($expenses) as total_expenses FROM $table WHERE name = ?',
      [name],
    );
    if (result.isEmpty || result.first['total_expenses'] == null) {
      result = await db.rawQuery(
        'SELECT SUM($expenses) as total_expenses FROM $table',
      );
    }
  }

  return (result.first['total_expenses'] as double?) ?? 0.0;
}
}
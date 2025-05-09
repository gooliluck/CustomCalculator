import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calculator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE calculations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertCalculation(String expression, String result) async {
    final db = await database;
    return await db.insert('calculations', {
      'expression': expression,
      'result': result,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getCalculations() async {
    final db = await database;
    return await db.query('calculations', orderBy: 'timestamp DESC');
  }

  Future<void> deleteCalculation(int id) async {
    final db = await database;
    await db.delete('calculations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllCalculations() async {
    final db = await database;
    await db.delete('calculations');
  }
} 
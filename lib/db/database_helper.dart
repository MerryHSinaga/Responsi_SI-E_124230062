
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    await initDb();
    return _db!;
  }

  Future<void> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'favorites.db');

    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        name TEXT,
        city TEXT,
        address TEXT,
        rating REAL,
        pictureId TEXT,
        description TEXT,
        categories TEXT
      )
    ''');
  }

  Future<void> insertFavorite(Restaurant r) async {
    final database = await db;
    await database.insert('favorites', r.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(String id) async {
    final database = await db;
    await database.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Restaurant>> getFavorites() async {
    final database = await db;
    final maps = await database.query('favorites');
    return maps.map((m) => Restaurant.fromMap(m)).toList();
  }

  Future<bool> isFavorite(String id) async {
    final database = await db;
    final maps = await database.query('favorites', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty;
  }
}

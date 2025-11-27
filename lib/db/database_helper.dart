import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/restaurant.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = join(await getDatabasesPath(), 'favorites.db');

  
    final exists = await databaseExists(dbPath);
    if (exists) {
      final corrupted = await _isCorruptedDatabase(dbPath);
      if (corrupted) {
        print("Database lama rusak, dihapus otomatis!");
        await deleteDatabase(dbPath);
      }
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites(
            id TEXT,
            username TEXT,
            name TEXT,
            city TEXT,
            address TEXT,
            rating REAL,
            pictureId TEXT,
            description TEXT,
            categories TEXT,
            PRIMARY KEY(id, username)
          )
        ''');
      },
    );
  }


  Future<bool> _isCorruptedDatabase(String path) async {
    try {
      final testDB = await openDatabase(path);
      final result = await testDB.rawQuery('SELECT username FROM favorites');
      final invalidFound = result.any((r) =>
          r['username'] == null || r['username'] == "" || r['username'] == "unknown");
      await testDB.close();
      return invalidFound;
    } catch (e) {
      return true; 
    }
  }


  Future<void> insertFavorite(Restaurant r, String username) async {
    final database = await db;
    final data = r.toMap();
    data['username'] = username;
    await database.insert(
      'favorites',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  
  Future<void> removeFavorite(String id, String username) async {
    final database = await db;
    await database.delete(
      'favorites',
      where: 'id = ? AND username = ?',
      whereArgs: [id, username],
    );
  }

 
  Future<List<Restaurant>> getFavorites(String username) async {
    final database = await db;
    final maps = await database.query(
      'favorites',
      where: 'username = ?',
      whereArgs: [username],
    );
    return maps.map((m) => Restaurant.fromMap(m)).toList();
  }
}

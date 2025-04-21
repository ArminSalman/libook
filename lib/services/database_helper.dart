import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    await deleteDatabase(path);
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 2, // Increment the version to trigger onUpgrade
        onCreate: _createDB,
        onUpgrade: _onUpgrade, // Define an upgrade function
      );
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // If the version is 2, add the favoriteBooks table
    if (oldVersion < 2) {
      await db.execute(''' 
      CREATE TABLE IF NOT EXISTS favoriteBooks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_name TEXT NOT NULL,
        UNIQUE(user_id, book_name)
      )
    ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    // Create favoriteBooks table (with book_name instead of book_id)
    await db.execute('''
      CREATE TABLE favoriteBooks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_ID TEXT NOT NULL,
        UNIQUE(user_id, book_ID)
      )
    ''');
  }

  // ---------- USER OPERATIONS ----------

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------- FAVORITE BOOK OPERATIONS ----------

  Future<int> addFavoriteBook(int userId, String bookID) async {
    final db = await database;
    return await db.insert(
      'favoriteBooks',
      {
        'user_id': userId,
        'book_ID': bookID,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> removeFavoriteBook(int userId, String bookID) async {
    final db = await database;
    return await db.delete(
      'favoriteBooks',
      where: 'user_id = ? AND book_ID = ?',
      whereArgs: [userId, bookID],
    );
  }

  Future<bool> isBookFavorited(int userId, String bookID) async {
    final db = await database;
    final result = await db.query(
      'favoriteBooks',
      where: 'user_id = ? AND book_ID = ?',
      whereArgs: [userId, bookID],
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final db = await database;
    return await db.query(
      'favoriteBooks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

}
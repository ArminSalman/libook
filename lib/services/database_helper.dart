import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'comment_control.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  /// Call this if you want to wipe and rebuild the DB (e.g. during development).
  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');
    await deleteDatabase(path);
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,                // bump to 3
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// Migrations:
  /// - v1 → v2: add favoriteBooks table
  /// - v2 → v3: add comments table
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v2 migration: favorites
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favoriteBooks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_ID TEXT NOT NULL,
          UNIQUE(user_id, book_ID)
        )
      ''');
    }
    if (oldVersion < 3) {
      // v3 migration: comments
      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bookId TEXT,
          userId TEXT,
          username TEXT,
          content TEXT,
          timestamp TEXT
        )
      ''');
    }

    if(oldVersion < 4) {
      // v3 migration: comments
      await db.execute('''
      CREATE TABLE avatar (
        userId INTEGER PRIMARY KEY,
        avatarLink TEXT
      )
    ''');
    }

    if (oldVersion < 5) {
      // v5 migration: notifications
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bookId TEXT NOT NULL UNIQUE,
          content TEXT NOT NULL,
          date TEXT NOT NULL,
          time TEXT NOT NULL
        )
      ''');
    }
  }

  /// Fresh install: build all tables
  Future<void> _createDB(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE favoriteBooks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_ID TEXT NOT NULL,
        UNIQUE(user_id, book_ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId TEXT,
        userId TEXT,
        username TEXT,
        content TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE avatar (
        userId INTEGER PRIMARY KEY,
        avatarLink TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId TEXT NOT NULL UNIQUE,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');
  }

  // ---------- USER OPERATIONS ----------

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return db.query('users');
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result =
    await db.query('users', where: 'id = ?', whereArgs: [id]);
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
    return db.update('users', user,
        where: 'id = ?', whereArgs: [user['id']]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- FAVORITE BOOK OPERATIONS ----------

  Future<int> addFavoriteBook(int userId, String bookID) async {
    final db = await database;
    return db.insert(
      'favoriteBooks',
      {'user_id': userId, 'book_ID': bookID},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> removeFavoriteBook(int userId, String bookID) async {
    final db = await database;
    return db.delete(
      'favoriteBooks',
      where: 'user_id = ? AND book_ID = ?',
      whereArgs: [userId, bookID],
    );
  }

  Future<bool> isBookFavorited(int userId, String bookID) async {
    final db = await database;
    final res = await db.query(
      'favoriteBooks',
      where: 'user_id = ? AND book_ID = ?',
      whereArgs: [userId, bookID],
    );
    return res.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final db = await database;
    return db.query('favoriteBooks',
        where: 'user_id = ?', whereArgs: [userId]);
  }

  // ---------- COMMENT OPERATIONS ----------

  Future<int> addComment(CommentControl comment) async {
    final db = await database;
    return db.insert('comments', comment.toMap());
  }

  Future<List<Map<String, dynamic>>> getComments(
      String bookId, String userId) async {
    final db = await database;
    return db.query(
      'comments',
      where: 'bookId = ? AND userId = ?',
      whereArgs: [bookId, userId],
      orderBy: 'timestamp DESC',
    );
  }

  // Bring comments belong to user
  Future<List<Map<String, dynamic>>> getCommentsByUserId(String userId) async {
    final db = await database;
    return db.query(
      'comments',
      where: 'userId = ?',
      whereArgs: [userId.toString()],  // userId'nin string olduğu varsayımı
      orderBy: 'timestamp DESC',
    );
  }

  // Belirli bir yorumu günceller (commentId ile)
  Future<int> updateComment(int commentId, String newContent) async {
    final db = await database;
    return await db.update(
      'comments',
      {'content': newContent},
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  // Delete specific comment (commentId ile)
  Future<int> deleteComment(int commentId) async {
    final db = await database;
    return await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }

  // ---------- Notification OPERATIONS ----------

  /// Inserts a new notification record.
  /// `conflictAlgorithm: ignore` ensures a given bookId is only saved once.
  Future<int> addNotification(String bookId, String content) async {
    final db = await database;
    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    return db.insert(
      'notifications',
      {
        'bookId': bookId,
        'content': content,
        'date': date,
        'time': time,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Returns true if this `bookId` has already been saved.
  Future<bool> isBookAlreadyNotified(String bookId) async {
    final db = await database;
    final res = await db.query(
      'notifications',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
    return res.isNotEmpty;
  }

  /// Fetches all notifications, newest first.
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;
    return db.query('notifications', orderBy: 'date DESC, time DESC');
  }

}

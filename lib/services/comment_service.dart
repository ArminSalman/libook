
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Comment {
  final int? id;
  final String bookId;
  final String userId;
  final String username;
  final String content;
  final String timestamp;

  Comment({
    this.id,
    required this.bookId,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'username': username,
      'content': content,
      'timestamp': timestamp,
    };
  }

  static Comment fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      bookId: map['bookId'],
      userId: map['userId'],
      content: map['content'],
      username: map['username'],
      timestamp: map['timestamp'],
    );
  }
}

class CommentService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'comments.db');

    return await openDatabase(
      path,
      version: 2,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        await db.execute('DROP TABLE IF EXISTS comments');
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
      },
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE comments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bookId TEXT,
            userId TEXT,
            content TEXT,
            username TEXT,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  static Future<void> addComment(Comment comment) async {
    final db = await database;
    await db.insert('comments', comment.toMap());
  }

  static Future<List<Comment>> getComments(String bookId, String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'bookId = ? AND userId = ?',
      whereArgs: [bookId, userId],
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => Comment.fromMap(map)).toList();
  }
}

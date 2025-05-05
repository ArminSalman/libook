import 'database_helper.dart';

class CommentControl {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final int? id;
  final String bookId;
  final String userId;
  final String username;
  final String content;
  final String timestamp;

  CommentControl({
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

  static CommentControl fromMap(Map<String, dynamic> map) {
    return CommentControl(
      id: map['id'],
      bookId: map['bookId'],
      userId: map['userId'],
      username: map['username'],
      content: map['content'],
      timestamp: map['timestamp'],
    );
  }

  /// Persist this comment to the database.
  Future<void> addComment() async {
    await _dbHelper.addComment(this);
  }

  Future<List<Map<String, dynamic>>> getComments(String bookId, String userId) async {
    return await _dbHelper.getComments(bookId, userId);
  }
  Future<List<Map<String, dynamic>>> getUserCommentsByUserId(String userId) async {
    return await _dbHelper.getCommentsByUser(userId);
  }

  Future<List<Map<String, dynamic>>> getAllComments() async {
    return await _dbHelper.getAllComments();
  }

  Future<void> deleteCommentById(int id) async {
    await _dbHelper.deleteCommentById(id);
  }

}

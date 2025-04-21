import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteBooksControl {
  final _dbHelper = DatabaseHelper.instance;

  Future<int> addToFavorites(int userId, int bookID) async {
    final db = await _dbHelper.database;
    try {
      return await db.insert(
        'favoriteBooks',
        {
          'user_id': userId,
          'book_ID': bookID,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print('Error adding book to favorites: $e');
      return -1;
    }
  }

  Future<bool> removeFromFavorites(int userId, int bookID) async {
    try {
      final result = await _dbHelper.removeFavoriteBook(userId, bookID);
      return result > 0;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<bool> isFavorite(int userId, int bookID) async {
    try {
      return await _dbHelper.isBookFavorited(userId, bookID);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<List<String>> getFavoriteBooks(int userId) async {
    final favorites = await _dbHelper.getUserFavorites(userId);
    return favorites.map((favorite) => favorite['book_ID'] as String).toList();
  }
}

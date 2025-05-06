import 'package:flutter/foundation.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class FavoriteBooksControl extends ChangeNotifier {
  final _dbHelper = DatabaseHelper.instance;

  List<String> _favoriteBooks = [];

  List<String> get favoriteBooks => _favoriteBooks;

  Future<void> loadFavorites(int userId) async {
    try {
      final favorites = await _dbHelper.getUserFavorites(userId);
      _favoriteBooks = favorites.map((favorite) => favorite['book_ID'] as String).toList();
      notifyListeners(); // Favoriler yüklendiğinde haber ver
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<List<String>> getFavoriteBooks(int userId) async {
    final favorites = await _dbHelper.getUserFavorites(userId);
    return favorites.map((favorite) => favorite['book_ID'] as String).toList();
  }


  Future<void> addToFavorites(int userId, String bookID) async {
    final db = await _dbHelper.database;
    try {
      // Veritabanına ekleme işlemi
      await db.insert(
        'favoriteBooks',
        {
          'user_id': userId,
          'book_ID': bookID,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      _favoriteBooks.add(bookID); // Favorilere ekle
      notifyListeners(); // Dinleyicilere haber ver
    } catch (e) {
      print('Error adding book to favorites: $e');
    }
  }


  Future<void> removeFromFavorites(int userId, String bookID) async {
    try {
      final result = await _dbHelper.removeFavoriteBook(userId, bookID);
      if (result > 0) {
        _favoriteBooks.remove(bookID);
        notifyListeners(); // Dinleyicilere haber ver
      }
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  bool isFavorite(int userId, String bookID) {
    return _favoriteBooks.contains(bookID);
  }


}

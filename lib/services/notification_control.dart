import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:libook/services/database_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';

class NotificationControl {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Add a new notification record to the database
  Future<void> addNotification(String bookId, String content) async {
    final now = DateTime.now();
    final date = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    await _dbHelper.database.then((db) => db.insert(
      'notifications',
      {
        'bookId': bookId,
        'content': content,
        'date': date,
        'time': time,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    ));
  }

  // Check if a book has already been suggested
  Future<bool> isBookAlreadyNotified(String bookId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'notifications',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
    return result.isNotEmpty;
  }

  // Fetch all past notifications
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await _dbHelper.database;
    return await db.query('notifications', orderBy: 'date DESC, time DESC');
  }

  // Suggest a daily book and send a notification if it hasn't been suggested before
  Future<void> suggestDailyBook() async {
    final book = await _fetchRandomBook();
    if (book == null) return;

    final bookId = book['id'];
    final title = book['volumeInfo']['title'] ?? 'Unknown Book';
    final authors = (book['volumeInfo']['authors'] ?? []).join(", ");
    final content = "Today's book suggestion: $title - $authors";

    final alreadySuggested = await isBookAlreadyNotified(bookId);
    if (alreadySuggested) {
      await suggestDailyBook(); // try another book
      return;
    }

    await _showNotification("Book of the Day", content);
    await addNotification(bookId, content);
  }

  // Fetch a random book from Google Books API
  Future<Map<String, dynamic>?> _fetchRandomBook() async {
    final random = Random();
    final startIndex = random.nextInt(40); // pick a random index
    final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=subject:fiction&startIndex=$startIndex&maxResults=1');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        return data['items'][0];
      }
    }
    return null;
  }

  // Show a local notification
  Future<void> _showNotification(String title, String body) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initSettings);

    const androidDetails = AndroidNotificationDetails(
      'daily_book_channel',
      'Daily Book Suggestion',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}

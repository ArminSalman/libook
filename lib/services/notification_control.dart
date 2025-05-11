import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:libook/services/database_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationControl {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Fetches a random book, shows a notification, and records it in the DB
  Future<void> suggestDailyBook() async {
    final book = await _fetchRandomBook();
    if (book == null) return;

    final bookId = book['id'] as String;
    final title = book['volumeInfo']['title'] as String? ?? 'Unknown Book';
    final authors = (book['volumeInfo']['authors'] as List<dynamic>?)
        ?.join(', ') ??
        'Unknown Author';
    final content = "Today's book suggestion: $title – $authors";

    // If already suggested, try another
    if (await _dbHelper.isBookAlreadyNotified(bookId)) {
      return suggestDailyBook();
    }

    // 1) Show local notification
    await _showNotification('Book of the Day', content);

    // 2) Persist to notifications table
    await _dbHelper.addNotification(bookId, content);
  }

  /// Retrieves all past notifications (newest first)
  Future<List<Map<String, dynamic>>> getNotificationHistory() {
    return _dbHelper.getAllNotifications();
  }

  // ─── Internal helpers ─────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchRandomBook() async {
    final random = Random();
    final start = random.nextInt(40);
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes'
          '?q=subject:fiction&startIndex=$start&maxResults=1',
    );
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>?;
      if (items != null && items.isNotEmpty) {
        return items.first as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<void> _showNotification(String title, String body) async {
    final plugin = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
      const InitializationSettings(android: androidInit),
    );

    const androidDetails = AndroidNotificationDetails(
      'daily_book_channel',               // channel id
      'Daily Book Suggestion',            // channel name
      channelDescription: 'Daily suggestions of a random book',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await plugin.show(0, title, body, details);
  }
}

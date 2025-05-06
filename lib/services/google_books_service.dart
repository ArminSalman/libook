import 'dart:convert';
import 'package:http/http.dart' as http;

/// Basit Google Books istemcisi – *sadece* sorgu string’i alır.
class GoogleBooksService {
  // (Varsa kendi anahtarınızı ekleyin veya tamamen kaldırın.)
  final String apiKey = 'AIzaSyBJMvahNX8YQwjFfr_3sYf5fgXpQU6TejA';

  /// `query` ⇒ Google Books raw JSON listesi (item’lar Map<String,dynamic>)
  Future<List<dynamic>> searchBooks(String query) async {
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey',
    );

    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['items'] ?? [];
    } else {
      throw Exception('Google Books request failed: ${res.statusCode}');
    }
  }

  /// Tek kitap detayını getir (gerekiyorsa)
  Future<Map<String, dynamic>?> getBookById(String id) async {
    final url =
    Uri.parse('https://www.googleapis.com/books/v1/volumes/$id?key=$apiKey');
    final res = await http.get(url);
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }
}

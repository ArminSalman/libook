import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  final String apiKey = 'AIzaSyBJMvahNX8YQwjFfr_3sYf5fgXpQU6TejA';

  Future<List<dynamic>> searchBooks(String query) async {
    final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?q=$query&key=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] ?? [];
    } else {
      throw Exception('There was an error retrieving book data');
    }
  }

  Future<Map<String, dynamic>?> getBookById(String bookId) async {
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes/$bookId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch book by ID: ${response.statusCode}');
      return null;
    }
  }

}

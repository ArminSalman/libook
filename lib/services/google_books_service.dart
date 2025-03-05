import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  final String apiKey = 'AIzaSyC_8WXvcncMJYcysOQ5Lg7qqZdNwdavNMc';

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
}

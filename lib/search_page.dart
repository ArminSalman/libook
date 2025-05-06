import 'package:flutter/material.dart';
import 'services/google_books_service.dart';
import 'book_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _titleCtrl  = TextEditingController();
  final _authorCtrl = TextEditingController();
  String? _selectedGenre;

  final GoogleBooksService _svc = GoogleBooksService();
  List<dynamic> _results = [];
  bool _loading = false;

  Future<void> _runSearch() async {
    final parts = <String>[
      if (_titleCtrl.text.trim().isNotEmpty)
        'intitle:${_titleCtrl.text.trim()}',
      if (_authorCtrl.text.trim().isNotEmpty)
        'inauthor:${_authorCtrl.text.trim()}',
      if (_selectedGenre?.isNotEmpty ?? false) 'subject:$_selectedGenre',
    ];
    if (parts.isEmpty) return;

    setState(() => _loading = true);
    try {
      _results = await _svc.searchBooks(parts.join('+'));
    } catch (e) {
      _results = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Search Books')),
    body: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Book title',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) => _runSearch(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _authorCtrl,
            decoration: const InputDecoration(
              labelText: 'Author (optional)',
              prefixIcon: Icon(Icons.person),
            ),
            onSubmitted: (_) => _runSearch(),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedGenre,
            hint: const Text('Genre (optional)'),
            items: const [
              'Fiction',
              'Fantasy',
              'History',
              'Science',
              'Romance',
              'Comics',
              'Biography',
            ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) => setState(() => _selectedGenre = v),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _runSearch,
            icon: const Icon(Icons.search),
            label: const Text('Search'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(child: Text('No results'))
                : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (_, i) {
                final info = _results[i]['volumeInfo'] ?? {};
                final thumb =
                    (info['imageLinks']?['thumbnail']) ?? '';
                return ListTile(
                  leading: thumb.isNotEmpty
                      ? Image.network(thumb,
                      width: 50, fit: BoxFit.cover)
                      : const Icon(Icons.book, size: 50),
                  title: Text(info['title'] ?? 'Untitled',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    (info['authors'] ?? ['Unknown']).join(', '),
                    maxLines: 1,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookDetailPage(book: _results[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

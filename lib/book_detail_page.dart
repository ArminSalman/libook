import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'services/comment_control.dart';
import 'services/database_helper.dart';
import 'services/favorite_books_control.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final String currentUserId = "demo_user"; // Örnek kullanıcı ID'si
  final FavoriteBooksControl _favoritesControl = FavoriteBooksControl();

  List<CommentControl> comments = [];
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final bookKey = (widget.book['id'] ?? widget.book['title'] ?? '').toString();
    final maps = await DatabaseHelper.instance.getComments(bookKey, currentUserId);
    setState(() {
      comments = maps.map((m) => CommentControl.fromMap(m)).toList();
    });
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final comment = CommentControl(
      bookId: (widget.book['id'] ?? widget.book['title'] ?? '').toString(),
      userId: currentUserId,
      username: user?.email ?? 'Anonymous',
      content: content,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    await comment.addComment();
    _commentController.clear();
    _loadComments();
  }

  Future<void> _checkIfFavorite() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final int userId = int.tryParse(user?.id?.toString() ?? '') ?? -1;
    final bookId = (widget.book['id'] ?? '').toString();

    final favoriteBooks = await _favoritesControl.getFavoriteBooks(userId);

    setState(() {
      isFavorite = favoriteBooks.contains(bookId);
    });
  }

  Future<void> _toggleFavorite() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final int userId = int.tryParse(user?.id?.toString() ?? '') ?? -1;
    final bookId = (widget.book['id'] ?? '').toString();

    if (isFavorite) {
      await _favoritesControl.removeFromFavorites(userId, bookId);
    } else {
      await _favoritesControl.addToFavorites(userId, bookId);
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final String title = book['title'] ?? 'Başlıksız';
    final String authors = book['authors'] ?? 'Yazar bilgisi yok';
    final String description = book['description'] ?? 'Açıklama bulunamadı.';
    final String? thumbnail = book['thumbnail'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (thumbnail != null)
                Center(
                  child: Image.network(
                    thumbnail,
                    height: 200,
                  ),
                ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(authors),
              const SizedBox(height: 8),
              Text(description),
              const Divider(height: 32),
              const Text(
                'Yorumlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...comments.map(
                    (c) => ListTile(
                  leading: const Icon(Icons.comment),
                  title: Text(c.content),
                  subtitle: Text('${c.username} • ${c.timestamp}'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Yorum ekle',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

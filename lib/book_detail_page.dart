import 'main.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'services/comment_service.dart';
import 'package:intl/intl.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  final String currentUserId = "demo_user"; // Giriş yapan kullanıcıya göre güncellenebilir

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final loadedComments = await CommentService.getComments(
      widget.book['id'] ?? widget.book['title'],
      currentUserId,
    );
    setState(() {
      comments = loadedComments;
    });
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
    final comment = Comment(
        bookId: widget.book['id'] ?? widget.book['title'],
        userId: currentUserId,
      username: user?.email ?? "Anonymous",
      content: content,
        timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
      await CommentService.addComment(comment);
      _commentController.clear();
      _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title'] ?? 'Kitap Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (book['thumbnail'] != null)
                Center(
                  child: Image.network(
                    book['thumbnail'],
                    height: 200,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                book['title'] ?? 'Başlıksız',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(book['authors'] ?? 'Yazar bilgisi yok'),
              const SizedBox(height: 8),
              Text(book['description'] ?? 'Açıklama bulunamadı.'),
              const Divider(height: 32),
              const Text(
                'Yorumlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...comments.map((comment) => ListTile(
                    leading: const Icon(Icons.comment),
                    title: Text(comment.content),
                    subtitle: Text("${comment.username} • ${comment.timestamp}"),
                  )),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

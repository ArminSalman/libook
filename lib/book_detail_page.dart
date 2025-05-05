import 'main.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'services/comment_control.dart';
import 'services/database_helper.dart';
import 'package:intl/intl.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<CommentControl> comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final bookKey = (widget.book['id'] ?? widget.book['title']).toString();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final userId = user?.id?.toString() ?? 'unknown';

    final maps = await DatabaseHelper.instance.getComments(
      bookKey,
      userId,
    );
    setState(() {
      comments = maps.map((m) => CommentControl.fromMap(m)).toList();
    });
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = Provider.of<UserProvider>(context, listen: false).user;
    final comment = CommentControl(
      bookId: (widget.book['id'] ?? widget.book['title']).toString(),
      userId: user?.id?.toString() ?? 'unknown',
      username: user?.email ?? 'Anonymous',
      content: content,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );
    await comment.addComment();
    _commentController.clear();
    _loadComments();
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
                  labelText: 'Add comment',
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

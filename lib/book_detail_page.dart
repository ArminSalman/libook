import 'main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'services/comment_control.dart';
import 'services/database_helper.dart';
import 'models/app_user.dart';                       // AppUser -> id & email

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final _commentController = TextEditingController();
  List<CommentControl> _comments = [];

  /* ─── JSON → sade Book map ─── */
  Map<String, dynamic> _flatten(Map<String, dynamic> raw) {
    if (raw.containsKey('volumeInfo')) {
      final info = raw['volumeInfo'] ?? {};
      return {
        'id'         : raw['id'] ?? '',
        'title'      : info['title'] ?? 'Untitled',
        'thumbnail'  : (info['imageLinks']?['thumbnail']) ?? '',
        'authors'    : (info['authors'] ?? ['Unknown']).join(', '),
        'description': info['description'] ?? 'No description available.',
      };
    }
    return raw;
  }

  /* ─── Yorumlar ─── */
  Future<void> _loadComments() async {
    final AppUser? user =
        Provider.of<UserProvider>(context, listen: false).user;
    final String userId = user?.id.toString() ?? '';
    final bookKey = _flatten(widget.book)['id'].toString();

    final rows = await DatabaseHelper.instance.getComments(bookKey, userId);
    setState(() =>
    _comments = rows.map((m) => CommentControl.fromMap(m)).toList());
  }

  Future<void> _addComment() async {
    final txt = _commentController.text.trim();
    if (txt.isEmpty) return;

    final AppUser? user =
        Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;                        // kullanıcı oturumu yoksa

    final book = _flatten(widget.book);

    final comment = CommentControl(
      bookId   : book['id'].toString(),
      userId   : user.id.toString(),                 // ✔ veritabanına userId
      username : user.email,                         // listede e‑posta göster
      content  : txt,
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );
    await comment.addComment();
    _commentController.clear();
    _loadComments();
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  /* ─── UI ─── */
  @override
  Widget build(BuildContext context) {
    final book = _flatten(widget.book);

    return Scaffold(
      appBar: AppBar(title: Text(book['title'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book['thumbnail'].toString().isNotEmpty)
              Center(child: Image.network(book['thumbnail'], height: 220)),
            const SizedBox(height: 16),
            Text(book['title'],
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (book['authors'].toString().isNotEmpty) Text(book['authors']),
            const SizedBox(height: 12),
            Text(book['description']),
            const Divider(height: 32),
            const Text('Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._comments.map(
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
                hintText: 'Add a comment',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

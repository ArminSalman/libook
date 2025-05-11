import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'welcome_page.dart';
import 'services/user_control.dart';
import 'services/favorite_books_control.dart';
import 'services/google_books_service.dart';
import 'services/comment_control.dart';
import 'services/database_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  bool _showingComments = false;

  late FavoriteBooksControl _favoritesControl;
  UserControl userControl = UserControl();
  final GoogleBooksService _booksService = GoogleBooksService();
  final CommentControl _commentControl = CommentControl(
    bookId: '',
    userId: '',
    username: '',
    content: '',
    timestamp: '',
  );

  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> _favoriteBooks = [];
  List<Map<String, dynamic>> _userComments = [];

  @override
  void initState() {
    super.initState();
    _favoritesControl = Provider.of<FavoriteBooksControl>(context, listen: false);
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final info = await userControl.getUserByEmail(user.email);
    if (info == null) {
      setState(() => isLoading = false);
      return;
    }

    final db = await DatabaseHelper.instance.database;
    final res = await db.query(
      'avatar',
      where: 'userId = ?',
      whereArgs: [info['id']],
    );
    String avatarUrl = res.isNotEmpty ? res.first['avatarLink'] as String? ?? "" : "";

    setState(() {
      userData = {...info, 'avatar_url': avatarUrl};
    });

    await fetchFavoriteBooks(info['id']);
    setState(() => isLoading = false);
  }

  void _showEditDialog() {
    TextEditingController usernameController = TextEditingController(text: userData?['username']);
    TextEditingController firstNameController = TextEditingController(text: userData?['first_name']);
    TextEditingController lastNameController = TextEditingController(text: userData?['last_name']);
    TextEditingController emailController = TextEditingController(text: userData?['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = {
                'id': userData!['id'],
                'username': usernameController.text,
                'first_name': firstNameController.text,
                'last_name': lastNameController.text,
                'email': emailController.text,
                'password': userData!['password']
              };
              await userControl.updateUser(userData!['id'], updatedUser);
              await getUserInfo();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelectionPopup() {
    final styles = ['adventurer', 'avataaars', 'bottts', 'pixel-art', 'fun-emoji'];
    final seeds = ['Riley', 'Wyatt', 'Eden', 'Chase', 'Jade', 'Luis'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Avatar"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: styles.map((style) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(style.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: seeds.map((seed) {
                      final avatarUrl = "https://api.dicebear.com/9.x/$style/svg?seed=$seed";
                      return GestureDetector(
                        onTap: () async {
                          final db = await DatabaseHelper.instance.database;
                          final userId = userData!['id'];

                          final existing = await db.query(
                            'avatar',
                            where: 'userId = ?',
                            whereArgs: [userId],
                          );

                          if (existing.isNotEmpty) {
                            await db.update(
                              'avatar',
                              {'avatarLink': avatarUrl},
                              where: 'userId = ?',
                              whereArgs: [userId],
                            );
                          } else {
                            await db.insert('avatar', {
                              'userId': userId,
                              'avatarLink': avatarUrl,
                            });
                          }

                          setState(() {
                            userData?['avatar_url'] = avatarUrl;
                          });

                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: SvgPicture.network(avatarUrl),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, bool isSelected, VoidCallback onTap) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black38,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        if (isSelected)
          Container(width: 80, height: 1.5, color: Colors.black54, margin: const EdgeInsets.only(top: 4)),
      ],
    );
  }

  Future<void> fetchFavoriteBooks(int userId) async {
    try {
      await _favoritesControl.loadFavorites(userId);
      final bookIds = _favoritesControl.favoriteBooks;
      List<Map<String, dynamic>> books = [];
      for (String id in bookIds) {
        final book = await _booksService.getBookById(id);
        if (book != null) {
          books.add(book);
        }
      }
      setState(() {
        _favoriteBooks = books;
        _showingComments = false;
      });
    } catch (e) {
      print("Error fetching favorite books: $e");
    }
  }

  Future<void> fetchUserComments(int userId) async {
    try {
      String sUserId = userId.toString();
      List<Map<String, dynamic>> comments = await _commentControl.getCommentsByUserId(sUserId);
      setState(() {
        _userComments = comments;
        _showingComments = true;
      });
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      await _commentControl.deleteCommentById(commentId);
      await fetchUserComments(userData!['id']);
    } catch (e) {
      print("Failed to delete comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        backgroundColor: Colors.grey[500],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              Provider.of<UserProvider>(context, listen: false).logout();
              await userControl.logoutUser();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomePage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  child: SvgPicture.network(
                    userData?['avatar_url']?.isNotEmpty == true
                        ? userData!['avatar_url']
                        : "https://api.dicebear.com/9.x/adventurer/svg?seed=Riley",
                    placeholderBuilder: (context) => const CircularProgressIndicator(),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: _showAvatarSelectionPopup,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: _showEditDialog,
              child: const Text("Edit Profile", style: TextStyle(color: Colors.black),),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            userData?['username'] ?? 'No username',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton("Favorites", !_showingComments, () {
                if (userData?['id'] != null) {
                  fetchFavoriteBooks(userData!['id']);
                }
              }),
              const SizedBox(width: 20),
              _buildButton("My Comments", _showingComments, () {
                if (userData?['id'] != null) {
                  fetchUserComments(userData!['id']);
                }
              }),
            ],
          ),
          const SizedBox(height: 20),
          _showingComments
              ? Column(
            children: _userComments.map((comment) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(comment['content']),
                subtitle: Text("${comment['timestamp']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteComment(comment['id']),
                ),
              ),
            )).toList(),
          )
              : _favoriteBooks.isEmpty
              ? const Center(child: Text("No favorite books yet."))
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _favoriteBooks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final book = _favoriteBooks[index]['volumeInfo'];
              final bookID = _favoriteBooks[index]['id'];
              final title = book['title'] ?? 'Unknown';
              final thumbnail = book['imageLinks']?['thumbnail'];

              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 130,
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: thumbnail != null
                              ? Image.network(thumbnail, fit: BoxFit.cover)
                              : const Center(child: Icon(Icons.book, size: 40)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 4,
                    bottom: 36,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                      onPressed: () async {
                        final userId = userData?['id'];
                        if (userId != null) {
                          await _favoritesControl.removeFromFavorites(userId, bookID);
                          await fetchFavoriteBooks(userId);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

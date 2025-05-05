import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'services/user_control.dart';
import 'services/favorite_books_control.dart';
import 'services/google_books_service.dart';
import 'services/comment_control.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  bool _showingComments = false;

  UserControl userControl = UserControl();
  FavoriteBooksControl _favoritesControl = FavoriteBooksControl();
  GoogleBooksService _booksService = GoogleBooksService();
  CommentControl _commentControl = CommentControl(
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
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      final info = await userControl.getUserByEmail(user.email);
      if (info != null) {
        setState(() {
          userData = info;
        });
        await fetchFavoriteBooks(info['id']);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchFavoriteBooks(int userId) async {
    try {
      final bookIds = await _favoritesControl.getFavoriteBooks(userId);
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
      print(userData?['id']);
      String sUserId = userId.toString();
      final comments = await _commentControl.getUserCommentsByUserId(sUserId);
      setState(() {
        _userComments = comments;
        _showingComments = true;
      });
      print(comments);
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(text: userData?['first_name'] ?? "");
    TextEditingController surnameController = TextEditingController(text: userData?['last_name'] ?? "");
    TextEditingController emailController = TextEditingController(text: userData?['email'] ?? "");
    TextEditingController usernameController = TextEditingController(text: userData?['username'] ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Center(
          child: Text("Edit Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Username", usernameController, Icons.person),
              const SizedBox(height: 12),
              _buildTextField("Name", nameController, Icons.account_circle),
              const SizedBox(height: 12),
              _buildTextField("Surname", surnameController, Icons.account_box),
              const SizedBox(height: 12),
              _buildTextField("Email", emailController, Icons.email),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = {
                'id': userData!['id'],
                'username': usernameController.text,
                'first_name': nameController.text,
                'last_name': surnameController.text,
                'email': emailController.text,
                'password': userData?['password'],
              };
              await userControl.updateUser(userData?['id'], updatedUser);
              Navigator.pop(context);
              await getUserInfo();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(icon, color: Colors.grey[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[600],
      ),
    );
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
            icon: const Icon(Icons.settings, color: Colors.black45),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/pp.jpeg"),
                ),
                const SizedBox(height: 8),
                Text(
                  userData?['username'] ?? 'no username',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: _showEditDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Edit profile", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton("Favorites", () {
                      if (userData?['id'] != null) {
                        fetchFavoriteBooks(userData!['id']);
                      }
                    }),
                    _divider(),
                    _buildButton("My Comments", () {
                      if (userData?['email'] != null) {
                        fetchUserComments(userData?['id']);
                      }
                    }),
                  ],
                ),
                Container(
                  width: 80,
                  height: 1.5,
                  color: Colors.black54,
                  margin: const EdgeInsets.only(top: 4, right: 125),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showingComments
                ? ListView.builder(
              itemCount: _userComments.length,
              itemBuilder: (context, index) {
                final comment = _userComments[index];
                return ListTile(
                  title: Text(comment['content']),
                  subtitle: Text("Book ID: ${comment['bookId']} • ${comment['timestamp']}"),
                );
              },
            )
                : _favoriteBooks.isEmpty
                ? const Center(child: Text("No favorite books yet."))
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                itemCount: _favoriteBooks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final book = _favoriteBooks[index]['volumeInfo'];
                  final title = book['title'] ?? 'Unknown';
                  final thumbnail = book['imageLinks']?['thumbnail'];

                  return Column(
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, [VoidCallback? onTap]) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black38,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _divider() {
    return Container(
      height: 30,
      width: 1.5,
      color: Colors.black54,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}

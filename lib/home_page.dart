import 'book_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:libook/library_page.dart';
import 'package:libook/profile_page.dart';
import 'services/google_books_service.dart';
import 'services/user_control.dart';
import 'services/favorite_books_control.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const LibraryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3D3D3),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text("LiBOOK", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[800],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[400],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Library"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleBooksService _booksService = GoogleBooksService();
  final FavoriteBooksControl _favoritesControl = FavoriteBooksControl();

  final List<Map<String, String>> _categories = [
    {'title': 'Trending', 'query': 'bestsellers'},
    {'title': 'Science', 'query': 'science'},
    {'title': 'History', 'query': 'history'},
    {'title': 'Fantasy', 'query': 'fantasy'},
  ];

  final Map<String, List<dynamic>> _booksByCategory = {};
  Set<String> _favoritedBookIds = {};

  int? _userId;
  bool _isLoading = true;

  UserControl userControl = UserControl();

  @override
  void initState() {
    super.initState();
    _fetchAllCategories();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      final info = await userControl.getUserByEmail(user.email);
      if (info != null) {
        _userId = info['id'];
        await _fetchFavorites();
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchAllCategories() async {
    for (var category in _categories) {
      final query = category['query']!;
      try {
        final books = await _booksService.searchBooks(query);
        _booksByCategory[query] = books.take(10).toList();
      } catch (e) {
        debugPrint("Error fetching $query books: $e");
        _booksByCategory[query] = [];
      }
    }
    setState(() {});
  }

  Future<void> _fetchFavorites() async {
    if (_userId == null) return;
    final favorites = await _favoritesControl.getFavoriteBooks(_userId!);
    setState(() {
      _favoritedBookIds = favorites.toSet();
    });
  }

  Future<void> _toggleFavorite(String bookId) async {
    if (_userId == null) return;

    final isFav = await _favoritesControl.isFavorite(_userId!, bookId);
    bool success = false;

    if (isFav) {
      success = await _favoritesControl.removeFromFavorites(_userId!, bookId);
      if (success) {
        setState(() {
          _favoritedBookIds.remove(bookId);
        });
      }
    } else {
      success = await _favoritesControl.addToFavorites(_userId!, bookId) > 0;
      if (success) {
        setState(() {
          _favoritedBookIds.add(bookId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const SizedBox(height: 8),
        const Text(
          "Explore curated categories",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        ..._categories.map((category) {
          final title = category['title']!;
          final query = category['query']!;
          final books = _booksByCategory[query] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index]['volumeInfo'];
                    final image = book['imageLinks']?['thumbnail'];
                    final bookID = books[index]['id'];

                    final isFavorite = _favoritedBookIds.contains(bookID);

                    return GestureDetector(
  onTap: () {
    final book = books[index]['volumeInfo'];
    final image = book['imageLinks']?['thumbnail'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(
          book: {
            'id': books[index]['id'],
            'title': book['title'] ?? 'Başlıksız',
            'authors': (book['authors'] as List?)?.join(', ') ?? 'Yazar bilgisi yok',
            'description': book['description'] ?? 'Açıklama bulunamadı.',
            'thumbnail': image,
          },
        ),
      ),
    );
  },
  child: Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: image != null
                                ? Image.network(image, fit: BoxFit.cover)
                                : const Center(
                              child: Icon(Icons.book, size: 40),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleFavorite(bookID),
                          ),
                        ),
                      ],
                    ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ],
    );
  }
}

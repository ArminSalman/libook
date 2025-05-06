import 'book_detail_page.dart';
import 'package:flutter/material.dart';
import 'search_page.dart';                       // ✅ yeni Search
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

/* -------------------------------------------------------------------------- */
/*                     HOME PAGE –  bottom‑nav, app‑bar, vs.                  */
/* -------------------------------------------------------------------------- */

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),   // özgün ana akışın
    const SearchPage(),   // 🔍 Library yerine Search
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFD3D3D3),
    appBar: AppBar(
      backgroundColor: Colors.grey[800],
      title: const Text('LiBOOK',
          style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => setState(() => _currentIndex = 1),
        ),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {}, // bildirim sayfan varsa ekle
        ),
      ],
    ),
    body: _pages[_currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.grey[800],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.search), label: 'Search'), // ✅
        BottomNavigationBarItem(
            icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}

/* -------------------------------------------------------------------------- */
/*                        HOME SCREEN –  kitabı listele                       */
/* -------------------------------------------------------------------------- */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoogleBooksService _booksService = GoogleBooksService();
  final UserControl _userControl = UserControl();
  late FavoriteBooksControl _favoritesControl;

  int? _userId;                             // giriş yapan kullanıcı
  bool _isLoading = true;

  // kategori → API query
  final List<Map<String, String>> _categories = [
    {'title': 'Trending', 'query': 'bestsellers'},
    {'title': 'Science',  'query': 'science'},
    {'title': 'History',  'query': 'history'},
    {'title': 'Fantasy',  'query': 'fantasy'},
  ];

  final Map<String, List<dynamic>> _booksByCategory = {};
  Set<String> _favoritedBookIds = {};

  @override
  void initState() {
    super.initState();
    _favoritesControl =
        Provider.of<FavoriteBooksControl>(context, listen: false);
    _initPage();
  }

  Future<void> _initPage() async {
    await _fetchCurrentUser();
    await _loadAllCategories();
    await _fetchFavorites();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchCurrentUser() async {
    // Örnek: SharedPreferences’tan user‑id alınıyor olabilir.
    // Buraya mevcut login mantığını ekleyebilirsin.
    _userId = 1; // demo
  }

  /* ----------------------------  KATEGORİ ÇEKME  --------------------------- */

  Future<void> _loadAllCategories() async {
    for (var cat in _categories) {
      final books = await _booksService.searchBooks(cat['query']!);
      _booksByCategory[cat['title']!] = books;
    }
  }

  /* ------------------------------  FAVORİLER  ------------------------------ */

  Future<void> _fetchFavorites() async {
    if (_userId == null) return;
    await _favoritesControl.loadFavorites(_userId!);
    setState(() {
      _favoritedBookIds = _favoritesControl.favoriteBooks.toSet();
    });
  }

  Future<void> _toggleFavorite(String bookId) async {
    if (_userId == null) return;

    final isFav =
    _favoritesControl.isFavorite(_userId!, bookId);

    if (isFav) {
      await _favoritesControl.removeFromFavorites(_userId!, bookId);
    } else {
      await _favoritesControl.addToFavorites(_userId!, bookId);
    }

    await _fetchFavorites();
  }

  /* ------------------------------  UI BUILD  ------------------------------ */

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Explore curated categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ..._categories.map((cat) {
          final books = _booksByCategory[cat['title']] ?? [];
          if (books.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cat['title']!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  itemBuilder: (_, i) {
                    final book = books[i];
                    final info   = book['volumeInfo'] ?? {};
                    final thumb  = (info['imageLinks']?['thumbnail']) ?? '';
                    final bookID = book['id'];

                    final isFavorite =
                    _favoritedBookIds.contains(bookID);

                    return Container(
                      width: 130,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookDetailPage(book: book),
                                ),
                              ),
                              child: thumb.isNotEmpty
                                  ? Image.network(thumb, fit: BoxFit.cover)
                                  : const Icon(Icons.book, size: 64),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            info['title'] ?? 'No title',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                              isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleFavorite(bookID),
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

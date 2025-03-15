import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final List<Map<String, dynamic>> books = [
    {"title": "Sefiller", "image": "assets/sefiller.jpeg", "progress": 0.7},
    {"title": "Don Kişot", "image": "assets/donkisot.jpeg", "progress": 0.5},
    {"title": "Martin Eden", "image": "assets/martineden.jpeg", "progress": 0.3},
    {"title": "Beyaz Diş", "image": "assets/beyazdis.jpeg", "progress": 0.6},
    {"title": "Savaş ve Barış", "image": "assets/savas.jpeg", "progress": 0.8},
    {"title": "Hayvan Çiftliği", "image": "assets/hayvan.jpeg", "progress": 0.4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500], // Arka plan rengi
      appBar: AppBar(
        backgroundColor: Colors.grey[500], // AppBar rengi gri
        elevation: 0,
        title: Text(
          "LiBook",
          style: TextStyle(
            color: Colors.black45,
            fontFamily: "Caveat", // Tanımladığın fontu burada kullanıyorsun
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // Solda hizalanmasını sağlamak için
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black45),
            onPressed: () {},
          ),
        ],
      ),

      body: Column(
        children: [
          // Profil Bilgileri
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/pp.jpeg"),
                ),
                SizedBox(height: 8),
                Text(
                  "Name Surname",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700], // Buton rengi gri
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), // Daha ince ve uzun
                    textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // Yazı rengi beyaz
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Daha az yuvarlak köşeler
                    ),
                  ),
                  child: Text("Edit profile", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Seviye Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Yuvarlak köşeler
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.lightGreen.shade700, // Seviye çubuğu rengi
                    ),
                    minHeight: 6,
                  ),
                ),
                SizedBox(height: 7),
                Text("Level 1"),
              ],
            ),
          ),

          // Butonlar (Hizalı ve Çizgili)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black38, // Buton rengi gri
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Daha az yuvarlak köşeler
                      ),
                      child: Text("Current Reads", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 30,
                      width: 1.5,
                      color: Colors.black54,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black26, // Buton rengi gri
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Daha az yuvarlak köşeler
                      ),
                      child: Text("Completed Reads", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 30,
                      width: 1.5,
                      color: Colors.black54,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black26, // Buton rengi gri
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), // Yazı rengi beyaz
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Daha az yuvarlak köşeler
                      ),
                      child: Text("My Books", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                // "Completed Reads" butonunun altındaki çizgi
                Container(
                  width: 110,
                  height: 1.5,
                  color: Colors.black54,
                  margin: EdgeInsets.only(top: 4, right: 230), // Üstten biraz boşluk bırak
                ),
              ],
            ),
          ),

          // Kitap Listesi (2 Satır Halinde)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildBookRow(books.sublist(0, 3)), // İlk üç kitap (üst sıra)
                SizedBox(height: 10), // Satırlar arası boşluk
                buildBookRow(books.sublist(3, 6)), // Sonraki üç kitap (alt sıra)
              ],
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[600], // Alt navigasyon çubuğu rengi gri
        items: [
          BottomNavigationBarItem(
            icon: Center(
              child: Image.asset('assets/book.png', width: 25, height: 25),
            ),
            label: "", // İkonun altındaki yazıyı kaldırdık
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: Icon(Icons.search, size: 30),
            ),
            label: "", // İkonun altındaki yazıyı kaldırdık
          ),
          BottomNavigationBarItem(
            icon: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3), // Çerçeve rengi ve kalınlığı
                ),
                child: CircleAvatar(
                  radius: 13,
                  backgroundImage: AssetImage("assets/pp.jpeg"), // İçine fotoğraf ekleyin
                ),
              ),
            ),
            label: "", // İkonun altındaki yazıyı kaldırdık
          ),
        ],
      ),
    );
  }

  // Kitap Sırası Oluşturucu
  Widget buildBookRow(List<Map<String, dynamic>> rowBooks) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: rowBooks.map((book) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), // Yuvarlak köşeler
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5), // Gölgenin rengi
                      spreadRadius: 7, // Gölgenin yayılma alanı
                      blurRadius: 5, // Gölgenin bulanıklığı
                      offset: Offset(0, 3), // Gölgenin konumu
                    ),
                  ],
                ),
                child: Image.asset(
                  book["image"]!,
                  width: 100,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Yuvarlak köşeler
                  child: LinearProgressIndicator(
                    value: book["progress"],
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.lightGreen.shade700, // Kitap çubuğu rengi
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                book["title"]!,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
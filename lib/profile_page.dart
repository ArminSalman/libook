import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
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

      body: Column(
        children: [
          // Profile Information
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/pp.jpeg"),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Name Surname",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), // Longer and thinner
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Edit profile", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          // Buttons
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
                        backgroundColor: Colors.black38,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Less circle corners
                      ),
                      child: const Text("Favorites", style: TextStyle(color: Colors.white)),
                    ),
                    Container(
                      height: 30,
                      width: 1.5,
                      color: Colors.black54,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black26, // Button color gray
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Less circle corners
                      ),
                      child: const Text("My Comments", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                // Line under the "Completed Reads" buttons
                Container(
                  width: 80,
                  height: 1.5,
                  color: Colors.black54,
                  margin: const EdgeInsets.only(top: 4, right: 125),
                ),
              ],
            ),
          ),

          // Books List (2 row)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildBookRow(books.sublist(0, 3)), // First three books
                const SizedBox(height: 10),
                buildBookRow(books.sublist(3, 6)), // Next three books
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kitap List maker
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
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 7,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
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
              const SizedBox(height: 4),
              const SizedBox(height: 4),
              Text(
                book["title"]!,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
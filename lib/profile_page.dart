import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'services/user_control.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  UserControl userControl = UserControl();
  Map<String, dynamic>? userData;

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
          isLoading = false;
        });
      }
    }
  }

  void _showEditDialog() {
    TextEditingController nameController = TextEditingController(text: userData?['first_name'] ?? "");
    TextEditingController surnameController = TextEditingController(text: userData?['last_name'] ?? "");
    TextEditingController emailController = TextEditingController(text: userData?['email'] ?? "");
    TextEditingController usernameController = TextEditingController(text: userData?['username'] ?? "");
    TextEditingController passwordController = TextEditingController(text: userData?['password'] ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog box
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username field with an icon
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              // Name field with an icon
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.account_circle, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              // Surname field with an icon
              TextField(
                controller: surnameController,
                decoration: InputDecoration(
                  labelText: "Surname",
                  prefixIcon: Icon(Icons.account_box, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              // Email field with an icon
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 12),
              // Password field with an icon
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel button with a rounded shape and custom color
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          // Save button with a rounded shape and custom color
          ElevatedButton(
            onPressed: () async {
              final updatedUser = {
                'id': userData!['id'],
                'username': usernameController.text,
                'first_name': nameController.text,
                'last_name': surnameController.text,
                'email': emailController.text,
                'password': passwordController.text,
              };
              await userControl.updateUser(userData?['id'], updatedUser);
              Navigator.pop(context);
              await getUserInfo();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> books = [
    {"title": "Sefiller", "image": "assets/sefiller.jpeg", "progress": 0.7},
    {"title": "Don Kışot", "image": "assets/donkisot.jpeg", "progress": 0.5},
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: _showEditDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 5),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Edit profile",
                      style: TextStyle(color: Colors.white)),
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
                    _buildButton("Favorites"),
                    _divider(),
                    _buildButton("My Comments"),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildBookRow(books.sublist(0, 3)),
                const SizedBox(height: 10),
                buildBookRow(books.sublist(3, 6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label) {
    return ElevatedButton(
      onPressed: () {},
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    book["image"]!,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                book["title"]!,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
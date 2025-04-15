import 'database_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserControl {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<int> addUser({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final user = {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': hashPassword(password),
    };
    return await _dbHelper.insertUser(user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _dbHelper.getUsers();
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    return await _dbHelper.getUserById(id);
  }

  Future<int> updateUser(int id, Map<String, dynamic> updatedUser) async {
    updatedUser['id'] = id;
    return await _dbHelper.updateUser(updatedUser);
  }

  Future<int> deleteUser(int id) async {
    return await _dbHelper.deleteUser(id);
  }

  void printUsers() async {
    List<Map<String, dynamic>> users = await DatabaseHelper.instance.getUsers();
    for (var user in users) {
      print("ID: ${user['id']}, Username: ${user['username']}, Email: ${user['email']}, Password: ${user['password']}");
    }
  }

  Future<void> saveUserSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInUser', email);
  }

  Future<String?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedInUser');
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUser');
  }
}

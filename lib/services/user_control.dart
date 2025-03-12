import 'database_helper.dart';

class UserControl {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

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
      'password': password, // Not: Şifreyi hashleyerek saklamanız önerilir.
    };
    return await _dbHelper.insertUser(user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    return await _dbHelper.getUsers();
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
}

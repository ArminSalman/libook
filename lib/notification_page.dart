import 'package:flutter/material.dart';
import 'package:libook/services/notification_control.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationControl _notificationControl = NotificationControl();
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final data = await _notificationControl.getNotificationHistory();
    setState(() {
      _notifications = data;
      _isLoading = false;
    });
  }

  Future<void> _suggestBook() async {
    setState(() => _isLoading = true);
    try {
      await _notificationControl.suggestDailyBook();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New book suggestion added!'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during suggestion: $e'))
      );
    } finally {
      await _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text('there is any notification'))
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, i) {
          final n = _notifications[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(n['content']),
              subtitle: Text("Date: ${n['date']}  •  Time: ${n['time']}"),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _suggestBook,
        tooltip: 'Suggest Book',
        child: const Icon(Icons.book),
      ),
    );
  }
}

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
    setState(() => _isLoading = true);  // yüklemeye başla
    final data = await _notificationControl.getAllNotifications();  // veritabanından oku :contentReference[oaicite:0]{index=0}:contentReference[oaicite:1]{index=1}
    setState(() {
      _notifications = data;
      _isLoading = false;              // yükleme bitti
    });
  }

  Future<void> _suggestBook() async {
    setState(() => _isLoading = true);  // öneri sırasında da spinner göster
    try {
      await _notificationControl.suggestDailyBook();  // öneri ve bildirim ekleme :contentReference[oaicite:2]{index=2}:contentReference[oaicite:3]{index=3}
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni kitap önerisi eklendi!'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Öneri sırasında hata: $e'))
      );
    } finally {
      await _loadNotifications();       // her durumda listeyi yenile
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

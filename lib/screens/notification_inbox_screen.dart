import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  final ApiService apiService = ApiService();
  List<dynamic>? _cachedMessages;
  List<String> _deletedIds = []; // ✅ IDs des messages supprimés localement

  @override
  void initState() {
    super.initState();
    _initData();
  }

  // ✅ Charger les IDs supprimés et les messages au démarrage
  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _deletedIds = prefs.getStringList('deleted_message_ids') ?? [];
    });
  }

  // ✅ Marquer les messages comme "Lus" pour le compteur de la cloche
  Future<void> _markAsRead(List<dynamic> messages) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> readIds = prefs.getStringList('read_message_ids') ?? [];
    bool changed = false;

    for (var msg in messages) {
      String id = msg['id'].toString();
      if (!readIds.contains(id)) {
        readIds.add(id);
        changed = true;
      }
    }
    if (changed) await prefs.setStringList('read_message_ids', readIds);
  }

  // ✅ Supprimer définitivement le message DU TÉLÉPHONE
  Future<void> _deleteMessageLocally(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_deletedIds.contains(id)) {
      _deletedIds.add(id);
      await prefs.setStringList('deleted_message_ids', _deletedIds);
      setState(() {
        // On force la mise à jour de l'affichage
        _cachedMessages?.removeWhere((msg) => msg['id'].toString() == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTurquoise = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Notifications",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 20)),
        backgroundColor: const Color(0xFF0F172A).withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _cachedMessages == null) {
            return const Center(
                child: CircularProgressIndicator(color: primaryTurquoise));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildEmptyState();
          }

          // ✅ FILTRAGE : On retire les messages supprimés par l'utilisateur
          _cachedMessages = snapshot.data!.where((msg) {
            return !_deletedIds.contains(msg['id'].toString());
          }).toList();

          if (_cachedMessages!.isEmpty) {
            return _buildEmptyState();
          }

          // Marquer ce qui reste comme lu
          _markAsRead(_cachedMessages!);

          return ListView.builder(
            itemCount: _cachedMessages!.length,
            padding:
                const EdgeInsets.only(top: kToolbarHeight + 40, bottom: 20),
            itemBuilder: (context, index) {
              final msg = _cachedMessages![index];
              return _buildDismissibleCard(msg, primaryTurquoise, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildDismissibleCard(dynamic msg, Color color, int index) {
    String messageId = msg['id'].toString();

    return Dismissible(
      key: Key(messageId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
            Text("Effacer",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      onDismissed: (direction) {
        _deleteMessageLocally(messageId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Notification supprimée"),
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: _buildNotificationCard(msg, color),
    );
  }

  Widget _buildNotificationCard(dynamic msg, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.01)
                ],
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              msg['titre'].toString().toUpperCase(),
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.2),
                            ),
                            const Icon(Icons.circle,
                                color: Colors.white10, size: 8),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          msg['contenu'] ?? "",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.4,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 20),
          const Text("Aucune notification",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

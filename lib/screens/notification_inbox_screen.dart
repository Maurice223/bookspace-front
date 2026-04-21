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
  final Color primaryTurquoise = const Color(0xFF26A69A);

  List<dynamic> _messages = [];
  List<String> _deletedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ✅ Chargement initial des données locales et API
  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _deletedIds = prefs.getStringList('deleted_message_ids') ?? [];
    await _fetchAndFilterMessages();
  }

  // ✅ Récupération des messages avec gestion d'état
  Future<void> _fetchAndFilterMessages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await apiService.fetchMessages();
      if (mounted) {
        setState(() {
          // Filtrer les messages qui ne sont pas dans la liste des supprimés
          _messages = data
              .where((msg) => !_deletedIds.contains(msg['id'].toString()))
              .toList();
          _isLoading = false;
        });
        if (_messages.isNotEmpty) {
          _markAsRead(_messages);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ Marquer comme lu localement
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

  // ✅ Suppression locale (Persistance)
  Future<void> _deleteMessageLocally(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_deletedIds.contains(id)) {
      _deletedIds.add(id);
      await prefs.setStringList('deleted_message_ids', _deletedIds);
      setState(() {
        _messages.removeWhere((msg) => msg['id'].toString() == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: primaryTurquoise,
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: _fetchAndFilterMessages,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryTurquoise))
            : _messages.isEmpty
                ? _buildEmptyState()
                : _buildListView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("Notifications",
          style: TextStyle(
              fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22)),
      backgroundColor: const Color(0xFF0F172A).withOpacity(0.8),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _messages.length,
      padding: const EdgeInsets.only(top: kToolbarHeight + 40, bottom: 40),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildDismissibleCard(msg, index);
      },
    );
  }

  Widget _buildDismissibleCard(dynamic msg, int index) {
    String messageId = msg['id'].toString();

    return Dismissible(
      key: Key(messageId),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      onDismissed: (direction) {
        _deleteMessageLocally(messageId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Notification effacée"),
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: _buildNotificationCard(msg),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 30),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child:
          const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
    );
  }

  Widget _buildNotificationCard(dynamic msg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icone circulaire décorative
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryTurquoise.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active_rounded,
                      color: primaryTurquoise, size: 20),
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
                            msg['titre']?.toString().toUpperCase() ?? "ANNONCE",
                            style: TextStyle(
                                color: primaryTurquoise,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.1),
                          ),
                          const Text(
                            "Récent",
                            style:
                                TextStyle(color: Colors.white24, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        msg['contenu'] ?? "",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 24),
          const Text("C'est bien calme ici...",
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Vos notifications apparaîtront ici",
              style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }
}

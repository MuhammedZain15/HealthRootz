import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/app_colors.dart';
import 'package:grad_project/core/network/token_storage.dart';
import 'package:grad_project/patient/features/ai_chat/data/ai_chat_datasource.dart';
import 'package:grad_project/patient/features/chat/chat_view.dart';
import 'package:intl/intl.dart';

class AiSessionsScreen extends StatefulWidget {
  const AiSessionsScreen({super.key});

  @override
  State<AiSessionsScreen> createState() => _AiSessionsScreenState();
}

class _AiSessionsScreenState extends State<AiSessionsScreen> {
  late final AiChatDataSource _dataSource;
  late String _patientId;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = AiChatDataSourceImpl();
    _initPatientId();
  }

  void _initPatientId() async {
    final userId = await TokenStorage.getUserId();
    if (userId != null) {
      setState(() {
        _patientId = userId;
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewSession() async {
    if (_patientId.isEmpty) return;
    final sessionId = await _dataSource.createSession(_patientId);
    if (mounted) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatView(isDoctorChat: false, sessionId: sessionId),
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmation(String sessionId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _dataSource.deleteSession(_patientId, sessionId);
      if (mounted) {
        setState(() {});
      }
      return true;
    }
    return false;
  }


  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.purple),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: const Color(0xFF0F172A)),
        ),
        title: const Text(
          'AI Chat History',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: Icon(Icons.search, color: AppColors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.purple, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Sessions List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _dataSource.getSessions(_patientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.purple),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final sessions = snapshot.data!
                    .where((session) {
                      final title =
                          (session['title'] ?? '').toString().toLowerCase();
                      return title.contains(_searchQuery.toLowerCase());
                    })
                    .toList();

                if (sessions.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations found',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _buildSessionCard(session);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewSession,
        backgroundColor: AppColors.purple,
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final sessionId = session['id'] as String;
    final title = session['title'] as String? ?? '';
    final lastMessage = session['lastMessage'] as String? ?? '';
    final lastMessageTime = session['lastMessageTime'];

    return Dismissible(
      key: Key(sessionId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _showDeleteConfirmation(sessionId),
      onDismissed: (_) {
        ScaffoldMessenger.of(context).clearSnackBars();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatView(isDoctorChat: false, sessionId: sessionId),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                color: Colors.grey[50],
              ),
              child: Row(
                children: [
                  // AI Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.smart_toy_outlined,
                      color: AppColors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastMessage.isNotEmpty
                              ? lastMessage
                              : 'No messages yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time
                  Text(
                    _formatTime(lastMessageTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new AI chat to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewSession,
            icon: const Icon(Icons.add),
            label: const Text('Start Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// commit update
 
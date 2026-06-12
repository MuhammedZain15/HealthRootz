import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/chat_model.dart';

class ChatSearchField extends StatelessWidget {
  const ChatSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search patients...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final ChatUser user;
  final VoidCallback onTap;

  const ChatListTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1A65EB),
        radius: 24,
        child: Text(
          user.name.split(' ').map((e) => e[0]).take(2).join(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            user.time,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              user.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: user.unreadCount > 0
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.grey,
                fontWeight: user.unreadCount > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          if (user.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF1A65EB),
                shape: BoxShape.circle,
              ),
              child: Text(
                user.unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onDelete;
  final Function(String patientId)? onForward;
  final Future<List<Map<String, dynamic>>> Function()? onGetPatients;

  const MessageBubble({
    super.key,
    required this.message,
    this.onDelete,
    this.onForward,
    this.onGetPatients,
  });

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFF1A65EB)),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              },
            ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
            ListTile(
              leading: const Icon(Icons.forward, color: Color(0xFF1A65EB)),
              title: const Text('Forward'),
              onTap: () async {
                Navigator.pop(context);
                if (onGetPatients != null && onForward != null) {
                  final patients = await onGetPatients!();
                  if (context.mounted) {
                    _showForwardSheet(context, patients);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showForwardSheet(
    BuildContext context,
    List<Map<String, dynamic>> patients,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: patients.isEmpty
              ? const ListTile(title: Text('No patients found.'))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ListTile(
                      title: Text(
                        'Forward to Patient',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patient = patients[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.person,
                              color: Color(0xFF1A65EB),
                            ),
                            title: Text(patient['name']?.toString() ?? ''),
                            onTap: () {
                              Navigator.pop(context);
                              onForward!(patient['id']?.toString() ?? '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Message forwarded'),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF1A65EB) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
            border:
                isMe ? null : Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              if (!isMe)
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) ...[
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(message.mediaUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: message.mediaType == 'image'
                        ? Image.network(
                            message.mediaUrl!,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                height: 150,
                                width: 150,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 80);
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            color: Colors.grey.shade100,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  message.mediaType == 'video'
                                      ? Icons.video_library
                                      : Icons.picture_as_pdf,
                                  color: const Color(0xFF1A65EB),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    message.fileName ?? 'Attachment',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                message.text,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.time,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Text(
                      message.isRead ? '✓✓' : '✓',
                      style: TextStyle(
                        color: message.isRead ? Colors.white : Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Attach file',
            onPressed: onAttach,
            icon: const Icon(Icons.attach_file, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF1A65EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

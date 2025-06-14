import 'package:flutter/material.dart';

class ChatMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final String? avatarUrl;
  final bool isCurrentUser;

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    this.avatarUrl,
    required this.isCurrentUser,
  });
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading messages
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.addAll(_getDummyMessages());
          _isLoading = false;
        });
        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ChatMessage> _getDummyMessages() {
    return [
      ChatMessage(
        sender: 'John Doe',
        message: 'Hello everyone! Has anyone tried the new headphones?',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        isCurrentUser: false,
      ),
      ChatMessage(
        sender: 'Emma Wilson',
        message: 'Yes! They are amazing. The sound quality is top-notch.',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        isCurrentUser: false,
      ),
      ChatMessage(
        sender: 'Michael Brown',
        message: 'I\'m thinking of getting them. Are they worth the price?',
        timestamp: DateTime.now().subtract(const Duration(hours: 23)),
        isCurrentUser: false,
      ),
      ChatMessage(
        sender: 'You',
        message: 'Definitely worth it! The noise cancellation is incredible.',
        timestamp: DateTime.now().subtract(const Duration(hours: 22)),
        isCurrentUser: true,
      ),
      ChatMessage(
        sender: 'Sophia Garcia',
        message: 'Has anyone had any issues with battery life?',
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        isCurrentUser: false,
      ),
      ChatMessage(
        sender: 'You',
        message: 'Mine lasts about 6-7 hours with noise cancellation on.',
        timestamp: DateTime.now().subtract(const Duration(hours: 19)),
        isCurrentUser: true,
      ),
      ChatMessage(
        sender: 'William Taylor',
        message:
            'That\'s pretty good! I might get them during the sale next week.',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        isCurrentUser: false,
      ),
      ChatMessage(
        sender: 'Olivia Martinez',
        message:
            'Does anyone know if they\'re compatible with Android and iOS?',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        isCurrentUser: false,
      ),
      ChatMessage(
        sender: 'James Johnson',
        message:
            'Yes, they work with both platforms. I use them with my Android phone and iPad.',
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        isCurrentUser: false,
      ),
      ChatMessage(
        sender: 'You',
        message:
            'The app also has some nice EQ settings to customize the sound.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isCurrentUser: true,
      ),
    ];
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          sender: 'You',
          message: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isCurrentUser: true,
        ),
      );
    });

    _messageController.clear();

    // Scroll to the bottom after sending a message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Community Chat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Community Guidelines'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Welcome to the Wealth Store Community Chat!\n\n'
                      '1. Be respectful to other members\n'
                      '2. No spam or promotional content\n'
                      '3. Keep discussions related to products and shopping\n'
                      '4. No sharing of personal information\n'
                      '5. Report any inappropriate behavior\n\n'
                      'Enjoy connecting with other shoppers!',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refreshing messages
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            setState(() {
              // Add a new message at the top when refreshed
              _messages.insert(
                0,
                ChatMessage(
                  sender: 'System',
                  message: 'Chat refreshed. Welcome back!',
                  timestamp: DateTime.now(),
                  isCurrentUser: false,
                ),
              );
            });
          }
        },
        child: Column(
          children: [
            // Chat topics bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey.shade100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _buildTopicChip('All', true),
                    _buildTopicChip('Headphones', false),
                    _buildTopicChip('Laptops', false),
                    _buildTopicChip('Smartphones', false),
                    _buildTopicChip('Accessories', false),
                    _buildTopicChip('Deals', false),
                  ],
                ),
              ),
            ),

            // Messages list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageItem(message);
                      },
                    ),
            ),

            // Message input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo sharing coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFF6518F4),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _sendMessage,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.send, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          // Handle topic selection
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF6518F4),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isCurrentUser = message.isCurrentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              backgroundColor: Colors
                  .primaries[message.sender.hashCode % Colors.primaries.length],
              radius: 16,
              child: Text(
                message.sender[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? const Color(0xFF6518F4)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isCurrentUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isCurrentUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.sender,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  if (!isCurrentUser) const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              backgroundColor: const Color(0xFF6518F4),
              radius: 16,
              child: const Text(
                'Y',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

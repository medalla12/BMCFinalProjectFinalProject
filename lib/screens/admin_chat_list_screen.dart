

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/chat_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});


  Future<String> _fetchUserEmail(String userId) async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['email'] ?? 'Unknown user';
      }
    } catch (e) {
      debugPrint('Error fetching user email: $e');
    }
    return 'Unknown user';
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin – User Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('chats')
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats found.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>? ?? {};

              final userId = data['userId'] ?? '';
              final lastMessage = data['lastMessage'] ?? '';
              final lastUpdated =
              (data['lastUpdated'] as Timestamp?)?.toDate();

              return FutureBuilder<String>(
                future: _fetchUserEmail(userId),
                builder: (context, userSnapshot) {
                  final userEmail = userSnapshot.data ?? 'Loading...';

                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      userEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: lastUpdated != null
                        ? Text(
                      '${lastUpdated.hour}:${lastUpdated.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 12),
                    )
                        : const SizedBox.shrink(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chat.id,
                            receiverId: userId,
                            receiverEmail: userEmail,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

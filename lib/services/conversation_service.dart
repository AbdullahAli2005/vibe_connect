import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen for new conversations
  void listenForNewConversations() {
    _firestore.collection('Conversations').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _handleNewConversation(change.doc);
        }
      }
    });
  }

  // Handle new conversation creation
  Future<void> _handleNewConversation(DocumentSnapshot conversationDoc) async {
    final data = conversationDoc.data() as Map<String, dynamic>;
    final conversationID = conversationDoc.id;
    final List<dynamic> members = data['members'] ?? [];

    for (var currentUserID in members) {
      final remainingUserIDs = members.where((id) => id != currentUserID).toList();

      for (var memberID in remainingUserIDs) {
        try {
          final userDoc = await _firestore.collection('Users').doc(memberID).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            await _firestore
                .collection('Users')
                .doc(currentUserID)
                .collection('Conversations')
                .doc(memberID)
                .set({
              "conversationID": conversationID,
              "image": userData?['image'],
              "name": userData?['name'],
              "unseenCount": 0,
            });
          }
        } catch (e) {
          print('Error handling new conversation: $e');
        }
      }
    }
  }

  // Listen for conversation updates
  void listenForConversationUpdates() {
    _firestore.collection('Conversations').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          _handleConversationUpdate(change.doc);
        }
      }
    });
  }

  // Handle conversation updates
  Future<void> _handleConversationUpdate(DocumentSnapshot conversationDoc) async {
    final data = conversationDoc.data() as Map<String, dynamic>;
    final List<dynamic> members = data['members'] ?? [];
    final lastMessage = (data['messages'] as List).last;

    for (var currentUserID in members) {
      final remainingUserIDs = members.where((id) => id != currentUserID).toList();

      for (var memberID in remainingUserIDs) {
        try {
          await _firestore
              .collection('Users')
              .doc(currentUserID)
              .collection('Conversations')
              .doc(memberID)
              .update({
            "lastMessage": lastMessage['message'],
            "timestamp": lastMessage['timestamp'],
            "type": lastMessage['type'],
            "unseenCount": FieldValue.increment(1),
          });
        } catch (e) {
          print('Error updating conversation: $e');
        }
      }
    }
  }
}

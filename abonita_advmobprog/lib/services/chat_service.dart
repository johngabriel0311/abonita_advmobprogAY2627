import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:abonita_advmobprog/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Retrieves all registered users from Firestore.
  // Excludes the currently logged-in user.
  // Includes each user's document ID as their UID.
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      final currentUserId = _firebaseAuth.currentUser?.uid;

      return snapshot.docs.where((doc) => doc.id != currentUserId).map((doc) {
        final user = doc.data();

        return {...user, 'uid': doc.id};
      }).toList();
    });
  }

  // Sends a message to the selected recipient.
  //
  // replyTo is optional. If the user is replying to a message,
  // the original message information is stored with the new message.
  Future<void> sendMessage(
    String receiverId,
    String message, {
    Map<String, dynamic>? replyTo,
  }) async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }

    final String currentUserId = currentUser.uid;
    final String currentUserEmail = currentUser.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    final MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Creates a unique chat room ID for both users.
    final List<String> ids = [currentUserId, receiverId];
    ids.sort();

    final String chatRoomID = ids.join('_');

    final Map<String, dynamic> messageData = {
      ...newMessage.toMap(),
      'status': 'sent',
    };

    // Stores reply information when replying to another message.
    if (replyTo != null) {
      messageData['replyTo'] = replyTo;
    }

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(messageData);
  }

  // Retrieves messages between two users.
  Stream<QuerySnapshot> getMessage(String userID, String otherUserID) {
    final List<String> ids = [userID, otherUserID];
    ids.sort();

    final String chatRoomID = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Marks messages received by the current user as seen.
  Future<void> markMessagesAsSeen(
    String currentUserId,
    String otherUserId,
  ) async {
    final List<String> ids = [currentUserId, otherUserId];

    ids.sort();

    final String chatRoomID = ids.join('_');

    final messagesRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages');

    final snapshot = await messagesRef
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    final batch = _firestore.batch();

    bool hasUpdates = false;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final status = (data['status'] ?? 'sent').toString();

      if (status != 'seen') {
        batch.update(doc.reference, {'status': 'seen'});

        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
    }
  }

  // Adds or changes a reaction on a message.
  Future<void> reactToMessage(
    String currentUserId,
    String otherUserId,
    String messageId,
    String reaction,
  ) async {
    final List<String> ids = [currentUserId, otherUserId];

    ids.sort();

    final String chatRoomID = ids.join('_');

    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'reaction': reaction,
      'reactionBy': currentUserId,
    });
  }

  // Removes the current user's reaction from a message.
  Future<void> removeReaction(
    String currentUserId,
    String otherUserId,
    String messageId,
  ) async {
    final List<String> ids = [currentUserId, otherUserId];

    ids.sort();

    final String chatRoomID = ids.join('_');

    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'reaction': FieldValue.delete(),
      'reactionBy': FieldValue.delete(),
    });
  }

  // Retrieves a user's Firebase UID using their email.
  Future<String?> getUidByEmail(String email) async {
    final q = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return null;

    final userData = q.docs.first.data();

    return (userData['uid'] ?? q.docs.first.id).toString();
  }
}

# John Gabriel Abonita

# INF231

# CTADMOBL Advance Mobile Programming

Explored how Flutter integrates Firebase Authentication, Cloud Firestore, user profiles, and real-time messaging to implement a chat system.

## Laboratory Activity 6

It all starts when a user selects another registered user from the chat list. The app retrieves the users' information from the Users collection in Cloud Firestore and uses their Firebase UIDs to generate a unique chat room ID. The messages subcollection inside the chat room stores the sender's UID, receiver's UID, message content, timestamp, and message status. The main idea of organizing chat data this way is to ensure that both users can access the same conversation and exchange messages in real time. When a user initiates a chat with themselves, the app generates a chat room ID using the same UID twice, and messages are stored in that room. However, in my current implementation, users cannot normally chat with themselves because the logged-in user is excluded from the chat list.

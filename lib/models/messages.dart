import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  Text,
  Image,
}

class Message {
  final String senderID;
  final String content;
  final Timestamp timestamp;
  final MessageType type;

  Message({required this.senderID, required this.content, required this.timestamp, required this.type});
}

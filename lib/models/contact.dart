import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final Timestamp lastseen;
  final String name;
 
  Contact({required this.id,required this.email,required this.name,required this.image, required this.lastseen});

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data() as Map<String, dynamic>?;
    if (_data == null) {
      throw StateError("Missing data for contact ID: ${_snapshot.id}");
    }
    return Contact(
      id: _snapshot.id,
      lastseen: _data["lastSeen"],
      email: _data["email"],
      name: _data["name"],
      image: _data["image"],
    );
  }
}

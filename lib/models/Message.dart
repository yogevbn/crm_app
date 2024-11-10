import 'package:crm_app/models/baseModel.dart';

class message implements BaseModel {
  @override
  final String id;
  final String text;
  final String? productID;
  final String? clientID;
  final DateTime lastModifiedAt;

  message({
    required this.id,
    required this.text,
    this.productID,
    this.clientID,
    required this.lastModifiedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'productID': productID,
      'clientID': clientID,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  @override
  BaseModel fromMap(Map<String, dynamic> map) {
    return message(
      id: map['id'],
      text: map['text'],
      productID: map['productID'],
      clientID: map['clientID'],
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
    );
  }

  @override
  String getModelName() {
    return 'Messages'; // The collection name in Firestore and SQLite
  }
}

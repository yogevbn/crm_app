import 'package:crm_app/models/baseModel.dart';

class Client implements BaseModel {
  @override
  final String id; // Now nullable to match BaseModel requirements
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? dn; // Optional field
  final String? note; // Optional field
  final DateTime lastModifiedAt; // Required for sync and conflict resolution
  final DateTime? deletedAt; // Optional field for soft deletes, if needed later

  Client({
    required this.id, // id is nullable
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.dn,
    this.note,
    required this.lastModifiedAt,
    this.deletedAt,
  });

  // Convert Client object to Map (for SQLite or Firestore)
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dn': dn,
      'note': note,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'deletedAt': deletedAt
          ?.toIso8601String(), // Handle nullable field for soft deletes
    };
  }

  // Create Client object from Map (this is the required fromMap implementation)
  static fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      dn: map['dn'],
      note: map['note'],
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }

  // Return the collection or table name for this model
  @override
  String getModelName() =>
      'clients'; // The collection name in Firestore and table name in SQLite
}

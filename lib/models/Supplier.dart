import 'dart:convert'; // For JSON encoding and decoding
import 'package:crm_app/models/baseModel.dart';

class Supplier implements BaseModel {
  @override
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? dn;
  final String? note;
  final List<String>? productsIDList;
  final DateTime lastModifiedAt;

  Supplier({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.dn,
    this.note,
    this.productsIDList,
    required this.lastModifiedAt,
  });

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
      // Serialize productsIDList as JSON string
      'productsIDList':
          productsIDList != null ? jsonEncode(productsIDList) : null,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      dn: map['dn'],
      note: map['note'],
      // Deserialize JSON string back to List<String>
      productsIDList: map['productsIDList'] != null
          ? List<String>.from(jsonDecode(map['productsIDList']))
          : null,
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
    );
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? dn,
    String? note,
    List<String>? productsIDList,
    DateTime? lastModifiedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dn: dn ?? this.dn,
      note: note ?? this.note,
      productsIDList: productsIDList ?? this.productsIDList,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  String getModelName() {
    return 'Suppliers';
  }
}

import 'package:crm_app/models/baseModel.dart';

class Stock implements BaseModel {
  @override
  final String id;
  final String productID;
  final String supplierID;
  final int quantity;
  final DateTime lastModifiedAt;

  Stock({
    required this.id,
    required this.productID,
    required this.supplierID,
    required this.quantity,
    required this.lastModifiedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productID': productID,
      'supplierID': supplierID,
      'quantity': quantity,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      productID: map['productID'],
      supplierID: map['supplierID'],
      quantity: map['quantity'],
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
    );
  }

  Stock copyWith({
    String? id,
    String? productID,
    String? supplierID,
    int? quantity,
    DateTime? lastModifiedAt,
  }) {
    return Stock(
      id: id ?? this.id,
      productID: productID ?? this.productID,
      supplierID: supplierID ?? this.supplierID,
      quantity: quantity ?? this.quantity,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  String getModelName() {
    return 'Stocks'; // The collection name in Firestore and SQLite
  }
}

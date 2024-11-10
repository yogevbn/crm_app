import 'package:crm_app/models/baseModel.dart';

class SupplierOrder implements BaseModel {
  @override
  final String id;
  final String supplierID;
  final List<String> productsList;
  final DateTime date;
  final double totalPrice;
  final String status;
  final DateTime lastModifiedAt;
  final DateTime? deletedAt; // Optional field for soft deletes, if needed

  SupplierOrder({
    required this.id,
    required this.supplierID,
    required this.productsList,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.lastModifiedAt,
    this.deletedAt,
  });

  // Convert SupplierOrder object to a Map for Firestore or SQLite
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierID': supplierID,
      'productsList': productsList,
      'date': date.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  // Static method to create a SupplierOrder object from a Map
  static SupplierOrder fromMap(Map<String, dynamic> map) {
    return SupplierOrder(
      id: map['id'],
      supplierID: map['supplierID'],
      productsList: List<String>.from(map['productsList']),
      date: DateTime.parse(map['date']),
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
      deletedAt:
          map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
    );
  }

  // Return the collection or table name for this model
  @override
  String getModelName() => 'supplierOrders';
}

import 'package:crm_app/models/baseModel.dart';

class ClientOrder implements BaseModel {
  @override
  final String id;
  final String clientId;
  final List<String> productsList;
  final DateTime date;
  final double totalPrice;
  final String status;
  final DateTime lastModifiedAt;

  ClientOrder({
    required this.id,
    required this.clientId,
    required this.productsList,
    required this.date,
    required this.totalPrice,
    required this.status,
    required this.lastModifiedAt,
  });

  // Convert ClientOrder object to a map (for Firestore or SQLite)
  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'productsList': productsList,
        'date': date.toIso8601String(),
        'totalPrice': totalPrice,
        'status': status,
        'lastModifiedAt': lastModifiedAt.toIso8601String(),
      };

  // Create a ClientOrder object from a map (from Firestore or SQLite)
  factory ClientOrder.fromMap(Map<String, dynamic> map) {
    return ClientOrder(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      productsList: List<String>.from(map['productsList'] ?? []),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      lastModifiedAt: DateTime.parse(
          map['lastModifiedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String getModelName() =>
      'clientOrders'; // The collection name in Firestore and SQLite
}

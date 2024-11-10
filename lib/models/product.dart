import 'package:crm_app/models/baseModel.dart';

class Product implements BaseModel {
  @override
  final String id;
  final String name;
  final String? barCode;
  final String description;
  final double price;
  final String typeOfUnit;
  final String? productImg;
  final String categoryID;
  final DateTime lastModifiedAt;

  Product({
    required this.id,
    required this.name,
    this.barCode,
    required this.description,
    required this.price,
    required this.typeOfUnit,
    this.productImg,
    required this.categoryID,
    required this.lastModifiedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barCode': barCode,
      'description': description,
      'price': price,
      'typeOfUnit': typeOfUnit,
      'productImg': productImg,
      'categoryID': categoryID,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  // Define the copyWith method to create a modified copy of Product
  Product copyWith({
    String? id,
    String? name,
    String? barCode,
    String? description,
    double? price,
    String? typeOfUnit,
    String? productImg,
    String? categoryID,
    DateTime? lastModifiedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barCode: barCode ?? this.barCode,
      description: description ?? this.description,
      price: price ?? this.price,
      typeOfUnit: typeOfUnit ?? this.typeOfUnit,
      productImg: productImg ?? this.productImg,
      categoryID: categoryID ?? this.categoryID,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  @override
  String getModelName() {
    return 'Products'; // Collection/table name in Firebase/SQLite
  }

  // Factory constructor for fromMap conversion
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      barCode: map['barCode'] as String?,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      typeOfUnit: map['typeOfUnit'] as String,
      productImg: map['productImg'] as String?,
      categoryID: map['categoryID'] as String,
      lastModifiedAt: DateTime.parse(map['lastModifiedAt'] as String),
    );
  }
}

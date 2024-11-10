import 'package:crm_app/models/baseModel.dart';

class ProductCategory implements BaseModel {
  @override
  final String id;
  final String name;
  final String? description;
  final String? categoryImg;
  final DateTime lastModifiedAt;

  ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.categoryImg,
    required this.lastModifiedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryImg': categoryImg,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  ProductCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryImg,
    DateTime? lastModifiedAt,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryImg: categoryImg ?? this.categoryImg,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
    );
  }

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      categoryImg: map['categoryImg'],
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
    );
  }

  @override
  String getModelName() {
    return 'productCategory'; // The collection name in Firestore and SQLite
  }
}

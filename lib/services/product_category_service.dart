import 'dart:async';
import 'dart:io';
import 'package:crm_app/models/ProductCategory.dart';
import 'package:crm_app/services/datamanage/image_handling_service.dart';
import 'package:crm_app/services/datamanage/firebase_service.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';

class ProductCategoryService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  final SyncService syncService = SyncService();
  final ImageHandlingService imageHandlingService = ImageHandlingService();

  ProductCategoryService() {
    syncService.initialize(); // Ensure databases are initialized
  }

  // Helper method to create a temporary ProductCategory instance
  ProductCategory _tempCategory() {
    return ProductCategory(
      id: '',
      name: '',
      description: null,
      categoryImg: null,
      lastModifiedAt: DateTime.now(),
    );
  }

  // Fetch all categories from local SQLite storage
  Future<List<ProductCategory>> fetchAllCategories() async {
    List<Map<String, dynamic>> categoriesData =
        await sqliteService.fetchAll(_tempCategory());
    return categoriesData.map((data) => ProductCategory.fromMap(data)).toList();
  }

  Future<String> fetchCategoryName(String categoryId) async {
    final category = await fetchCategoryById(categoryId);
    return category?.name ?? 'Unknown';
  }

  // Check if a category with the same name already exists
  Future<bool> doesCategoryNameExist(String name) async {
    List<Map<String, dynamic>> existingCategories = await sqliteService.query(
      'SELECT * FROM productCategory WHERE name = ?',
      [name],
    );
    return existingCategories.isNotEmpty;
  }

  // Sync categories between Firebase and SQLite with delta sync
  Future<void> syncCategories() async {
    await syncService.sync(
      _tempCategory(),
      fromMap: (data) => ProductCategory.fromMap(data),
    );
  }

  // Add a new category with optional image and flexible input for category name
  Future<void> addCategory({
    ProductCategory? category,
    String? categoryName,
    File? image,
  }) async {
    // If only a category name is provided, check for uniqueness and create a new ProductCategory if it doesn't exist
    if (category == null && categoryName != null) {
      bool exists = await doesCategoryNameExist(categoryName);
      if (!exists) {
        category = ProductCategory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: categoryName,
          description: null,
          categoryImg: null,
          lastModifiedAt: DateTime.now(),
        );
      } else {
        throw Exception("Category name already exists");
      }
    }

    // If an image is provided, save it and update the category with the image path
    if (category != null && image != null) {
      final imagePath =
          imageHandlingService.getAssetPath('ProductCategory', category.id);
      await imageHandlingService.saveOrReplaceImage(
          image, 'ProductCategory', category.id);
      category = category.copyWith(categoryImg: imagePath);
    }

    // Add category to SQLite and Firebase if it's newly created
    if (category != null) {
      await sqliteService.insert(category);
      await firebaseService.insert(category);
    }
  }

  // Update an existing category with optional image handling
  Future<void> updateCategory(ProductCategory category,
      {File? newImage}) async {
    if (newImage != null) {
      final imagePath =
          imageHandlingService.getAssetPath('ProductCategory', category.id);
      await imageHandlingService.saveOrReplaceImage(
          newImage, 'ProductCategory', category.id);
      category = category.copyWith(categoryImg: imagePath);
    }
    await sqliteService.update(category, category.id);
    await firebaseService.update(category, category.id);
  }

  // Delete a category along with its image
  Future<void> deleteCategory(String categoryId) async {
    final ProductCategory? category = await fetchCategoryById(categoryId);
    if (category != null) {
      await imageHandlingService.deleteImage('ProductCategory', category.id);
      await sqliteService.delete(_tempCategory(), categoryId);
      await firebaseService.delete(_tempCategory(), categoryId);
    }
  }

  // Fetch a single category by ID from SQLite
  Future<ProductCategory?> fetchCategoryById(String categoryId) async {
    Map<String, dynamic>? categoryData =
        await sqliteService.fetchById(_tempCategory(), categoryId);
    return categoryData != null ? ProductCategory.fromMap(categoryData) : null;
  }

  // Stream categories from SQLite for real-time UI updates
  Stream<List<ProductCategory>> getCategoriesStream() {
    return sqliteService.watchTable(_tempCategory()).map(
          (categoriesData) => categoriesData
              .map((data) => ProductCategory.fromMap(data))
              .toList(),
        );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:crm_app/models/product.dart';
import 'package:crm_app/models/stock.dart';
import 'package:crm_app/services/datamanage/image_handling_service.dart';
import 'package:crm_app/services/datamanage/firebase_service.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';
import 'package:crm_app/services/stock_service.dart';

class ProductService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  final SyncService syncService = SyncService();
  final ImageHandlingService imageHandlingService = ImageHandlingService();
  final StockService stockService = StockService(); // Add StockService

  ProductService() {
    syncService.initialize(); // Ensure databases are initialized
  }

  // Cached list of products for quick access
  List<Product> _products = [];

  List<Product> get products => _products;

  // Helper method to create a temporary Product instance
  Product _tempProduct() {
    return Product(
      id: '',
      name: '',
      description: '',
      price: 0.0,
      typeOfUnit: '',
      categoryID: '',
      lastModifiedAt: DateTime.now(),
    );
  }

  // Fetch all products from local SQLite storage
  Future<List<Product>> fetchAllProducts() async {
    List<Map<String, dynamic>> productsData =
        await sqliteService.fetchAll(_tempProduct());
    _products = productsData.map((data) => Product.fromMap(data)).toList();
    return _products;
  }

  // Sync products between Firebase and SQLite with delta sync
  Future<void> syncProducts() async {
    await syncService.sync(
      _tempProduct(),
      fromMap: (data) => Product.fromMap(data),
    );
    await fetchAllProducts(); // Refresh local cache after sync
  }

  // Fetch product details (name and typeOfUnit) by product ID
  Future<Map<String, String>> fetchProductDetails(String productId) async {
    final productData =
        await sqliteService.fetchById(_tempProduct(), productId);
    if (productData != null) {
      return {
        'name': productData['name'] ?? 'Unknown',
        'unitType': productData['typeOfUnit'] ?? 'unit',
      };
    }
    return {'name': 'Unknown', 'unitType': 'unit'};
  }

// Stream of products from SQLite for real-time UI updates
  Stream<List<Product>> getProductsStream() {
    return sqliteService.watchTable(_tempProduct()).map(
          (productsData) =>
              productsData.map((data) => Product.fromMap(data)).toList(),
        );
  }

  // Add a new product to both SQLite and Firebase, save image if available
  Future<void> addProduct(Product product, {File? image}) async {
    // Handle image saving if provided
    if (image != null) {
      final imagePath =
          imageHandlingService.getAssetPath('Product', product.id);
      await imageHandlingService.saveOrReplaceImage(
          image, 'Product', product.id);
      product = product.copyWith(productImg: imagePath);
    }

    // Insert product into SQLite and Firebase
    await sqliteService.insert(product);
    await firebaseService.insert(product);

    _products.add(product); // Update local cache

    // Initialize stock entry for the product with quantity 0
    final Stock initialStock = Stock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productID: product.id,
      supplierID: 'unknown', // Placeholder for supplier ID
      quantity: 0, // Initial quantity set to 0
      lastModifiedAt: DateTime.now(),
    );

    // Add initial stock entry to StockService
    await stockService.addStock(initialStock);
  }

  // Update an existing product in both SQLite and Firebase, handle image updates if provided
  Future<void> updateProduct(Product product, {File? newImage}) async {
    if (newImage != null) {
      final imagePath =
          imageHandlingService.getAssetPath('Product', product.id);
      await imageHandlingService.saveOrReplaceImage(
          newImage, 'Product', product.id);
      product = product.copyWith(productImg: imagePath);
    }
    await sqliteService.update(product, product.id);
    await firebaseService.update(product, product.id);

    _products = await fetchAllProducts(); // Refresh local cache
  }

  // Delete a product from both SQLite and Firebase, including its image
  Future<void> deleteProduct(String productId) async {
    final Product? product = await fetchProductById(productId);
    if (product != null) {
      // Delete the associated image
      await imageHandlingService.deleteImage('Product', product.id);

      // Delete the product from SQLite and Firebase
      await sqliteService.delete(_tempProduct(), productId);
      await firebaseService.delete(_tempProduct(), productId);

      _products.removeWhere((p) => p.id == productId); // Update local cache
    }
  }

  // Fetch a single product by ID from SQLite
  Future<Product?> fetchProductById(String productId) async {
    Map<String, dynamic>? productData =
        await sqliteService.fetchById(_tempProduct(), productId);
    return productData != null ? Product.fromMap(productData) : null;
  }
}

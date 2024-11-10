import 'dart:async';
import 'package:crm_app/models/supplier.dart';
import 'package:crm_app/services/datamanage/firebase_service.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';
import 'package:crm_app/services/product_service.dart';

class SupplierService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  final SyncService syncService = SyncService();
  final ProductService productService = ProductService(); // Add ProductService
  SupplierService() {
    syncService.initialize(); // Ensure databases are initialized
  }

  // Temporary Supplier instance for database operations
  Supplier _tempSupplier() {
    return Supplier(
      id: '',
      name: '',
      email: '',
      phone: '',
      address: '',
      dn: null,
      note: null,
      productsIDList: [],
      lastModifiedAt: DateTime.now(),
    );
  }

  // Fetch all suppliers from local SQLite storage
  Future<List<Supplier>> fetchAllSuppliers() async {
    final suppliersData = await sqliteService.fetchAll(_tempSupplier());
    return suppliersData.map((data) => Supplier.fromMap(data)).toList();
  }

  // Sync suppliers between Firebase and SQLite with delta sync
  Future<void> syncSuppliers() async {
    await syncService.sync(
      _tempSupplier(),
      fromMap: (data) => Supplier.fromMap(data),
    );
  }

  // Add a new supplier to both SQLite and Firebase
  Future<void> addSupplier(Supplier supplier) async {
    await sqliteService.insert(supplier);
    await firebaseService.insert(supplier);
  }

  // Update an existing supplier in both SQLite and Firebase
  Future<void> updateSupplier(Supplier supplier) async {
    await sqliteService.update(supplier, supplier.id);
    await firebaseService.update(supplier, supplier.id);
  }

  // Delete a supplier from both SQLite and Firebase
  Future<void> deleteSupplier(String supplierId) async {
    await sqliteService.delete(_tempSupplier(), supplierId);
    await firebaseService.delete(_tempSupplier(), supplierId);
  }

  // Fetch a single supplier by ID from SQLite
  Future<Supplier?> fetchSupplierById(String supplierId) async {
    final supplierData =
        await sqliteService.fetchById(_tempSupplier(), supplierId);
    return supplierData != null ? Supplier.fromMap(supplierData) : null;
  }

  // Fetch a supplier's name by supplierID, with default fallback if not found
  Future<String> fetchSupplierName(String supplierID) async {
    try {
      final supplierData =
          await sqliteService.fetchById(_tempSupplier(), supplierID);
      return supplierData?['name'] ?? 'Unknown Supplier';
    } catch (e) {
      print("Error fetching supplier name: $e");
      return 'Unknown Supplier';
    }
  }

  // Check if a supplier with the specified name exists in SQLite
  Future<bool> doesSupplierNameExist(String name) async {
    const sql = 'SELECT * FROM Suppliers WHERE name = ? LIMIT 1';
    final result = await sqliteService.query(sql, [name]);
    return result.isNotEmpty;
  }

  // Stream suppliers from SQLite for real-time UI updates
  Stream<List<Supplier>> getSuppliersStream() {
    return sqliteService.watchTable(_tempSupplier()).map(
          (suppliersData) =>
              suppliersData.map((data) => Supplier.fromMap(data)).toList(),
        );
  }

  // Fetch product options for assigning to suppliers
  Future<List<Map<String, String>>> fetchProductOptions() async {
    final products = await productService.fetchAllProducts();
    return products
        .map((product) => {
              'id': product.id,
              'name': product.name,
            })
        .toList();
  }
}

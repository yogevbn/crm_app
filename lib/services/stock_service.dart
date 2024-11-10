import 'dart:async';
import 'package:crm_app/models/stock.dart';
import 'package:crm_app/services/datamanage/firebase_service.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';

class StockService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  final SyncService syncService = SyncService();

  StockService() {
    syncService.initialize(); // Ensure databases are initialized
  }

  // Helper method to create a temporary Stock instance
  Stock _tempStock() {
    return Stock(
      id: '',
      productID: '',
      supplierID: '',
      quantity: 0,
      lastModifiedAt: DateTime.now(),
    );
  }

  // Sync stocks between Firebase and SQLite with delta sync
  Future<void> syncStocks() async {
    await syncService.sync(
      _tempStock(),
      fromMap: (data) => Stock.fromMap(data),
    );
  }

  // Add a new stock entry to both SQLite and Firebase
  Future<void> addStock(Stock stock) async {
    await sqliteService.insert(stock);
    await firebaseService.insert(stock);
  }

  // Update an existing stock entry in both SQLite and Firebase
  Future<void> updateStock(Stock stock) async {
    await sqliteService.update(stock, stock.id);
    await firebaseService.update(stock, stock.id);
  }

  // Delete a stock entry from both SQLite and Firebase
  Future<void> deleteStock(String stockId) async {
    await sqliteService.delete(_tempStock(), stockId);
    await firebaseService.delete(_tempStock(), stockId);
  }

  // Fetch all stock entries from local SQLite storage
  Future<List<Stock>> fetchAllStocks() async {
    List<Map<String, dynamic>> stocksData =
        await sqliteService.fetchAll(_tempStock());
    return stocksData.map((data) => Stock.fromMap(data)).toList();
  }

  // Stream stocks from SQLite for real-time UI updates
  Stream<List<Stock>> getStocksStream() {
    return sqliteService.watchTable(_tempStock()).map(
          (stocksData) =>
              stocksData.map((data) => Stock.fromMap(data)).toList(),
        );
  }
}

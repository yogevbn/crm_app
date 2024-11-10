import 'package:crm_app/models/SupplierOrder.dart';
import 'package:crm_app/models/clientOrder.dart';
import 'package:crm_app/services/datamanage/firebase_service.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';

class OrderService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  final SyncService syncService = SyncService();

  OrderService() {
    syncService.initialize();
  }

  // Fetch all client orders
  Future<List<ClientOrder>> fetchAllClientOrders() async {
    final ordersData = await sqliteService.fetchAll(ClientOrder(
      id: '',
      clientId: '',
      productsList: [],
      date: DateTime.now(),
      totalPrice: 0.0,
      status: '',
      lastModifiedAt: DateTime.now(),
    ));
    return ordersData.map((data) => ClientOrder.fromMap(data)).toList();
  }

  Future<List<SupplierOrder>> fetchAllSupplierOrders() async {
    // Fetching data from SQLite as List<Map<String, dynamic>>
    List<Map<String, dynamic>> ordersData =
        await sqliteService.fetchAll(SupplierOrder(
      id: '',
      supplierID: '',
      productsList: [],
      date: DateTime.now(),
      totalPrice: 0.0,
      status: '',
      lastModifiedAt: DateTime.now(),
    ));

    // Mapping each map to a SupplierOrder object explicitly and enforcing the type
    return ordersData.map<SupplierOrder>((data) {
      return SupplierOrder.fromMap(data);
    }).toList();
  }

  // Add a new client order
  Future<void> addClientOrder(ClientOrder order) async {
    await sqliteService.insert(order);
    await firebaseService.insert(order);
  }

  // Add a new supplier order
  Future<void> addSupplierOrder(SupplierOrder order) async {
    await sqliteService.insert(order);
    await firebaseService.insert(order);
  }

  // Update a client order
  Future<void> updateClientOrder(ClientOrder order) async {
    await sqliteService.update(order, order.id);
    await firebaseService.update(order, order.id);
  }

  // Update a supplier order
  Future<void> updateSupplierOrder(SupplierOrder order) async {
    await sqliteService.update(order, order.id);
    await firebaseService.update(order, order.id);
  }

  // Delete a client order
  Future<void> deleteClientOrder(String orderId) async {
    await sqliteService.delete(
        ClientOrder(
          id: '',
          clientId: '',
          productsList: [],
          date: DateTime.now(),
          totalPrice: 0.0,
          status: '',
          lastModifiedAt: DateTime.now(),
        ),
        orderId);
    await firebaseService.delete(
        ClientOrder(
          id: '',
          clientId: '',
          productsList: [],
          date: DateTime.now(),
          totalPrice: 0.0,
          status: '',
          lastModifiedAt: DateTime.now(),
        ),
        orderId);
  }

  // Delete a supplier order
  Future<void> deleteSupplierOrder(String orderId) async {
    await sqliteService.delete(
        SupplierOrder(
          id: '',
          supplierID: '',
          productsList: [],
          date: DateTime.now(),
          totalPrice: 0.0,
          status: '',
          lastModifiedAt: DateTime.now(),
        ),
        orderId);
    await firebaseService.delete(
        SupplierOrder(
          id: '',
          supplierID: '',
          productsList: [],
          date: DateTime.now(),
          totalPrice: 0.0,
          status: '',
          lastModifiedAt: DateTime.now(),
        ),
        orderId);
  }
}

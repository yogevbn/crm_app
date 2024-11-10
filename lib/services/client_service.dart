import 'dart:async';
import 'package:crm_app/models/Client.dart';
import 'package:crm_app/models/clientOrder.dart';
import 'package:crm_app/services/datamanage/firebase_service.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';

class ClientService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  final SyncService syncService = SyncService();

  ClientService() {
    syncService.initialize();
  }

  // Cached list of clients for quick access
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  Future<List<Client>> fetchAllClients() async {
    // Fetching data from SQLite as List<Map<String, dynamic>>
    List<Map<String, dynamic>> clientsData =
        await sqliteService.fetchAll(Client(
      id: '',
      name: '',
      email: '',
      phone: '',
      address: '',
      lastModifiedAt: DateTime.now(),
    ));

    // Mapping each map to a Client object explicitly and enforcing the type
    _clients = clientsData.map<Client>((data) {
      return Client.fromMap(data);
    }).toList();

    return _clients;
  }

  Future<Map<String, dynamic>> fetchClientDetails(String clientId) async {
    Map<String, dynamic>? clientData = await sqliteService.fetchById(
        Client(
            id: clientId,
            name: '',
            email: '',
            phone: '',
            address: '',
            lastModifiedAt: DateTime.now()),
        clientId);
    return clientData ?? {};
  }

  // Sync clients between Firebase and SQLite
  Future<void> syncClients() async {
    await syncService.sync<Client>(
      Client(
        id: '',
        name: '',
        email: '',
        phone: '',
        address: '',
        lastModifiedAt: DateTime.now(),
      ),
      fromMap: (data) => Client.fromMap(data),
    );
    await fetchAllClients(); // Refresh local cache after sync
  }

  // Add a new client to both SQLite and Firebase
  Future<void> addClient(Client client) async {
    await sqliteService.insert(client);
    await firebaseService.insert(client);
    _clients.add(client); // Update local cache
  }

  // Update an existing client in both SQLite and Firebase
  Future<void> updateClient(Client client) async {
    await sqliteService.update(client, client.id);
    await firebaseService.update(client, client.id);
    _clients = await fetchAllClients(); // Refresh local cache
  }

  // Delete a client from both SQLite and Firebase
  Future<void> deleteClient(String clientId) async {
    await sqliteService.delete(
        Client(
            id: '',
            name: '',
            email: '',
            phone: '',
            address: '',
            lastModifiedAt: DateTime.now()),
        clientId);
    await firebaseService.delete(
        Client(
            id: '',
            name: '',
            email: '',
            phone: '',
            address: '',
            lastModifiedAt: DateTime.now()),
        clientId);
    _clients
        .removeWhere((client) => client.id == clientId); // Update local cache
  }

  // Fetch all orders related to a specific client
  Future<List<ClientOrder>> fetchClientOrders(String clientId) async {
    List<Map<String, dynamic>> ordersData = await sqliteService.query(
      'SELECT * FROM clientOrders WHERE clientId = ?',
      [clientId],
    );
    return ordersData.map((data) => ClientOrder.fromMap(data)).toList();
  }
}

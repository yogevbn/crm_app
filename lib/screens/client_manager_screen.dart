import 'package:flutter/material.dart';
import 'package:crm_app/models/Client.dart';
import 'package:crm_app/services/client_service.dart';
import 'package:crm_app/services/translation_service.dart';
import 'client_edit_screen.dart';

class ClientManagerScreen extends StatefulWidget {
  @override
  _ClientManagerScreenState createState() => _ClientManagerScreenState();
}

class _ClientManagerScreenState extends State<ClientManagerScreen> {
  final ClientService clientService = ClientService();

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation.translate('client_manager')),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              await clientService.syncClients();
              setState(() {}); // Refresh after sync
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Client>>(
        future: clientService.fetchAllClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading clients'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No clients available'));
          }

          final clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];

              return ListTile(
                title: Text(client.name),
                subtitle:
                    Text("${translation.translate('email')}: ${client.email}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editClient(client),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteClient(client.id),
                    ),
                  ],
                ),
                onTap: () => _viewClientOrders(client.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addClient,
      ),
    );
  }

  Future<void> _addClient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientEditScreen()),
    );
    if (result == true) setState(() {}); // Refresh if a client was added
  }

  Future<void> _editClient(Client client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientEditScreen(client: client),
      ),
    );
    if (result == true) setState(() {}); // Refresh if a client was updated
  }

  Future<void> _deleteClient(String clientId) async {
    await clientService.deleteClient(clientId);
    setState(() {}); // Refresh after deletion
  }

  Future<void> _viewClientOrders(String clientId) async {
    // Show the orders of the client
    final translation =
        TranslationService.of(context); // Get the translation instance here
    final orders = await clientService.fetchClientOrders(clientId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translation.translate('client_orders')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            children: orders.map((order) {
              return ListTile(
                title: Text("Order ID: ${order.id}"),
                subtitle: Text(
                    "Total Price: ${order.totalPrice} - Status: ${order.status}"),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: Text(translation.translate('close')),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

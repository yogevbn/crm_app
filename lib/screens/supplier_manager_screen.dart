import 'package:flutter/material.dart';
import 'package:crm_app/models/supplier.dart';
import 'package:crm_app/services/supplier_service.dart';
import 'package:crm_app/services/translation_service.dart';
import 'supplier_setup_screen.dart'; // Screen for adding/editing suppliers

class SupplierManagerScreen extends StatefulWidget {
  @override
  _SupplierManagerScreenState createState() => _SupplierManagerScreenState();
}

class _SupplierManagerScreenState extends State<SupplierManagerScreen> {
  final SupplierService supplierService = SupplierService();

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation.translate('supplier_manager')),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              await supplierService.syncSuppliers();
              setState(() {}); // Refresh after sync
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Supplier>>(
        stream: supplierService.getSuppliersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(translation.translate('error_loading_suppliers')));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(translation.translate('no_suppliers_available')));
          }

          final suppliers = snapshot.data!;
          return ListView.builder(
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];

              return ListTile(
                leading: Icon(Icons.person),
                title: Text(supplier.name),
                subtitle: Text(
                  "${translation.translate('email')}: ${supplier.email}\n"
                  "${translation.translate('phone')}: ${supplier.phone}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editSupplier(supplier),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDeleteSupplier(supplier.id),
                    ),
                  ],
                ),
                onTap: () => _viewSupplierDetails(supplier),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addSupplier,
      ),
    );
  }

  Future<void> _addSupplier() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SupplierSetupScreen()),
    );
    if (result == true) setState(() {}); // Refresh if a supplier was added
  }

  Future<void> _editSupplier(Supplier supplier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SupplierSetupScreen(supplier: supplier)),
    );
    if (result == true) setState(() {}); // Refresh if a supplier was updated
  }

  Future<void> _confirmDeleteSupplier(String supplierId) async {
    final translation = TranslationService.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translation.translate('delete_supplier')),
        content: Text(translation.translate('confirm_delete_supplier')),
        actions: [
          TextButton(
            child: Text(translation.translate('cancel')),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(translation.translate('delete')),
            onPressed: () async {
              await supplierService.deleteSupplier(supplierId);
              Navigator.pop(context);
              setState(() {}); // Refresh after deletion
            },
          ),
        ],
      ),
    );
  }

  void _viewSupplierDetails(Supplier supplier) {
    final translation = TranslationService.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(supplier.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${translation.translate('email')}: ${supplier.email}"),
                Text("${translation.translate('phone')}: ${supplier.phone}"),
                Text(
                    "${translation.translate('address')}: ${supplier.address}"),
                if (supplier.dn != null && supplier.dn!.isNotEmpty)
                  Text("${translation.translate('dn')}: ${supplier.dn}"),
                if (supplier.note != null && supplier.note!.isNotEmpty)
                  Text("${translation.translate('note')}: ${supplier.note}"),
                if (supplier.productsIDList != null &&
                    supplier.productsIDList!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "${translation.translate('products')}: ${supplier.productsIDList!.join(', ')}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(translation.translate('close')),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}

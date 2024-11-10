import 'package:crm_app/models/SupplierOrder.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/services/order_service.dart';
import 'package:crm_app/services/translation_service.dart';

class NewSupplierOrderScreen extends StatefulWidget {
  @override
  _NewSupplierOrderScreenState createState() => _NewSupplierOrderScreenState();
}

class _NewSupplierOrderScreenState extends State<NewSupplierOrderScreen> {
  final OrderService orderService = OrderService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<String> selectedProducts = [];

  Future<void> _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      final supplierOrder = SupplierOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        supplierID:
            "supplier_id_placeholder", // Replace with actual supplier ID
        productsList: selectedProducts,
        date: selectedDate,
        totalPrice: double.parse(_totalPriceController.text),
        status: _statusController.text,
        lastModifiedAt: DateTime.now(),
      );

      await orderService.addSupplierOrder(supplierOrder);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation.translate('new_supplier_order')),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveOrder,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _totalPriceController,
                decoration: InputDecoration(
                  labelText: translation.translate('total_price'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? translation.translate('enter_total_price')
                    : null,
              ),
              TextFormField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: translation.translate('status'),
                ),
              ),
              ElevatedButton(
                onPressed: _saveOrder,
                child: Text(translation.translate('save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

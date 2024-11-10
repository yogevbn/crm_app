import 'package:flutter/material.dart';
import 'package:crm_app/models/stock.dart';
import 'package:crm_app/services/stock_service.dart';
import 'package:crm_app/services/product_service.dart';
import 'package:crm_app/services/supplier_service.dart';
import 'package:crm_app/services/translation_service.dart';

class StockSetupScreen extends StatefulWidget {
  final Stock? stock;

  StockSetupScreen({this.stock});

  @override
  _StockSetupScreenState createState() => _StockSetupScreenState();
}

class _StockSetupScreenState extends State<StockSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final StockService stockService = StockService();
  final ProductService productService = ProductService();
  final SupplierService supplierService = SupplierService();

  late TextEditingController _quantityController;
  String? _selectedProductId;
  String? _selectedSupplierId;
  List<Map<String, String>> products = [];
  List<Map<String, String>> suppliers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchProducts();
    _fetchSuppliers();
  }

  void _initializeControllers() {
    _quantityController = TextEditingController(
        text: widget.stock?.quantity.toString() ??
            ''); // Load initial quantity if editing
    _selectedProductId = widget.stock?.productID;
    _selectedSupplierId = widget.stock?.supplierID;
  }

  Future<void> _fetchProducts() async {
    final fetchedProducts = await productService.fetchAllProducts();
    setState(() {
      products = fetchedProducts
          .map((product) => {'id': product.id, 'name': product.name})
          .toList();
    });
  }

  Future<void> _fetchSuppliers() async {
    final fetchedSuppliers = await supplierService.fetchAllSuppliers();
    setState(() {
      suppliers = fetchedSuppliers
          .map((supplier) => {'id': supplier.id, 'name': supplier.name})
          .toList();
    });
  }

  Future<void> _saveStock() async {
    if (_formKey.currentState!.validate()) {
      final stockId =
          widget.stock?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final quantity = int.tryParse(_quantityController.text) ?? 0;

      final stock = Stock(
        id: stockId,
        productID: _selectedProductId!,
        supplierID: _selectedSupplierId!,
        quantity: quantity,
        lastModifiedAt: DateTime.now(),
      );

      if (widget.stock == null) {
        await stockService.addStock(stock);
      } else {
        await stockService.updateStock(stock);
      }

      Navigator.pop(context, true); // Return to previous screen with success
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stock == null
            ? translation.translate('add_stock')
            : translation.translate('edit_stock')),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveStock,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProductId,
                items: products.map((product) {
                  return DropdownMenuItem(
                    value: product['id'],
                    child: Text(product['name']!),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedProductId = value),
                decoration: InputDecoration(
                  labelText: translation.translate('select_product'),
                ),
                validator: (value) => value == null
                    ? translation.translate('select_product_error')
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: suppliers.any(
                        (supplier) => supplier['id'] == _selectedSupplierId)
                    ? _selectedSupplierId
                    : null, // Reset to null if not in the list
                items: suppliers.map((supplier) {
                  return DropdownMenuItem(
                    value: supplier['id'],
                    child: Text(supplier['name']!),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSupplierId = value),
                decoration: InputDecoration(
                  labelText: translation.translate('select_supplier'),
                ),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: translation.translate('quantity'),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return translation.translate('enter_quantity');
                  }
                  if (int.tryParse(value) == null) {
                    return translation.translate('enter_valid_quantity');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

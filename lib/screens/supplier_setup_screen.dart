import 'package:flutter/material.dart';
import 'package:crm_app/models/supplier.dart';
import 'package:crm_app/services/supplier_service.dart';
import 'package:crm_app/services/translation_service.dart';

class SupplierSetupScreen extends StatefulWidget {
  final Supplier? supplier;

  SupplierSetupScreen({this.supplier});

  @override
  _SupplierSetupScreenState createState() => _SupplierSetupScreenState();
}

class _SupplierSetupScreenState extends State<SupplierSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupplierService supplierService = SupplierService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dnController;
  late TextEditingController _noteController;
  List<String> selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _emailController =
        TextEditingController(text: widget.supplier?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.supplier?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.supplier?.address ?? '');
    _dnController = TextEditingController(text: widget.supplier?.dn ?? '');
    _noteController = TextEditingController(text: widget.supplier?.note ?? '');
    selectedProducts = widget.supplier?.productsIDList ?? [];
  }

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      final supplierId = widget.supplier?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      final supplier = Supplier(
        id: supplierId,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        dn: _dnController.text,
        note: _noteController.text,
        productsIDList: selectedProducts,
        lastModifiedAt: DateTime.now(),
      );

      if (widget.supplier == null) {
        await supplierService.addSupplier(supplier);
      } else {
        await supplierService.updateSupplier(supplier);
      }

      Navigator.pop(context, true); // Return to previous screen with success
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier == null
            ? translation.translate('add_supplier')
            : translation.translate('edit_supplier')),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSupplier,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: translation.translate('name'),
                ),
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_supplier_name')
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: translation.translate('email'),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_email')
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: translation.translate('phone'),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_phone')
                    : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: translation.translate('address'),
                ),
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_address')
                    : null,
              ),
              TextFormField(
                controller: _dnController,
                decoration: InputDecoration(
                  labelText: translation.translate('dn'),
                ),
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: translation.translate('note'),
                ),
              ),
              SizedBox(height: 20),
              Text(
                translation.translate('products'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Add a widget to select products, e.g., a dropdown or multiselect
              // Assuming you have a method to fetch product list
              FutureBuilder<List<Map<String, String>>>(
                future: supplierService.fetchProductOptions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text(
                        translation.translate('error_loading_products'));
                  }

                  final productOptions = snapshot.data ?? [];
                  return Column(
                    children: productOptions.map((product) {
                      return CheckboxListTile(
                        title: Text(product['name']!),
                        value: selectedProducts.contains(product['id']),
                        onChanged: (isSelected) {
                          setState(() {
                            if (isSelected == true) {
                              selectedProducts.add(product['id']!);
                            } else {
                              selectedProducts.remove(product['id']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

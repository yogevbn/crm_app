import 'package:crm_app/models/Client.dart';
import 'package:crm_app/models/product.dart';
import 'package:crm_app/services/client_service.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/models/clientOrder.dart';
import 'package:crm_app/services/order_service.dart';
import 'package:crm_app/services/translation_service.dart';
import 'package:crm_app/services/product_service.dart';

class NewClientOrderScreen extends StatefulWidget {
  @override
  _NewClientOrderScreenState createState() => _NewClientOrderScreenState();
}

class _NewClientOrderScreenState extends State<NewClientOrderScreen> {
  final OrderService orderService = OrderService();
  final ClientService clientService = ClientService();
  final ProductService productService = ProductService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> selectedProducts = [];
  double totalOrderPrice = 0.0;

  String? selectedClientId;
  Map<String, dynamic>? selectedClientDetails;
  Product? selectedProduct;

  List<Client> clientList = [];
  List<Product> productList = [];

  @override
  void initState() {
    super.initState();
    _loadClientsAndProducts();
  }

  Future<void> _loadClientsAndProducts() async {
    final clients = await clientService.fetchAllClients();
    final products = await productService.fetchAllProducts();
    setState(() {
      clientList = clients;
      productList = products;
    });
  }

  @override
  void dispose() {
    _totalPriceController.dispose();
    _statusController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      final clientOrder = ClientOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: selectedClientId ?? "client_id_placeholder",
        productsList: selectedProducts.map((e) => e['id'] as String).toList(),
        date: selectedDate,
        totalPrice: totalOrderPrice,
        status: _statusController.text,
        lastModifiedAt: DateTime.now(),
      );

      await orderService.addClientOrder(clientOrder);
      Navigator.pop(context, true);
    }
  }

  void _addProductToOrder() {
    if (selectedProduct != null && _quantityController.text.isNotEmpty) {
      double productPrice = selectedProduct!.price;
      int quantity = int.tryParse(_quantityController.text) ?? 0;

      if (quantity > 0) {
        double totalPrice = productPrice * quantity;

        setState(() {
          selectedProducts.add({
            'id': selectedProduct!.id,
            'name': selectedProduct!.name,
            'price': productPrice,
            'quantity': quantity,
            'totalPrice': totalPrice,
          });
          totalOrderPrice += totalPrice;
        });
      }
    }
  }

  Widget _buildClientPicker(TranslationService translation) {
    return DropdownButtonFormField<String>(
      value: selectedClientId,
      hint: Text(translation.translate('select_client') ?? 'Select Client'),
      onChanged: (clientId) async {
        setState(() {
          selectedClientId = clientId;
        });
        selectedClientDetails =
            await clientService.fetchClientDetails(clientId!);
      },
      items: clientList.map((client) {
        return DropdownMenuItem<String>(
          value: client.id,
          child: Text(client.name),
        );
      }).toList(),
    );
  }

  Widget _buildProductPicker(TranslationService translation) {
    return DropdownButtonFormField<Product>(
      value: selectedProduct,
      hint: Text(translation.translate('select_product') ?? 'Select Product'),
      onChanged: (Product? product) {
        setState(() {
          selectedProduct = product;
        });
      },
      items: productList.map((product) {
        return DropdownMenuItem<Product>(
          value: product,
          child: Text(product.name),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedProductsList(TranslationService translation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedProducts.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translation.translate('product_name') ?? 'Product Name'),
              Text(translation.translate('price_per_unit') ?? 'Price/Unit'),
              Text(translation.translate('quantity') ?? 'Quantity'),
              Text(translation.translate('total_price') ?? 'Total Price'),
            ],
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: selectedProducts.length,
          itemBuilder: (context, index) {
            final product = selectedProducts[index];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product['name']),
                Text(product['price'].toString()),
                Text(product['quantity'].toString()),
                Text(product['totalPrice'].toString()),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            translation.translate('new_client_order') ?? 'New Client Order'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClientPicker(translation),
                if (selectedClientDetails != null) ...[
                  Text("Name: ${selectedClientDetails!['name']}"),
                  Text("Email: ${selectedClientDetails!['email']}"),
                  Text("Phone: ${selectedClientDetails!['phone']}"),
                ],
                SizedBox(height: 16),
                _buildProductPicker(translation),
                if (selectedProduct != null) ...[
                  Text(
                      "${translation.translate('product_price') ?? 'Product Price'}: ${selectedProduct!.price}"),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText:
                          translation.translate('quantity') ?? 'Quantity',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: _addProductToOrder,
                    child: Text(
                        translation.translate('add_product') ?? 'Add Product'),
                  ),
                ],
                SizedBox(height: 16),
                _buildSelectedProductsList(translation),
                Divider(),
                Text(
                  "${translation.translate('total') ?? 'Total'}: ₪$totalOrderPrice",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _statusController,
                  decoration: InputDecoration(
                    labelText: translation.translate('status') ?? 'Status',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

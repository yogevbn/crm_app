import 'package:crm_app/services/stock_service.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/models/stock.dart';
import 'package:crm_app/services/product_service.dart';
import 'package:crm_app/services/supplier_service.dart';
import 'package:crm_app/services/translation_service.dart';
import 'stock_setup_screen.dart';

class StockManagerScreen extends StatefulWidget {
  @override
  _StockManagerScreenState createState() => _StockManagerScreenState();
}

class _StockManagerScreenState extends State<StockManagerScreen> {
  final StockService stockService = StockService();
  final ProductService productService = ProductService();
  final SupplierService supplierService = SupplierService();

  String searchQuery = '';
  String? selectedProduct;
  List<Map<String, String>> products = []; // List of product IDs and names

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final fetchedProducts = await productService.fetchAllProducts();
    setState(() {
      products = fetchedProducts
          .map((product) => {'id': product.id, 'name': product.name})
          .toList();
      products.insert(0, {
        'id': '',
        'name': TranslationService.of(context).translate('all_products')
      }); // "All Products" option
    });
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation.translate('stock_manager')),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () => stockService.syncStocks(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: translation.translate('search_by_quantity'),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedProduct,
                  hint: Text(translation.translate('filter_by_product')),
                  items: products.map((product) {
                    return DropdownMenuItem(
                      value: product['id'],
                      child: Text(product['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Stock>>(
              stream: stockService.getStocksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child:
                          Text(translation.translate('error_loading_stock')));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(translation.translate('no_stock_available')));
                }

                final stocks = snapshot.data!.where((stock) {
                  final matchesSearch = searchQuery.isEmpty ||
                      stock.quantity.toString().contains(searchQuery);
                  final matchesProduct = selectedProduct == null ||
                      selectedProduct!.isEmpty ||
                      stock.productID == selectedProduct;
                  return matchesSearch && matchesProduct;
                }).toList();

                return ListView.builder(
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    return FutureBuilder<Map<String, String>>(
                      future:
                          productService.fetchProductDetails(stock.productID),
                      builder: (context, productSnapshot) {
                        final productData = productSnapshot.data ?? {};
                        final productName = productData['name'] ??
                            translation.translate('unknown_product');
                        final unitType = productData['unitType'] ?? '';

                        return FutureBuilder<String>(
                          future: supplierService
                              .fetchSupplierName(stock.supplierID),
                          builder: (context, supplierSnapshot) {
                            final supplierName = supplierSnapshot.data != null
                                ? supplierSnapshot.data!
                                : translation.translate('unknown_supplier');
                            final stockQuantity =
                                stock.quantity > 0 ? stock.quantity : 0;

                            final stockDetails =
                                "${translation.translate('quantity')}: $stockQuantity ${translation.translate(unitType)}\n${translation.translate('supplier')}: $supplierName";
                            return ListTile(
                              leading: Icon(Icons.store),
                              title: Text(productName),
                              subtitle: Text(stockDetails),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _editStock(stock),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteStock(stock.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addStock,
      ),
    );
  }

  Future<void> _addStock() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockSetupScreen()),
    );
    if (result == true) setState(() {}); // Refresh if a stock entry was added
  }

  Future<void> _editStock(Stock stock) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StockSetupScreen(stock: stock)),
    );
    if (result == true) setState(() {}); // Refresh if a stock entry was updated
  }

  Future<void> _deleteStock(String stockId) async {
    await stockService.deleteStock(stockId);
    setState(() {}); // Refresh UI after deletion
  }
}

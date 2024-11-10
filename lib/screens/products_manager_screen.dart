import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crm_app/models/product.dart';
import 'package:crm_app/services/product_service.dart';
import 'package:crm_app/services/product_category_service.dart';
import 'package:crm_app/services/translation_service.dart';
import 'product_setup_screen.dart';

class ProductsManagerScreen extends StatefulWidget {
  @override
  _ProductsManagerScreenState createState() => _ProductsManagerScreenState();
}

class _ProductsManagerScreenState extends State<ProductsManagerScreen> {
  final ProductService productService = ProductService();
  final ProductCategoryService categoryService = ProductCategoryService();

  String searchQuery = '';
  String? selectedCategory;
  List<Map<String, String>> categories = []; // Stores category ID and name

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final fetchedCategories = await categoryService.fetchAllCategories();
    setState(() {
      categories = fetchedCategories
          .map((cat) => {'id': cat.id, 'name': cat.name})
          .toList();
      categories.insert(
          0, {'id': '', 'name': 'All Categories'}); // Add an "All" option
    });
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation.translate('products_manager')),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () => productService.syncProducts(),
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
                      labelText: translation.translate('search_by_name'),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: Text(translation.translate('filter_by_category')),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category['id'],
                      child: Text(category['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productService.getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading products'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No products available'));
                }

                final products = snapshot.data!.where((product) {
                  final matchesSearch =
                      product.name.toLowerCase().contains(searchQuery);
                  final matchesCategory = selectedCategory == null ||
                      selectedCategory!.isEmpty ||
                      product.categoryID == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return FutureBuilder<String>(
                      future:
                          categoryService.fetchCategoryName(product.categoryID),
                      builder: (context, categorySnapshot) {
                        final categoryName = categorySnapshot.data ?? 'Unknown';
                        final pricePerUnit =
                            "${translation.translate('price')}: ₪${product.price} ${translation.translate(product.typeOfUnit)}";

                        return ListTile(
                          leading: product.productImg != null &&
                                  product.productImg!.isNotEmpty
                              ? Image.file(
                                  File(product.productImg!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.shopping_bag,
                                  size: 50,
                                ),
                          title: Text(
                              "${product.name} , ${translation.translate('category')}: $categoryName"),
                          subtitle: Text(pricePerUnit),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editProduct(product),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteProduct(product.id),
                              ),
                            ],
                          ),
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
        onPressed: _addProduct,
      ),
    );
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductSetupScreen()),
    );
    if (result == true)
      setState(() {}); // Refresh the UI if a product was added
  }

  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductSetupScreen(product: product)),
    );
    if (result == true)
      setState(() {}); // Refresh the UI if a product was updated
  }

  Future<void> _deleteProduct(String productId) async {
    await productService.deleteProduct(productId);
    setState(() {}); // Refresh the UI after deletion
  }
}

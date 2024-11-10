import 'package:crm_app/services/datamanage/image_handling_service.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/models/product.dart';
import 'package:crm_app/services/product_service.dart';
import 'package:crm_app/services/product_category_service.dart';
import 'package:crm_app/services/translation_service.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductSetupScreen extends StatefulWidget {
  final Product? product;

  ProductSetupScreen({this.product});

  @override
  _ProductSetupScreenState createState() => _ProductSetupScreenState();
}

class _ProductSetupScreenState extends State<ProductSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService productService = ProductService();
  final ProductCategoryService categoryService = ProductCategoryService();
  final ImageHandlingService imageHandlingService = ImageHandlingService();

  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _selectedUnit;
  List<Map<String, String>> _categories = []; // Stores category ID and name
  String? _selectedCategoryId;
  File? _selectedImage;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchCategories();
    _imagePath = widget.product?.productImg;
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController =
        TextEditingController(text: widget.product?.barCode ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '0.0');
    _selectedUnit = widget.product?.typeOfUnit ?? 'unit'; // Default unit
    _selectedCategoryId = widget.product?.categoryID; // Use ID for uniqueness
  }

  Future<void> _fetchCategories() async {
    final categories = await categoryService.fetchAllCategories();
    setState(() {
      _categories =
          categories.map((cat) => {'id': cat.id, 'name': cat.name}).toList();

      // Ensure selectedCategoryId exists within the category list
      if (_categories
          .every((category) => category['id'] != _selectedCategoryId)) {
        _selectedCategoryId = null; // Reset if it doesn’t match any category ID
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      setState(() {
        _imagePath = null; // Reset to reflect new selection
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final productId = widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Save image if selected
      if (_selectedImage != null) {
        _imagePath = imageHandlingService.getAssetPath('Product', productId);
        await imageHandlingService.saveOrReplaceImage(
            _selectedImage!, 'Product', productId);
      }

      Product product = Product(
        id: productId,
        name: _nameController.text,
        barCode:
            _barcodeController.text.isNotEmpty ? _barcodeController.text : null,
        description: _descriptionController.text,
        price: price,
        typeOfUnit: _selectedUnit ?? 'unit',
        productImg: _imagePath,
        categoryID: _selectedCategoryId ?? '', // Save category ID
        lastModifiedAt: DateTime.now(),
      );

      if (widget.product == null) {
        await productService.addProduct(product);
      } else {
        await productService.updateProduct(product);
      }

      Navigator.pop(context, true);
    }
  }

  void _addNewCategory() async {
    String? newCategoryName = await _showAddCategoryDialog();
    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      bool exists =
          await categoryService.doesCategoryNameExist(newCategoryName);
      if (!exists) {
        await categoryService.addCategory(categoryName: newCategoryName);
        _fetchCategories(); // Refresh categories after adding
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Duplicate Category"),
              content: Text("A category with this name already exists."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<String?> _showAddCategoryDialog() {
    TextEditingController categoryController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New Category"),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(labelText: "Category Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, categoryController.text),
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null
            ? translation.translate('add_product')
            : translation.translate('edit_product')),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProduct,
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
                    labelText: translation.translate('product_name')),
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_product_name')
                    : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                          labelText: translation.translate('barcode')),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: translation.translate('description')),
              ),
              TextFormField(
                controller: _priceController,
                decoration:
                    InputDecoration(labelText: translation.translate('price')),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_price')
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                items: ['kilo', 'box', 'unit'].map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(translation.translate(unit)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedUnit = value),
                decoration: InputDecoration(
                    labelText: translation.translate('unit_type')),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                items: _categories.isEmpty
                    ? []
                    : _categories.map((category) {
                        return DropdownMenuItem(
                          value: category['id'],
                          child: Text(category['name']!),
                        );
                      }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategoryId = value),
                decoration: InputDecoration(
                  labelText: translation.translate('category_id'),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addNewCategory,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : imageHandlingService.buildImageWidget(
                          modelName: 'Product',
                          modelId: widget.product?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          width: 100,
                          height: 100,
                        ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text(translation.translate('select_image')),
                    onPressed: _pickImage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scanBarcode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    if (barcode != '-1') {
      setState(() {
        _barcodeController.text = barcode;
      });
    }
  }
}

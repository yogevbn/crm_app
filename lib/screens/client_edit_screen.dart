import 'package:flutter/material.dart';
import 'package:crm_app/models/Client.dart';
import 'package:crm_app/services/client_service.dart';
import 'package:crm_app/services/translation_service.dart';

class ClientEditScreen extends StatefulWidget {
  final Client? client;

  ClientEditScreen({this.client});

  @override
  _ClientEditScreenState createState() => _ClientEditScreenState();
}

class _ClientEditScreenState extends State<ClientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientService clientService = ClientService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dnController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.client?.name ?? '');
    _emailController = TextEditingController(text: widget.client?.email ?? '');
    _phoneController = TextEditingController(text: widget.client?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.client?.address ?? '');
    _dnController = TextEditingController(text: widget.client?.dn ?? '');
    _noteController = TextEditingController(text: widget.client?.note ?? '');
  }

  Future<void> _saveClient() async {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: widget.client?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        dn: _dnController.text,
        note: _noteController.text,
        lastModifiedAt: DateTime.now(),
      );

      if (widget.client == null) {
        await clientService.addClient(client);
      } else {
        await clientService.updateClient(client);
      }

      Navigator.pop(context, true); // Return to previous screen with success
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client == null
            ? translation.translate('add_client')
            : translation.translate('edit_client')),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveClient,
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
                decoration:
                    InputDecoration(labelText: translation.translate('name')),
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_client_name')
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration:
                    InputDecoration(labelText: translation.translate('email')),
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_email')
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration:
                    InputDecoration(labelText: translation.translate('phone')),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                    labelText: translation.translate('address')),
              ),
              TextFormField(
                controller: _dnController,
                decoration:
                    InputDecoration(labelText: translation.translate('dn')),
              ),
              TextFormField(
                controller: _noteController,
                decoration:
                    InputDecoration(labelText: translation.translate('note')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

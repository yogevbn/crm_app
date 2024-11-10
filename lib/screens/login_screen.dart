import 'package:flutter/material.dart';
import 'package:crm_app/services/business_config.dart';
import 'package:crm_app/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  bool _isEditMode = false; // New property to determine the mode
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _businessIDController = TextEditingController();
  final TextEditingController _licenseKeyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLicenseKeyVisible = false;
  bool _isLoading = true;
  bool _isLocked = true; // Track lock state for settings

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEditMode();
    });
    _loadBusinessConfig();
  }

  // Load business config info and license key if available
  Future<void> _loadBusinessConfig() async {
    final businessInfo = await BusinessConfig.getBusinessInfo();
    final licenseKey = await BusinessConfig.getLicenseKey();
    final prefs = await SharedPreferences.getInstance();
    final isLocked = prefs.getBool('isLocked') ?? true;

    setState(() {
      _businessNameController.text = businessInfo['businessName'] ?? '';
      _addressController.text = businessInfo['address'] ?? '';
      _phoneController.text = businessInfo['phone'] ?? '';
      _businessIDController.text = businessInfo['businessID'] ?? '';
      _licenseKeyController.text = licenseKey ?? '';
      _isLocked = (_phoneController.text.isNotEmpty &&
          _businessIDController.text.isNotEmpty &&
          isLocked); // Lock only if fields contain data and are marked as locked
      _isLoading = false;
    });
  }

  // Save business config info and license key
  Future<void> _saveBusinessConfig() async {
    await BusinessConfig.saveBusinessInfo(
      _businessNameController.text,
      _addressController.text,
      _phoneController.text,
      _businessIDController.text,
    );
    await BusinessConfig.saveLicenseKey(_licenseKeyController.text);

    // Navigate to the dashboard after saving
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  // Check if all fields are filled
  bool _areFieldsValid() {
    return _businessNameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _businessIDController.text.isNotEmpty &&
        _licenseKeyController.text.isNotEmpty;
  }

  // Toggle lock state and save it in SharedPreferences
  Future<void> _toggleLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocked = !_isLocked;
    });
    prefs.setBool('isLocked', _isLocked);
  }

  // Show password dialog
  Future<void> _showPasswordDialog() async {
    final translation = TranslationService.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_isLocked
              ? translation.translate('unlock_settings_title')
              : translation.translate('lock_settings_title')),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration:
                InputDecoration(labelText: translation.translate('password')),
          ),
          actions: [
            TextButton(
              child: Text(translation.translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(translation.translate('confirm')),
              onPressed: () {
                // Implement password check
                if (_passwordController.text == 'your_secure_password') {
                  _toggleLockState();
                  Navigator.of(context).pop();
                } else {
                  // Show error if password is incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(translation.translate('incorrect_password'))),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // New method to check if we are in edit mode
  void _checkEditMode() {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    if (args != null && args.containsKey('editMode')) {
      setState(() {
        _isEditMode = args['editMode'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call the new method to check for edit mode
    _checkEditMode();
    final translation = TranslationService.of(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      translation.translate('setup_business_config'),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(translation.translate('business_name'),
                        _businessNameController),
                    _buildTextField(
                        translation.translate('address'), _addressController),
                    _buildTextField(
                        translation.translate('phone'), _phoneController,
                        enabled: !_isLocked),
                    _buildTextField(translation.translate('business_id'),
                        _businessIDController,
                        enabled: !_isLocked),
                    _buildLicenseKeyField(translation),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _areFieldsValid() ? _saveBusinessConfig : null,
                      child: Text(_isEditMode
                          ? translation.translate('save_changes')
                          : translation.translate('save_and_proceed')),
                    ),
                    const SizedBox(height: 10),
                    if (_phoneController.text.isNotEmpty &&
                        _businessIDController.text.isNotEmpty)
                      ElevatedButton(
                        onPressed: _showPasswordDialog,
                        child: Text(_isLocked
                            ? translation.translate('unlock_settings')
                            : translation.translate('lock_settings')),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper to build text input fields with optional enabled flag
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // License key field with toggle visibility
  Widget _buildLicenseKeyField(TranslationService translation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: _licenseKeyController,
        obscureText: !_isLicenseKeyVisible,
        decoration: InputDecoration(
          labelText: translation.translate('license_key'),
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(
              _isLicenseKeyVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _isLicenseKeyVisible = !_isLicenseKeyVisible;
              });
            },
          ),
        ),
      ),
    );
  }
}

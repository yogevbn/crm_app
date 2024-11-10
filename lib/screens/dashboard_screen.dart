import 'package:flutter/material.dart';
import 'package:crm_app/services/business_config.dart';
import 'package:crm_app/services/translation_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _businessName = '';
  String _address = '';
  String _phone = '';
  int _licenseDaysLeft = 180;

  final List<Map<String, dynamic>> _dashboardItems = [
    {
      'icon': Icons.calendar_today,
      'label': 'meetings',
      'routeName': '/meetingManager'
    },
    {'icon': Icons.inventory, 'label': 'stock', 'routeName': '/stockManager'},
    {
      'icon': Icons.shopping_cart,
      'label': 'products',
      'routeName': '/productsManager'
    },
    {
      'icon': Icons.local_shipping,
      'label': 'suppliers',
      'routeName': '/supplierManager'
    },
    {'icon': Icons.person, 'label': 'clients', 'routeName': '/clientsManager'},
    {
      'icon': Icons.message,
      'label': 'promotions',
      'routeName': '/promoteManager'
    },
    {
      'icon': Icons.add_shopping_cart,
      'label': 'new_order_client',
      'routeName': '/newOrderClient'
    },
    {
      'icon': Icons.local_offer,
      'label': 'new_order_supplier',
      'routeName': '/newOrderSupplier'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);
    bool isHebrew = Localizations.localeOf(context).languageCode == 'he';

    return FutureBuilder<Map<String, dynamic>>(
      future: BusinessConfig.getBusinessInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading business info'));
        } else {
          final businessInfo = snapshot.data!;
          _businessName = businessInfo['businessName'] ?? 'Business Name';
          _address = businessInfo['address'] ?? 'Address not set';
          _phone = businessInfo['phone'] ?? 'Phone not set';

          return _buildDashboardScreen(context, translation, isHebrew);
        }
      },
    );
  }

  Widget _buildDashboardScreen(
      BuildContext context, TranslationService translation, bool isHebrew) {
    return Directionality(
      textDirection: isHebrew ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(translation.translate('dashboard')),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                            ? 3
                            : 2;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: _dashboardItems.length,
                      itemBuilder: (context, index) {
                        final item = _dashboardItems[index];
                        return _buildDashboardCard(
                          context,
                          icon: item['icon'] as IconData,
                          label: translation.translate(item['label']),
                          routeName: item['routeName'] as String,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            _buildBusinessInfoFooter(context, translation),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfoFooter(
      BuildContext context, TranslationService translation) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${translation.translate('business_name')}: $_businessName',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('${translation.translate('address')}: $_address'),
          Text('${translation.translate('phone')}: $_phone'),
          Text(
            '${translation.translate('license_time_left')}: $_licenseDaysLeft ${translation.translate('days')}',
            style: TextStyle(color: Colors.redAccent),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login',
                  arguments: {'editMode': true});
            },
            child: Text(translation.translate('edit_business_info')),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String routeName}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:crm_app/firebase_options.dart';
import 'package:crm_app/screens/client_manager_screen.dart';
import 'package:crm_app/screens/dashboard_screen.dart';
import 'package:crm_app/screens/login_screen.dart';
import 'package:crm_app/screens/meeting_manager_screen.dart';
import 'package:crm_app/screens/new_client_order_screen.dart';
import 'package:crm_app/screens/new_supplier_order_screen.dart';
import 'package:crm_app/screens/products_manager_screen.dart';
import 'package:crm_app/screens/splash_screen.dart';
import 'package:crm_app/screens/stock_manager_screen.dart';
import 'package:crm_app/screens/supplier_manager_screen.dart';
import 'package:crm_app/services/translation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with debug logging
    print("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully.");

    runApp(MyApp());
  } catch (e) {
    print("Error during Firebase initialization: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM System',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        TranslationService.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('he', ''),
      ],
      initialRoute: '/',
      routes: appRoutes,
    );
  }

  // Define your routes in a separate method or variable for better readability
  static final Map<String, WidgetBuilder> appRoutes = {
    '/': (context) => SplashScreen(),
    '/login': (context) => LoginScreen(),
    '/dashboard': (context) => DashboardScreen(),
    '/productsManager': (context) => ProductsManagerScreen(),
    '/stockManager': (context) => StockManagerScreen(),
    '/supplierManager': (context) => SupplierManagerScreen(),
    '/meetingManager': (context) => MeetingManagerScreen(),
    '/clientsManager': (context) => ClientManagerScreen(),
    '/newOrderClient': (context) => NewClientOrderScreen(),
    '/newOrderSupplier': (context) => NewSupplierOrderScreen()
    // Removed '/loginScreen' to avoid duplicate route pointing to the same screen
  };
}

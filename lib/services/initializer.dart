import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';
import 'package:crm_app/services/business_config.dart';

class Initializer {
  static Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");

    // Initialize SyncService (ensures sync_log table exists and syncs pending changes)
    await SyncService().initialize();

    // Check if Business Configurations are set
    bool isBusinessInfoSet = await BusinessConfig.isBusinessInfoSet();
    if (!isBusinessInfoSet) {
      // Handle missing business configuration, e.g., redirect to a setup screen
      print("Business info is not set. Prompt setup.");
    } else {
      // Load Business Information if already set
      await BusinessConfig.getBusinessInfo();
    }

    // Additional setup can be added here if needed
  }
}

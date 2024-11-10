import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class APIRequestService {
  static final CollectionReference apiRequestCollection =
      FirebaseFirestore.instance.collection('api_requests');

  static Future<Database> _getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'crm_database.db');

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE api_requests(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER,
            endpoint TEXT,
            request_count INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  // Save API request to SQLite
  static Future<void> saveRequestToLocalDB(String endpoint) async {
    final db = await _getDatabase();
    await db.insert('api_requests', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'endpoint': endpoint,
      'request_count': 1,
    });
  }

  // Get the total number of API requests made locally
  static Future<int> getLocalRequestCount() async {
    final db = await _getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) FROM api_requests');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Save API request to Firebase
  static Future<void> saveRequestToFirebase(String endpoint) async {
    await apiRequestCollection.add({
      'timestamp': Timestamp.now(),
      'endpoint': endpoint,
      'request_count': 1,
    });
  }

  // Get the total number of API requests made in Firebase
  static Future<int> getFirebaseRequestCount() async {
    final querySnapshot = await apiRequestCollection.get();
    return querySnapshot.size;
  }

  // Combined function to save API request both locally and in Firebase
  static Future<void> saveAPIRequest(String endpoint) async {
    await saveRequestToLocalDB(endpoint);
    await saveRequestToFirebase(endpoint);
  }

  // Check if API request limit is reached based on a limit parameter
  static Future<bool> isLimitReached(int limit) async {
    final localCount = await getLocalRequestCount();
    final firebaseCount = await getFirebaseRequestCount();
    final totalCount = localCount + firebaseCount;

    return totalCount >= limit;
  }

  // Display API request information
  static Future<Map<String, int>> getRequestInfo() async {
    final localCount = await getLocalRequestCount();
    final firebaseCount = await getFirebaseRequestCount();

    return {
      'local': localCount,
      'firebase': firebaseCount,
      'total': localCount + firebaseCount,
    };
  }
}

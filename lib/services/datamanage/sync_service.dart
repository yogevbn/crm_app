import 'package:crm_app/models/baseModel.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class SyncService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  static const String _lastSyncTimeKey = 'lastSyncTime';

  Future<void> initialize() async {
    await sqliteService.initializeDatabase();
  }

  // Sync data from Firebase to SQLite
  Future<void> syncFromFirebase<T extends BaseModel>(
    T model, {
    required T Function(Map<String, dynamic>) fromMap,
    DateTime? lastSyncTime,
  }) async {
    List<Map<String, dynamic>> firebaseRecords = lastSyncTime != null
        ? await firebaseService.fetchSince(model, lastSyncTime)
        : await firebaseService.fetchAll(model);

    for (var firebaseRecord in firebaseRecords) {
      String recordID = firebaseRecord['id'];
      var localRecord = await sqliteService.fetchById(model, recordID);

      DateTime firebaseLastModified =
          DateTime.parse(firebaseRecord['lastModifiedAt']);
      DateTime? localLastModified = localRecord != null
          ? DateTime.parse(localRecord['data']['lastModifiedAt'])
          : null;

      if (localRecord == null) {
        // Insert if not present locally
        await sqliteService.insert(fromMap(firebaseRecord));
      } else if (localLastModified == null ||
          firebaseLastModified.isAfter(localLastModified)) {
        // Update if Firebase data is newer
        await sqliteService.update(fromMap(firebaseRecord), recordID);
      }
    }
  }

  // Sync changes from SQLite to Firebase
  Future<void> syncToFirebase<T extends BaseModel>(
    T model, {
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    List<Map<String, dynamic>> changeLog =
        await sqliteService.fetchSyncLog(model);

    for (var logEntry in changeLog) {
      String recordID = logEntry['recordID'];
      String operation = logEntry['operation'];

      if (operation == 'insert' || operation == 'update') {
        var localRecord = await sqliteService.fetchById(model, recordID);
        if (localRecord != null) {
          await firebaseService.insert(fromMap(localRecord));
        }
      } else if (operation == 'delete') {
        await firebaseService.delete(model, recordID);
      }
    }

    await sqliteService.clearSyncLog(model);
  }

  // Two-way sync
  Future<void> sync<T extends BaseModel>(
    T model, {
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    DateTime lastSyncTime = await getLastSyncTime();
    await syncFromFirebase(model, fromMap: fromMap, lastSyncTime: lastSyncTime);
    await syncToFirebase(model, fromMap: fromMap);
    await setLastSyncTime(DateTime.now());
  }

  // Retrieve last sync time
  Future<DateTime> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString(_lastSyncTimeKey);
    return lastSyncString != null
        ? DateTime.parse(lastSyncString)
        : DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Store the last sync time
  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncTimeKey, time.toIso8601String());
  }
}

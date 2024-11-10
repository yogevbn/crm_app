import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crm_app/models/baseModel.dart';
import 'package:crm_app/services/business_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLiteService {
  Database? _database;
  final Map<String, StreamController<List<Map<String, dynamic>>>>
      _tableControllers = {};

  Future<void> initializeDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database ??= await _openDatabase();

    // Ensure sync_log table exists
    await _createSyncLogTable();
  }

  Future<Database> _openDatabase() async {
    Directory appDirectory;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      appDirectory = Directory.current;
    } else {
      appDirectory = await getApplicationDocumentsDirectory();
    }

    final businessInfo = await BusinessConfig.getBusinessInfo();
    final String businessName =
        businessInfo['businessName'] ?? 'defaultBusiness';
    String path = join(appDirectory.path, '$businessName' '_crm_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createSyncLogTable(db);
      },
    );
  }

  // Generic query method to execute any SQL query
  Future<List<Map<String, dynamic>>> query(String sql,
      [List<dynamic>? arguments]) async {
    await initializeDatabase();
    return await _database!.rawQuery(sql, arguments);
  }

  Future<void> _createSyncLogTable([Database? db]) async {
    final database = db ?? _database!;
    try {
      await database.execute('''
        CREATE TABLE IF NOT EXISTS sync_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recordID TEXT NOT NULL,
          modelName TEXT NOT NULL,
          operation TEXT NOT NULL,
          lastModifiedAt TEXT NOT NULL
        )
      ''');
    } catch (e) {
      print('Error creating sync_log table: $e');
      throw Exception('Failed to create sync_log table');
    }
  }

  Future<void> createTableForModel(BaseModel model) async {
    await initializeDatabase();
    final fields = model.toMap();
    final columns = fields.keys
        .where((key) => key != 'id')
        .map((key) => '$key ${_getSqlType(fields[key])}')
        .join(', ');

    final sql = '''
      CREATE TABLE IF NOT EXISTS ${model.getModelName()} (
        id TEXT PRIMARY KEY,
        $columns
      )
    ''';

    await _database!.execute(sql);
  }

  String _getSqlType(dynamic value) {
    if (value is int) return 'INTEGER';
    if (value is double) return 'REAL';
    if (value is bool) return 'INTEGER';
    return 'TEXT';
  }

  Future<void> insert(BaseModel model) async {
    await createTableForModel(model);
    await _database!.insert(model.getModelName(), model.toMap());
    await _logChange(model, model.id, 'insert');
    _notifyTableChanged(model.getModelName());
  }

  Future<void> update(BaseModel model, String id) async {
    await createTableForModel(model);
    await _database!.update(
      model.getModelName(),
      model.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await _logChange(model, id, 'update');
    _notifyTableChanged(model.getModelName());
  }

  Future<void> delete(BaseModel model, String id) async {
    await createTableForModel(model);
    await _database!.delete(
      model.getModelName(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await _logChange(model, id, 'delete');
    _notifyTableChanged(model.getModelName());
  }

  Future<List<Map<String, dynamic>>> fetchAll(BaseModel model) async {
    await createTableForModel(model);
    return await _database!.query(model.getModelName());
  }

  Future<Map<String, dynamic>?> fetchById(BaseModel model, String id) async {
    await createTableForModel(model);
    final result = await _database!.query(
      model.getModelName(),
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> fetchSyncLog(BaseModel model) async {
    await initializeDatabase();
    return await _database!.query(
      'sync_log',
      where: 'modelName = ?',
      whereArgs: [model.getModelName()],
    );
  }

  Future<void> clearSyncLog(BaseModel model) async {
    await initializeDatabase();
    await _database!.delete(
      'sync_log',
      where: 'modelName = ?',
      whereArgs: [model.getModelName()],
    );
  }

  Future<void> _logChange(
      BaseModel model, String recordID, String operation) async {
    await initializeDatabase();
    final lastModifiedAt = DateTime.now().toIso8601String();
    await _database!.insert('sync_log', {
      'recordID': recordID,
      'modelName': model.getModelName(),
      'operation': operation,
      'lastModifiedAt': lastModifiedAt,
    });
  }

  // Watch table changes for real-time updates
  Stream<List<Map<String, dynamic>>> watchTable(BaseModel model) {
    final modelName = model.getModelName();
    _tableControllers.putIfAbsent(modelName,
        () => StreamController<List<Map<String, dynamic>>>.broadcast());

    _tableControllers[modelName]!.onListen = () async {
      final data = await fetchAll(model);
      _tableControllers[modelName]!.add(data);
    };

    return _tableControllers[modelName]!.stream;
  }

  void _notifyTableChanged(String tableName) async {
    if (_tableControllers.containsKey(tableName)) {
      final data = await _database!.query(tableName);
      _tableControllers[tableName]!.add(data);
    }
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _tableControllers.forEach((_, controller) => controller.close());
    _tableControllers.clear();
  }
}

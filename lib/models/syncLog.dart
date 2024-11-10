import 'package:crm_app/models/baseModel.dart';

class SyncLog implements BaseModel {
  @override
  final String id; // Private field for id with String type
  final String recordID;
  final String modelName;
  final String operation; // insert, update, delete
  final DateTime lastModifiedAt;

  // Constructor with optional id parameter
  SyncLog({
    required this.id,
    required this.recordID,
    required this.modelName,
    required this.operation,
    required this.lastModifiedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recordID': recordID,
      'modelName': modelName,
      'operation': operation,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  @override
  BaseModel fromMap(Map<String, dynamic> map) {
    return SyncLog(
      id: map['id'],
      recordID: map['recordID'],
      modelName: map['modelName'],
      operation: map['operation'],
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
    );
  }

  @override
  String getModelName() => 'sync_log';
}

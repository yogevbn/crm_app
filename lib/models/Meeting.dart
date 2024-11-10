import 'package:crm_app/models/baseModel.dart';

class Meeting implements BaseModel {
  @override
  final String id;
  final String title;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final String? clientID;
  final String? supplierID;
  final List<String>? attendees;
  final List<String>? documents;
  final String? location;
  final String status; // 'scheduled', 'completed', or 'canceled'
  final String? notes;
  final DateTime lastModifiedAt;

  Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    this.clientID,
    this.supplierID,
    this.attendees,
    this.documents,
    this.location,
    this.status = 'scheduled',
    this.notes,
    required this.lastModifiedAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'description': description,
      'clientID': clientID,
      'supplierID': supplierID,
      'attendees': attendees,
      'documents': documents,
      'location': location,
      'status': status,
      'notes': notes,
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
    };
  }

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      description: map['description'],
      clientID: map['clientID'],
      supplierID: map['supplierID'],
      attendees:
          map['attendees'] != null ? List<String>.from(map['attendees']) : null,
      documents:
          map['documents'] != null ? List<String>.from(map['documents']) : null,
      location: map['location'],
      status: map['status'] ?? 'scheduled',
      notes: map['notes'],
      lastModifiedAt: DateTime.parse(map['lastModifiedAt']),
    );
  }

  @override
  String getModelName() {
    return 'Meetings';
  }
}

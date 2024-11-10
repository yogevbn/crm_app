import 'dart:async';
import 'package:crm_app/models/Meeting.dart';
import 'package:crm_app/services/datamanage/firebase_service.dart';
import 'package:crm_app/services/datamanage/sqllite_service.dart';
import 'package:crm_app/services/datamanage/sync_service.dart';

class MeetingService {
  final FirebaseService firebaseService = FirebaseService();
  final SQLiteService sqliteService = SQLiteService();
  final SyncService syncService = SyncService();

  MeetingService() {
    syncService.initialize();
  }

  Meeting _tempMeeting() {
    return Meeting(
      id: '',
      title: '',
      date: DateTime.now(),
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: 1)),
      description: '',
      lastModifiedAt: DateTime.now(),
    );
  }

  Future<void> syncMeetings() async {
    await syncService.sync(
      _tempMeeting(),
      fromMap: (data) => Meeting.fromMap(data),
    );
  }

  Future<void> addMeeting(Meeting meeting) async {
    await sqliteService.insert(meeting);
    await firebaseService.insert(meeting);
  }

  Future<void> updateMeeting(Meeting meeting) async {
    await sqliteService.update(meeting, meeting.id);
    await firebaseService.update(meeting, meeting.id);
  }

  Future<void> deleteMeeting(String meetingId) async {
    await sqliteService.delete(_tempMeeting(), meetingId);
    await firebaseService.delete(_tempMeeting(), meetingId);
  }

  Future<List<Meeting>> fetchAllMeetings() async {
    List<Map<String, dynamic>> data =
        await sqliteService.fetchAll(_tempMeeting());
    return data.map((item) => Meeting.fromMap(item)).toList();
  }

  Stream<List<Meeting>> getMeetingsStream() {
    return sqliteService.watchTable(_tempMeeting()).map(
          (data) => data.map((item) => Meeting.fromMap(item)).toList(),
        );
  }
}

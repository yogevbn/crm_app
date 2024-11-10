import 'package:crm_app/models/Meeting.dart';
import 'package:crm_app/services/meeting_service.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/services/translation_service.dart';
import 'meeting_setup_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class MeetingManagerScreen extends StatefulWidget {
  @override
  _MeetingManagerScreenState createState() => _MeetingManagerScreenState();
}

class _MeetingManagerScreenState extends State<MeetingManagerScreen> {
  final MeetingService meetingService = MeetingService();
  DateTime selectedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Meeting>> meetings = {}; // Map to store meetings by date

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    final allMeetings = await meetingService.fetchAllMeetings();
    setState(() {
      meetings = {};
      for (var meeting in allMeetings) {
        // Normalize date to ignore time
        final date =
            DateTime(meeting.date.year, meeting.date.month, meeting.date.day);
        if (meetings[date] == null) {
          meetings[date] = [];
        }
        meetings[date]!.add(meeting);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(translation.translate('meeting_manager')),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              await meetingService.syncMeetings();
              _loadMeetings(); // Reload meetings after sync
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: translation.locale.languageCode,
            focusedDay: selectedDate,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.twoWeeks: '2 Weeks',
              CalendarFormat.month: 'Month',
            },
            onFormatChanged: (format) {
              setState(() {
                calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
            },
            eventLoader: (date) {
              final normalizedDate = DateTime(date.year, date.month, date.day);
              return meetings[normalizedDate] ?? [];
            },
            calendarBuilders: CalendarBuilders(
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange, // Orange circle around selected day
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _buildMeetingListForSelectedDate(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addMeeting,
      ),
    );
  }

  Widget _buildMeetingListForSelectedDate() {
    final translation = TranslationService.of(context);

    // Normalize selectedDate to ignore time
    final normalizedSelectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final dailyMeetings = meetings[normalizedSelectedDate] ?? [];

    if (dailyMeetings.isEmpty) {
      return Center(
        child: Text(translation
            .translate('no_meetings_for_selected_date')), // No meetings message
      );
    }

    return ListView.builder(
      itemCount: dailyMeetings.length,
      itemBuilder: (context, index) {
        final meeting = dailyMeetings[index];
        return ListTile(
          title: Text(meeting.title),
          subtitle: Text(
            "${translation.translate('description')}: ${meeting.description}\n"
            "${translation.translate('date')}: ${meeting.date}\n"
            "${translation.translate('time')}: ${meeting.startTime} - ${meeting.endTime}",
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editMeeting(meeting),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteMeeting(meeting.id),
              ),
            ],
          ),
          onTap: () => _viewMeetingDetails(meeting),
        );
      },
    );
  }

  Future<void> _addMeeting() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MeetingSetupScreen(date: selectedDate)),
    );
    if (result == true) {
      _loadMeetings(); // Reload meetings after adding
    }
  }

  Future<void> _editMeeting(Meeting meeting) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingSetupScreen(
          meeting: meeting,
          date: meeting.date, // Pass the date of the meeting
        ),
      ),
    );
    if (result == true) {
      _loadMeetings(); // Reload meetings after editing
    }
  }

  Future<void> _deleteMeeting(String meetingId) async {
    await meetingService.deleteMeeting(meetingId);
    _loadMeetings(); // Reload meetings after deletion
  }

  void _viewMeetingDetails(Meeting meeting) {
    final translation = TranslationService.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(meeting.title),
        content: Text(
          "${translation.translate('description')}: ${meeting.description}\n"
          "${translation.translate('date')}: ${meeting.date}\n"
          "${translation.translate('time')}: ${meeting.startTime} - ${meeting.endTime}",
        ),
        actions: [
          TextButton(
            child: Text(translation.translate('close')),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

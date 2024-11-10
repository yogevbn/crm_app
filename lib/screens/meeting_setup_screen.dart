import 'package:crm_app/models/Meeting.dart';
import 'package:flutter/material.dart';
import 'package:crm_app/services/meeting_service.dart';
import 'package:crm_app/services/translation_service.dart';

class MeetingSetupScreen extends StatefulWidget {
  final Meeting? meeting;
  final DateTime date;

  MeetingSetupScreen({this.meeting, required this.date});

  @override
  _MeetingSetupScreenState createState() => _MeetingSetupScreenState();
}

class _MeetingSetupScreenState extends State<MeetingSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final MeetingService meetingService = MeetingService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime selectedDate;
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  Duration meetingDuration = Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    selectedDate = widget.date;
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.meeting?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.meeting?.description ?? '');
    _locationController =
        TextEditingController(text: widget.meeting?.location ?? '');

    if (widget.meeting != null) {
      selectedDate = widget.meeting!.date;
      startTime = TimeOfDay.fromDateTime(widget.meeting!.startTime);
      endTime = TimeOfDay.fromDateTime(widget.meeting!.endTime);
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickStartTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (pickedTime != null) {
      setState(() {
        startTime = pickedTime;
        endTime = _calculateEndTime(startTime, meetingDuration);
      });
    }
  }

  Future<void> _pickEndTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: endTime,
    );
    if (pickedTime != null) {
      setState(() {
        endTime = pickedTime;
      });
    }
  }

  TimeOfDay _calculateEndTime(TimeOfDay start, Duration duration) {
    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      start.hour,
      start.minute,
    ).add(duration);
    return TimeOfDay.fromDateTime(endDateTime);
  }

  Future<void> _saveMeeting() async {
    if (_formKey.currentState!.validate()) {
      final startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      final endDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );

      final meeting = Meeting(
        id: widget.meeting?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        date: selectedDate,
        startTime: startDateTime,
        endTime: endDateTime,
        description: _descriptionController.text,
        location: _locationController.text,
        lastModifiedAt: DateTime.now(),
      );

      if (widget.meeting == null) {
        await meetingService.addMeeting(meeting);
      } else {
        await meetingService.updateMeeting(meeting);
      }

      Navigator.pop(context, true); // Return to previous screen with success
    }
  }

  @override
  Widget build(BuildContext context) {
    final translation = TranslationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting == null
            ? translation.translate('add_meeting')
            : translation.translate('edit_meeting')),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveMeeting,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration:
                    InputDecoration(labelText: translation.translate('title')),
                validator: (value) => value!.isEmpty
                    ? translation.translate('enter_title')
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    labelText: translation.translate('description')),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                    labelText: translation.translate('location')),
              ),
              SizedBox(height: 16),
              Text(translation.translate('selected_date')),
              ListTile(
                title: Text("${selectedDate.toLocal()}".split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 16),
              Text(translation.translate('start_time')),
              ListTile(
                title: Text(startTime.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: _pickStartTime,
              ),
              SizedBox(height: 16),
              Text(translation.translate('end_time')),
              ListTile(
                title: Text(endTime.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: _pickEndTime,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<Duration>(
                value: meetingDuration,
                onChanged: (Duration? newDuration) {
                  setState(() {
                    meetingDuration = newDuration!;
                    endTime = _calculateEndTime(startTime, meetingDuration);
                  });
                },
                decoration: InputDecoration(
                    labelText: translation.translate('duration')),
                items: [
                  DropdownMenuItem(
                    child: Text('30 minutes'),
                    value: Duration(minutes: 30),
                  ),
                  DropdownMenuItem(
                    child: Text('1 hour'),
                    value: Duration(hours: 1),
                  ),
                  DropdownMenuItem(
                    child: Text('1.5 hours'),
                    value: Duration(hours: 1, minutes: 30),
                  ),
                  DropdownMenuItem(
                    child: Text('2 hours'),
                    value: Duration(hours: 2),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

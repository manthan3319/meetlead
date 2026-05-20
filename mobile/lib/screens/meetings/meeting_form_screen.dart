import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/meeting_model.dart';
import '../../services/meeting_service.dart';
import '../../services/notification_service.dart';

class MeetingFormScreen extends StatefulWidget {
  final MeetingModel? existing;
  const MeetingFormScreen({super.key, this.existing});
  @override
  State<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends State<MeetingFormScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _title, _description, _link, _location, _notes;
  String _type = 'online';
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  int _duration = 30;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _link = TextEditingController(text: e?.meetingLink ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    if (e != null) {
      _type = e.type;
      _scheduledAt = e.scheduledAt;
      _duration = e.durationMinutes;
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context, firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: _scheduledAt,
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_scheduledAt));
    if (time == null) return;
    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final body = {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'type': _type,
        'meetingLink': _link.text.trim(),
        'location': _location.text.trim(),
        'scheduledAt': _scheduledAt.toUtc().toIso8601String(),
        'durationMinutes': _duration,
        'notes': _notes.text.trim(),
      };
      MeetingModel saved;
      if (widget.existing != null) {
        saved = await MeetingService().update(widget.existing!.id, body);
      } else {
        saved = await MeetingService().create(body);
      }

      final reminders = [
        {'before': 60, 'alarm': false},
        {'before': 15, 'alarm': false},
        {'before': 0, 'alarm': true},
      ];
      for (final r in reminders) {
        final at = saved.scheduledAt.subtract(Duration(minutes: r['before'] as int));
        if (at.isAfter(DateTime.now())) {
          await NotificationService.scheduleMeetingReminder(
            id: '${saved.id.hashCode}${r['before']}'.hashCode,
            title: saved.title,
            body: r['before'] == 0 ? 'Meeting time now!' : 'Starts in ${r['before']} min',
            at: at,
            alarm: r['alarm'] as bool,
          );
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM y · h:mm a');
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(title: Text(widget.existing == null ? 'New Meeting' : 'Edit Meeting')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('Title *'),
            TextFormField(controller: _title, decoration: const InputDecoration(hintText: 'Meeting title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            _label('Type'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'online', label: Text('Online'), icon: Icon(Icons.videocam)),
                ButtonSegment(value: 'offline', label: Text('Offline'), icon: Icon(Icons.place)),
                ButtonSegment(value: 'call', label: Text('Call'), icon: Icon(Icons.phone)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            if (_type == 'online') ...[
              _label('Meeting Link'),
              TextFormField(controller: _link, decoration: const InputDecoration(hintText: 'https://meet.google.com/...')),
            ] else if (_type == 'offline') ...[
              _label('Location'),
              TextFormField(controller: _location, decoration: const InputDecoration(hintText: 'Office address')),
            ],
            _label('Description'),
            TextFormField(controller: _description, maxLines: 2),
            _label('When'),
            InkWell(
              onTap: _pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.fildbg, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.event, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(fmt.format(_scheduledAt), style: const TextStyle(fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
            _label('Duration (minutes)'),
            DropdownButtonFormField<int>(
              value: _duration,
              items: [15, 30, 45, 60, 90, 120].map((d) => DropdownMenuItem(value: d, child: Text('$d min'))).toList(),
              onChanged: (v) => setState(() => _duration = v!),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Icon(Icons.alarm, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Auto-alarm 1hr before, 15min before, and at meeting time.',
                  style: TextStyle(fontSize: 12))),
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save Meeting')),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.fromLTRB(2, 12, 0, 6),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)));
}

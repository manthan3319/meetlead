// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/theme.dart';
import '../../models/meeting_model.dart';
import '../../services/meeting_service.dart';
import 'meeting_form_screen.dart';
import 'meeting_detail_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});
  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  Map<DateTime, List<MeetingModel>> _byDay = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final from = DateTime(_focused.year, _focused.month, 1);
      final to = DateTime(_focused.year, _focused.month + 1, 0, 23, 59);
      final list = await MeetingService().list(from: from, to: to);
      _byDay.clear();
      for (final m in list) {
        final key = DateTime(m.scheduledAt.year, m.scheduledAt.month, m.scheduledAt.day);
        _byDay.putIfAbsent(key, () => []).add(m);
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<MeetingModel> _eventsFor(DateTime d) =>
    _byDay[DateTime(d.year, d.month, d.day)] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(
        title: const Text('Meetings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const MeetingFormScreen()));
              _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: _focused,
              selectedDayPredicate: (d) => isSameDay(d, _selected),
              onDaySelected: (sel, foc) => setState(() { _selected = sel; _focused = foc; }),
              onPageChanged: (foc) { _focused = foc; _load(); },
              eventLoader: _eventsFor,
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(color: AppColors.light, shape: BoxShape.circle),
                todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: AppColors.teal700, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildList(_eventsFor(_selected)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<MeetingModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No meetings on this day', style: TextStyle(color: AppColors.textgrey)));
    }
    final fmt = DateFormat('h:mm a');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Container(
                width: 48, padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Text(fmt.format(m.scheduledAt).split(' ')[0],
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(fmt.format(m.scheduledAt).split(' ')[1],
                    style: const TextStyle(color: AppColors.primary, fontSize: 10)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (m.leadInfo != null)
                      Text('with ${m.leadInfo!['name']}', style: const TextStyle(color: AppColors.textgrey, fontSize: 12)),
                    Text('${m.type} • ${m.durationMinutes} min',
                      style: const TextStyle(color: AppColors.textgrey, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColors.textgrey),
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => MeetingDetailScreen(meeting: m)));
                  _load();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

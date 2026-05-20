import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/meeting_model.dart';
import '../../services/meeting_service.dart';
import 'meeting_form_screen.dart';

class MeetingDetailScreen extends StatefulWidget {
  final MeetingModel meeting;
  const MeetingDetailScreen({super.key, required this.meeting});
  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  late MeetingModel _m;
  late TextEditingController _notes;
  late TextEditingController _outcome;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _m = widget.meeting;
    _notes = TextEditingController(text: _m.notes ?? '');
    _outcome = TextEditingController(text: _m.outcome ?? '');
  }

  Future<void> _setStatus(String status, {String? notes, String? outcome}) async {
    setState(() => _busy = true);
    try {
      final updated = status == 'completed'
          ? await MeetingService().addNote(_m.id, notes: notes, outcome: outcome, status: status)
          : await MeetingService().update(_m.id, {'status': status});
      setState(() => _m = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status: ${status.toUpperCase()}'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveNotes() async {
    if (_notes.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final updated = await MeetingService().addNote(_m.id, notes: _notes.text.trim(), status: _m.status);
      setState(() => _m = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes saved'), backgroundColor: AppColors.primary),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLink() async {
    if (_m.meetingLink == null || _m.meetingLink!.isEmpty) return;
    final url = Uri.parse(_m.meetingLink!);
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _callLead() async {
    final phone = _m.leadInfo?['phone'];
    if (phone == null) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _whatsappLead() async {
    final phone = (_m.leadInfo?['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return;
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMM y · h:mm a');
    final isUpcoming = _m.status == 'scheduled' && _m.scheduledAt.isAfter(DateTime.now());
    final isInProgress = _m.status == 'in-progress';
    final isCompleted = _m.status == 'completed';

    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(
        title: const Text('Meeting Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MeetingFormScreen(existing: _m)));
              if (result == true && mounted) Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _statusBanner(),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_m.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if ((_m.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(_m.description!, style: const TextStyle(color: AppColors.textgrey)),
                ],
                const Divider(height: 24),
                _infoRow(Icons.event, 'When', fmt.format(_m.scheduledAt)),
                _infoRow(Icons.timer, 'Duration', '${_m.durationMinutes} minutes'),
                _infoRow(_m.type == 'online' ? Icons.videocam : _m.type == 'call' ? Icons.phone : Icons.place, 'Type', _m.type),
                if (_m.type == 'online' && (_m.meetingLink ?? '').isNotEmpty)
                  _linkRow(Icons.link, 'Link', _m.meetingLink!, _openLink),
                if (_m.type == 'offline' && (_m.location ?? '').isNotEmpty)
                  _infoRow(Icons.place_outlined, 'Location', _m.location!),
              ],
            ),
          ),

          if (_m.leadInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.light,
                    child: Text((_m.leadInfo!['name'] ?? '?').toString()[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_m.leadInfo!['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (_m.leadInfo!['phone'] != null)
                          Text(_m.leadInfo!['phone'], style: const TextStyle(color: AppColors.textgrey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: _whatsappLead, icon: const Icon(Icons.chat, color: Color(0xFF25D366))),
                  IconButton(onPressed: _callLead, icon: const Icon(Icons.call, color: AppColors.primary)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notes, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text('Meeting Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (!isCompleted)
                      TextButton.icon(
                        onPressed: _busy ? null : _saveNotes,
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Save'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notes,
                  maxLines: 6,
                  readOnly: isCompleted,
                  decoration: InputDecoration(
                    hintText: isInProgress
                      ? 'Type during the meeting...\n• Kya discuss hua?\n• Client requirement?\n• Next step?'
                      : 'Add notes here',
                  ),
                ),
                if (isInProgress || isCompleted) ...[
                  const SizedBox(height: 12),
                  const Text('Outcome', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _outcome,
                    readOnly: isCompleted,
                    decoration: const InputDecoration(hintText: 'e.g. Interested — send proposal'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _actionButton(isUpcoming, isInProgress, isCompleted),
        ),
      ),
    );
  }

  Widget _statusBanner() {
    final colors = {
      'scheduled': [AppColors.light, AppColors.primary, 'SCHEDULED'],
      'in-progress': [Colors.orange.shade50, Colors.orange.shade700, 'IN PROGRESS'],
      'completed': [Colors.green.shade50, Colors.green.shade700, 'COMPLETED'],
      'cancelled': [AppColors.red.withOpacity(0.1), AppColors.red, 'CANCELLED'],
      'no-show': [Colors.grey.shade200, Colors.grey.shade700, 'NO SHOW'],
    };
    final c = colors[_m.status] ?? colors['scheduled']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: c[0] as Color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: c[1] as Color),
          const SizedBox(width: 8),
          Text(c[2] as String, style: TextStyle(color: c[1] as Color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textgrey),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textgrey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _linkRow(IconData icon, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textgrey),
          const SizedBox(width: 10),
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textgrey, fontSize: 13))),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(value, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(bool isUpcoming, bool isInProgress, bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text('Meeting completed', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }
    if (isInProgress) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _busy ? null : () => _setStatus('completed', notes: _notes.text.trim(), outcome: _outcome.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              icon: const Icon(Icons.check),
              label: const Text('Complete Meeting'),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _busy ? null : () => _setStatus('cancelled'),
            icon: const Icon(Icons.cancel_outlined, color: AppColors.red),
            label: const Text('Cancel', style: TextStyle(color: AppColors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.red)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : () => _setStatus('in-progress'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Meeting'),
          ),
        ),
      ],
    );
  }
}

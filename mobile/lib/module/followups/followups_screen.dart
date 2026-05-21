// ignore_for_file: unnecessary_brace_in_string_interps, deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/followup_service.dart';
import '../../services/lead_service.dart';

class FollowupsScreen extends StatefulWidget {
  const FollowupsScreen({super.key});
  @override
  State<FollowupsScreen> createState() => _FollowupsScreenState();
}

class _FollowupsScreenState extends State<FollowupsScreen> {
  String _filter = 'today';
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      if (_filter == 'today') {
        _items = await FollowupService().today();
      } else if (_filter == 'pending') {
        _items = await FollowupService().list(status: 'pending');
      } else {
        _items = await FollowupService().list(status: 'done');
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _complete(dynamic item) async {
    final outcome = await _askOutcome();
    if (outcome == null) return;
    try {
      await FollowupService().complete(item['_id'], outcome: outcome);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow-up completed ✓'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<String?> _askOutcome() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Done'),
        content: TextField(
          controller: ctrl, maxLines: 3,
          decoration: const InputDecoration(hintText: 'Outcome (e.g. Connected, will close next week)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Done')),
        ],
      ),
    );
  }

  Future<void> _action(dynamic item) async {
    final lead = item['leadId'];
    if (lead == null) return;
    final phone = (lead['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return;
    final type = item['type'];
    Uri url;
    if (type == 'whatsapp') {
      url = Uri.parse('https://wa.me/$phone');
    } else if (type == 'call') {
      url = Uri.parse('tel:$phone');
    } else {
      url = Uri.parse('tel:$phone');
    }
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _addNew() async {
    final leads = await LeadService().list();
    if (!mounted || leads.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a lead first')),
      );
      return;
    }
    String selectedLead = leads.first.id;
    String type = 'call';
    DateTime scheduledAt = DateTime.now().add(const Duration(hours: 1));
    final noteCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('New Follow-up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Lead', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedLead,
                  items: leads.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))).toList(),
                  onChanged: (v) => setS(() => selectedLead = v!),
                ),
                const SizedBox(height: 12),
                const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'call', label: Text('Call'), icon: Icon(Icons.phone)),
                    ButtonSegment(value: 'whatsapp', label: Text('WA'), icon: Icon(Icons.chat)),
                    ButtonSegment(value: 'meeting', label: Text('Meet'), icon: Icon(Icons.event)),
                    ButtonSegment(value: 'visit', label: Text('Visit'), icon: Icon(Icons.place)),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setS(() => type = s.first),
                ),
                const SizedBox(height: 12),
                const Text('When', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: scheduledAt);
                    if (d == null || !ctx.mounted) return;
                    final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(scheduledAt));
                    if (t == null) return;
                    setS(() => scheduledAt = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.fildbg, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.event, color: AppColors.primary), const SizedBox(width: 8),
                      Text(DateFormat('d MMM, h:mm a').format(scheduledAt)),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: noteCtrl, decoration: const InputDecoration(hintText: 'Note (optional)')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FollowupService().create({
                        'leadId': selectedLead,
                        'type': type,
                        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
                        'note': noteCtrl.text.trim(),
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      _load();
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  },
                  child: const Text('Schedule Follow-up'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(
        title: const Text('Follow-ups'),
        actions: [IconButton(icon: const Icon(Icons.add, color: AppColors.primary), onPressed: _addNew)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'today', label: Text('Today')),
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'done', label: Text('Done')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) { setState(() => _filter = s.first); _load(); },
            ),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flag_outlined, size: 60, color: AppColors.textgrey),
                      const SizedBox(height: 12),
                      Text('No ${_filter} follow-ups', style: const TextStyle(color: AppColors.textgrey)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(onPressed: _addNew, icon: const Icon(Icons.add), label: const Text('Schedule one')),
                    ],
                  ))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _items.length,
                      itemBuilder: (_, i) => _tile(_items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tile(dynamic item) {
    final lead = item['leadId'] ?? {};
    final when = DateTime.tryParse(item['scheduledAt'] ?? '') ?? DateTime.now();
    final isPending = item['status'] == 'pending';
    final type = item['type'] ?? 'call';
    IconData icon;
    Color color;
    switch (type) {
      case 'whatsapp': icon = Icons.chat; color = const Color(0xFF25D366); break;
      case 'meeting': icon = Icons.event; color = AppColors.primary; break;
      case 'visit': icon = Icons.place; color = AppColors.teal700; break;
      default: icon = Icons.phone; color = AppColors.primary;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${type.toString().toUpperCase()} • ${DateFormat('d MMM, h:mm a').format(when)}',
                  style: const TextStyle(color: AppColors.textgrey, fontSize: 11)),
                if ((item['note'] ?? '').toString().isNotEmpty)
                  Text(item['note'], style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (isPending) ...[
            IconButton(onPressed: () => _action(item), icon: Icon(icon, color: color, size: 22)),
            IconButton(onPressed: () => _complete(item), icon: const Icon(Icons.check_circle_outline, color: AppColors.primary)),
          ] else
            const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}

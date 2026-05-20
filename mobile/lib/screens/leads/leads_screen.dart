// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/lead_model.dart';
import '../../services/lead_service.dart';
import 'lead_form_screen.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});
  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  List<LeadModel> _items = [];
  String? _filter;
  bool _loading = true;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await LeadService().list(status: _filter, q: _q.isEmpty ? null : _q);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _whatsapp(LeadModel lead) async {
    final phone = (lead.whatsapp ?? lead.phone)?.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse('https://wa.me/$phone?text=Hi%20${Uri.encodeComponent(lead.name)}');
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(LeadModel lead) async {
    if (lead.phone == null) return;
    final url = Uri.parse('tel:${lead.phone}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadFormScreen()));
              _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search leads...',
                prefixIcon: Icon(Icons.search, color: AppColors.textgrey),
              ),
              onChanged: (v) { _q = v; },
              onSubmitted: (_) => _load(),
            ),
          ),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _chip('All', null),
                _chip('New', 'new'),
                _chip('Contacted', 'contacted'),
                _chip('Qualified', 'qualified'),
                _chip('Won', 'won'),
                _chip('Lost', 'lost'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                    ? ListView(children: const [
                        SizedBox(height: 100),
                        Center(child: Text('No leads yet', style: TextStyle(color: AppColors.textgrey))),
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: _items.length,
                        itemBuilder: (_, i) {
                          final lead = _items[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: _priorityColor(lead.priority).withOpacity(0.15),
                                child: Text(lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                                  style: TextStyle(color: _priorityColor(lead.priority), fontWeight: FontWeight.bold)),
                              ),
                              title: Text(lead.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${lead.phone ?? ''} • ${lead.source}',
                                style: const TextStyle(color: AppColors.textgrey, fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 22), onPressed: () => _whatsapp(lead)),
                                  IconButton(icon: const Icon(Icons.call, color: AppColors.primary, size: 22), onPressed: () => _call(lead)),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => LeadFormScreen(existing: lead)));
                                _load();
                              },
                            ),
                          );
                        },
                      ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textgrey),
        side: BorderSide(color: selected ? AppColors.primary : Colors.transparent),
        onSelected: (_) {
          setState(() => _filter = value);
          _load();
        },
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'hot': return AppColors.red;
      case 'warm': return Colors.orange;
      default: return AppColors.textgrey;
    }
  }
}

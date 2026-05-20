import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/lead_model.dart';
import '../../services/lead_service.dart';
import '../../services/service_service.dart';

class LeadFormScreen extends StatefulWidget {
  final LeadModel? existing;
  const LeadFormScreen({super.key, this.existing});
  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name, _phone, _email, _company, _requirement, _value, _notes;
  String _source = 'whatsapp';
  String _status = 'new';
  String _priority = 'warm';
  bool _busy = false;
  List<dynamic> _availableServices = [];
  final Set<String> _selectedServices = {};

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _company = TextEditingController(text: e?.company ?? '');
    _requirement = TextEditingController(text: e?.requirement ?? '');
    _value = TextEditingController(text: e?.estimatedValue?.toString() ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    if (e != null) {
      _source = e.source;
      _status = e.status;
      _priority = e.priority;
    }
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      _availableServices = await ServiceService().list();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final body = {
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
        'company': _company.text.trim(),
        'requirement': _requirement.text.trim(),
        'estimatedValue': double.tryParse(_value.text) ?? 0,
        'notes': _notes.text.trim(),
        'source': _source,
        'status': _status,
        'priority': _priority,
        'services': _selectedServices.toList(),
      };
      if (widget.existing != null) {
        await LeadService().update(widget.existing!.id, body);
      } else {
        await LeadService().create(body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(title: Text(widget.existing == null ? 'New Lead' : 'Edit Lead')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _label('Name *'),
            TextFormField(controller: _name, decoration: const InputDecoration(hintText: 'Full name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null),
            _label('Phone'),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone),
            _label('Email'),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress),
            _label('Company'),
            TextFormField(controller: _company),
            _label('Requirement'),
            TextFormField(controller: _requirement, maxLines: 2),
            _label('Interested Services'),
            if (_availableServices.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('No services yet. Add services in the Services tab to link them here.',
                    style: TextStyle(fontSize: 12))),
                ]),
              )
            else
              Wrap(
                spacing: 8, runSpacing: 6,
                children: _availableServices.map<Widget>((s) {
                  final selected = _selectedServices.contains(s['_id']);
                  return FilterChip(
                    label: Text('${s['name']} • ₹${s['price'] ?? 0}'),
                    selected: selected,
                    selectedColor: AppColors.light,
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(color: selected ? AppColors.primary : AppColors.fildbg),
                    onSelected: (v) => setState(() {
                      if (v) _selectedServices.add(s['_id']); else _selectedServices.remove(s['_id']);
                    }),
                  );
                }).toList(),
              ),
            _label('Estimated Value (₹)'),
            TextFormField(controller: _value, keyboardType: TextInputType.number),
            _label('Source'),
            _dropdown(_source, ['whatsapp', 'call', 'website', 'instagram', 'facebook', 'referral', 'walk-in', 'other'], (v) => _source = v),
            _label('Status'),
            _dropdown(_status, ['new', 'contacted', 'qualified', 'proposal', 'negotiation', 'won', 'lost'], (v) => _status = v),
            _label('Priority'),
            _dropdown(_priority, ['hot', 'warm', 'cold'], (v) => _priority = v),
            _label('Notes'),
            TextFormField(controller: _notes, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save Lead')),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.fromLTRB(2, 12, 0, 6),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)));

  Widget _dropdown(String value, List<String> options, Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: (v) => setState(() => onChanged(v!)),
    );
  }
}

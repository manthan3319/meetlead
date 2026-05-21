import 'package:flutter/material.dart';
import '../../../models/lead_model.dart';
import '../../../services/followup_service.dart';
import '../../../services/lead_service.dart';

class NewFollowupProvider extends ChangeNotifier {
  List<LeadModel> leads = [];
  String? selectedLeadId;
  String type = 'call';
  DateTime scheduledAt = DateTime.now().add(const Duration(hours: 1));
  final noteController = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  String? _error;

  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;
  bool get noLeads => !_loading && leads.isEmpty;

  NewFollowupProvider() {
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    try {
      leads = await LeadService().list();
      if (leads.isNotEmpty) selectedLeadId = leads.first.id;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void setLead(String id) {
    selectedLeadId = id;
    notifyListeners();
  }

  void setType(String t) {
    type = t;
    notifyListeners();
  }

  void setScheduledAt(DateTime dt) {
    scheduledAt = dt;
    notifyListeners();
  }

  Future<void> pickDateTime(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: scheduledAt,
    );
    if (d == null || !context.mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(scheduledAt),
    );
    if (t == null) return;
    setScheduledAt(DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<bool> submit(BuildContext context) async {
    if (selectedLeadId == null) return false;
    _submitting = true;
    notifyListeners();
    try {
      await FollowupService().create({
        'leadId': selectedLeadId,
        'type': type,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'note': noteController.text.trim(),
      });
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}

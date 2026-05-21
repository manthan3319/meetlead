import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/lead_model.dart';
import '../../../services/lead_service.dart';
import '../view/lead_form_screen.dart';

class LeadsProvider extends ChangeNotifier {
  List<LeadModel> _items = [];
  String? _filter;
  String _query = '';
  bool _loading = true;

  List<LeadModel> get items => _items;
  String? get filter => _filter;
  String get query => _query;
  bool get loading => _loading;

  LeadsProvider() {
    load();
  }

  void setQuery(String q) {
    _query = q;
  }

  Future<void> setFilter(String? f) async {
    if (_filter == f) return;
    _filter = f;
    notifyListeners();
    await load();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await LeadService().list(
        status: _filter,
        q: _query.isEmpty ? null : _query,
      );
    } catch (_) {
      // swallow: empty list renders empty-state
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> whatsapp(LeadModel lead) async {
    final raw = (lead.whatsapp ?? lead.phone);
    final phone = raw?.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse(
      'https://wa.me/$phone?text=Hi%20${Uri.encodeComponent(lead.name)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> call(LeadModel lead) async {
    if (lead.phone == null) return;
    final url = Uri.parse('tel:${lead.phone}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> openNewLead(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeadFormScreen()),
    );
    if (context.mounted) await load();
  }

  Future<void> openEditLead(BuildContext context, LeadModel lead) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LeadFormScreen(existing: lead)),
    );
    if (context.mounted) await load();
  }
}

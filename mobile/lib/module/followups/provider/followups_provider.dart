import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../services/followup_service.dart';
import '../widget/new_followup_sheet.dart';
import '../widget/outcome_dialog.dart';

class FollowupsProvider extends ChangeNotifier {
  String _filter = 'today';
  List<dynamic> _items = [];
  bool _loading = true;

  String get filter => _filter;
  List<dynamic> get items => _items;
  bool get loading => _loading;

  FollowupsProvider() {
    load();
  }

  Future<void> setFilter(String f) async {
    if (_filter == f) return;
    _filter = f;
    notifyListeners();
    await load();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      if (_filter == 'today') {
        _items = await FollowupService().today();
      } else if (_filter == 'pending') {
        _items = await FollowupService().list(status: 'pending');
      } else {
        _items = await FollowupService().list(status: 'done');
      }
    } catch (_) {
      // swallow: empty list renders an empty-state card
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> complete(BuildContext context, dynamic item) async {
    final outcome = await showOutcomeDialog(context);
    if (outcome == null) return;
    try {
      await FollowupService().complete(item['_id'], outcome: outcome);
      await load();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow-up completed'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> launchContact(dynamic item) async {
    final lead = item['leadId'];
    if (lead == null) return;
    final phone =
        (lead['phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) return;
    final type = item['type'];
    final url = type == 'whatsapp'
        ? Uri.parse('https://wa.me/$phone')
        : Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> openNewFollowup(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewFollowupSheet(),
    );
    if (created == true) await load();
  }
}

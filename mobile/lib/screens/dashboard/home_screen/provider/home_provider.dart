import 'package:flutter/material.dart';
import '../../../../models/meeting_model.dart';
import '../../../../services/api_service.dart';
import '../../../../services/followup_service.dart';
import '../../../../services/meeting_service.dart';
import '../../../leads/lead_form_screen.dart';
import '../../../meetings/meeting_detail_screen.dart';
import '../../../meetings/meeting_form_screen.dart';

class HomeProvider extends ChangeNotifier {
  Map<String, dynamic>? _summary;
  List<MeetingModel> _upcoming = [];
  List<dynamic> _todayFollowups = [];
  bool _loading = true;

  Map<String, dynamic>? get summary => _summary;
  List<MeetingModel> get upcoming => _upcoming;
  List<dynamic> get todayFollowups => _todayFollowups;
  bool get loading => _loading;

  HomeProvider() {
    load();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final r = await ApiService().dio.get('/dashboard/summary');
      _summary = r.data['data'];
      _upcoming = await MeetingService().upcoming();
      _todayFollowups = await FollowupService().today();
    } catch (_) {
      // swallowed: empty lists / null summary render as zeros + empty cards
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> openLeadForm(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeadFormScreen()),
    );
    if (context.mounted) await load();
  }

  Future<void> openMeetingForm(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MeetingFormScreen()),
    );
    if (context.mounted) await load();
  }

  Future<void> openMeetingDetail(
      BuildContext context, MeetingModel meeting) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MeetingDetailScreen(meeting: meeting)),
    );
    if (context.mounted) await load();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/meeting_service.dart';
import '../../services/followup_service.dart';
import '../../models/meeting_model.dart';
import '../leads/lead_form_screen.dart';
import '../meetings/meeting_form_screen.dart';
import '../meetings/meeting_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _summary;
  List<MeetingModel> _upcoming = [];
  List<dynamic> _todayFollowups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ApiService();
      final r = await api.dio.get('/dashboard/summary');
      _summary = r.data['data'];
      _upcoming = await MeetingService().upcoming();
      _todayFollowups = await FollowupService().today();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.name.isNotEmpty == true ? user!.name[0] : '?').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, ${user?.name.split(' ').first ?? ''}!',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(DateFormat('EEEE, d MMM').format(DateTime.now()),
                          style: const TextStyle(color: AppColors.textgrey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _quickAction(Icons.person_add, 'New Lead', AppColors.primary, () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadFormScreen()));
                    _load();
                  })),
                  const SizedBox(width: 10),
                  Expanded(child: _quickAction(Icons.event_available, 'New Meeting', AppColors.teal700, () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const MeetingFormScreen()));
                    _load();
                  })),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
              else ...[
                _StatGrid(summary: _summary),
                const SizedBox(height: 24),
                _section('Upcoming Meetings', _upcoming.length),
                const SizedBox(height: 8),
                if (_upcoming.isEmpty)
                  _emptyCard('No upcoming meetings', Icons.event_busy)
                else
                  ..._upcoming.take(5).map((m) => _MeetingTile(meeting: m, onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => MeetingDetailScreen(meeting: m)));
                    _load();
                  })),
                const SizedBox(height: 20),
                _section('Today\'s Follow-ups', _todayFollowups.length),
                const SizedBox(height: 8),
                if (_todayFollowups.isEmpty)
                  _emptyCard('No follow-ups for today', Icons.flag_outlined)
                else
                  ..._todayFollowups.take(5).map(_followupTile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _emptyCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textgrey.withOpacity(0.5)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(color: AppColors.textgrey)),
        ],
      ),
    );
  }

  Widget _followupTile(dynamic item) {
    final lead = item['leadId'] ?? {};
    final when = DateTime.tryParse(item['scheduledAt'] ?? '') ?? DateTime.now();
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
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${type.toString().toUpperCase()} • ${DateFormat('h:mm a').format(when)}',
                  style: const TextStyle(color: AppColors.textgrey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final Map<String, dynamic>? summary;
  const _StatGrid({this.summary});

  @override
  Widget build(BuildContext context) {
    final leads = summary?['leads'] ?? {};
    final meetings = summary?['meetings'] ?? {};
    final followups = summary?['followups'] ?? {};

    final tiles = [
      _Tile('Today\'s Meetings', '${meetings['today'] ?? 0}', Icons.event, AppColors.primary),
      _Tile('Pending Follow-ups', '${followups['pending'] ?? 0}', Icons.flag, AppColors.teal700),
      _Tile('New Leads', '${leads['new'] ?? 0}', Icons.fiber_new, AppColors.dark),
      _Tile('Won Leads', '${leads['won'] ?? 0}', Icons.emoji_events, Colors.amber.shade700),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: tiles,
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Tile(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.textgrey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MeetingTile extends StatelessWidget {
  final MeetingModel meeting;
  final VoidCallback onTap;
  const _MeetingTile({required this.meeting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM, h:mm a');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.event, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meeting.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(fmt.format(meeting.scheduledAt), style: const TextStyle(color: AppColors.textgrey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(6)),
              child: Text(meeting.type, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

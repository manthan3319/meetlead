import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/auth_provider.dart';
import '../provider/home_provider.dart';
import '../widget/empty_card.dart';
import '../widget/followup_tile.dart';
import '../widget/meeting_tile.dart';
import '../widget/quick_action.dart';
import '../widget/section_header.dart';
import '../widget/stat_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HomeProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.fildbg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: p.load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (user?.name.isNotEmpty == true ? user!.name[0] : '?')
                          .toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${user?.name.split(' ').first ?? ''}!',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('EEEE, d MMM').format(DateTime.now()),
                          style: const TextStyle(
                              color: AppColors.textgrey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: QuickAction(
                      icon: Icons.person_add,
                      label: 'New Lead',
                      color: AppColors.primary,
                      onTap: () => p.openLeadForm(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: QuickAction(
                      icon: Icons.event_available,
                      label: 'New Meeting',
                      color: AppColors.teal700,
                      onTap: () => p.openMeetingForm(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (p.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                StatGrid(summary: p.summary),
                const SizedBox(height: 24),
                SectionHeader(
                    title: 'Upcoming Meetings', count: p.upcoming.length),
                const SizedBox(height: 8),
                if (p.upcoming.isEmpty)
                  const EmptyCard(
                      text: 'No upcoming meetings', icon: Icons.event_busy)
                else
                  ...p.upcoming.take(5).map(
                        (m) => MeetingTile(
                          meeting: m,
                          onTap: () => p.openMeetingDetail(context, m),
                        ),
                      ),
                const SizedBox(height: 20),
                SectionHeader(
                    title: "Today's Follow-ups",
                    count: p.todayFollowups.length),
                const SizedBox(height: 8),
                if (p.todayFollowups.isEmpty)
                  const EmptyCard(
                      text: 'No follow-ups for today', icon: Icons.flag_outlined)
                else
                  ...p.todayFollowups.take(5).map((f) => FollowupTile(item: f)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

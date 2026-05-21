import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../provider/followups_provider.dart';
import '../widget/followup_tile.dart';

class FollowupsScreen extends StatelessWidget {
  const FollowupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FollowupsProvider(),
      child: const _FollowupsView(),
    );
  }
}

class _FollowupsView extends StatelessWidget {
  const _FollowupsView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<FollowupsProvider>();

    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(
        title: const Text('Follow-ups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => p.openNewFollowup(context),
          ),
        ],
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
              selected: {p.filter},
              onSelectionChanged: (s) => p.setFilter(s.first),
            ),
          ),
          Expanded(
            child: p.loading
                ? const Center(child: CircularProgressIndicator())
                : p.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flag_outlined,
                                size: 60, color: AppColors.textgrey),
                            const SizedBox(height: 12),
                            Text(
                              'No ${p.filter} follow-ups',
                              style:
                                  const TextStyle(color: AppColors.textgrey),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => p.openNewFollowup(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Schedule one'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: p.load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: p.items.length,
                          itemBuilder: (_, i) {
                            final item = p.items[i];
                            return FollowupTile(
                              item: item,
                              onAction: () => p.launchContact(item),
                              onComplete: () => p.complete(context, item),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

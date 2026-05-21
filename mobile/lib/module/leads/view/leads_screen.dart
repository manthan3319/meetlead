import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../provider/leads_provider.dart';
import '../widget/lead_tile.dart';
import '../widget/status_filter_bar.dart';

class LeadsScreen extends StatelessWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeadsProvider(),
      child: const _LeadsView(),
    );
  }
}

class _LeadsView extends StatelessWidget {
  const _LeadsView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LeadsProvider>();

    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => p.openNewLead(context),
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
              onChanged: p.setQuery,
              onSubmitted: (_) => p.load(),
            ),
          ),
          StatusFilterBar(
            selected: p.filter,
            onChanged: p.setFilter,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: p.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: p.load,
                    child: p.items.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'No leads yet',
                                style: TextStyle(color: AppColors.textgrey),
                              ),
                            ),
                          ])
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: p.items.length,
                            itemBuilder: (_, i) {
                              final lead = p.items[i];
                              return LeadTile(
                                lead: lead,
                                onTap: () => p.openEditLead(context, lead),
                                onWhatsapp: () => p.whatsapp(lead),
                                onCall: () => p.call(lead),
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

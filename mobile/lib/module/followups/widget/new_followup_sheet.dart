import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../provider/new_followup_provider.dart';

class NewFollowupSheet extends StatelessWidget {
  const NewFollowupSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewFollowupProvider(),
      child: const _NewFollowupSheetView(),
    );
  }
}

class _NewFollowupSheetView extends StatelessWidget {
  const _NewFollowupSheetView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NewFollowupProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: p.loading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : p.noLeads
                ? const _NoLeadsView()
                : _FormView(p: p),
      ),
    );
  }
}

class _NoLeadsView extends StatelessWidget {
  const _NoLeadsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_add_disabled,
              size: 48, color: AppColors.textgrey),
          const SizedBox(height: 12),
          const Text('Add a lead first',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text(
            'You need at least one lead before scheduling a follow-up.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textgrey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final NewFollowupProvider p;
  const _FormView({required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'New Follow-up',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Lead', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: p.selectedLeadId,
          items: p.leads
              .map((l) => DropdownMenuItem(value: l.id, child: Text(l.name)))
              .toList(),
          onChanged: (v) {
            if (v != null) p.setLead(v);
          },
        ),
        const SizedBox(height: 12),
        const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
                value: 'call', label: Text('Call'), icon: Icon(Icons.phone)),
            ButtonSegment(
                value: 'whatsapp', label: Text('WA'), icon: Icon(Icons.chat)),
            ButtonSegment(
                value: 'meeting',
                label: Text('Meet'),
                icon: Icon(Icons.event)),
            ButtonSegment(
                value: 'visit', label: Text('Visit'), icon: Icon(Icons.place)),
          ],
          selected: {p.type},
          onSelectionChanged: (s) => p.setType(s.first),
        ),
        const SizedBox(height: 12),
        const Text('When', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => p.pickDateTime(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.fildbg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.event, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(DateFormat('d MMM, h:mm a').format(p.scheduledAt)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: p.noteController,
          decoration: const InputDecoration(hintText: 'Note (optional)'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: p.submitting
              ? null
              : () async {
                  final ok = await p.submit(context);
                  if (ok && context.mounted) Navigator.pop(context, true);
                },
          child: p.submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Schedule Follow-up'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

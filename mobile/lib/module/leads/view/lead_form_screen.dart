import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/lead_model.dart';
import '../provider/lead_form_provider.dart';
import '../widget/form_label.dart';
import '../widget/services_picker.dart';

class LeadFormScreen extends StatelessWidget {
  final LeadModel? existing;
  const LeadFormScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeadFormProvider(existing: existing),
      child: const _LeadFormView(),
    );
  }
}

class _LeadFormView extends StatelessWidget {
  const _LeadFormView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LeadFormProvider>();

    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(title: Text(p.isEdit ? 'Edit Lead' : 'New Lead')),
      body: Form(
        key: p.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const FormLabel('Name *'),
            TextFormField(
              controller: p.nameController,
              decoration: const InputDecoration(hintText: 'Full name'),
              validator: p.validateName,
            ),
            const FormLabel('Phone'),
            TextFormField(
              controller: p.phoneController,
              keyboardType: TextInputType.phone,
            ),
            const FormLabel('Email'),
            TextFormField(
              controller: p.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const FormLabel('Company'),
            TextFormField(controller: p.companyController),
            const FormLabel('Requirement'),
            TextFormField(
              controller: p.requirementController,
              maxLines: 2,
            ),
            const FormLabel('Interested Services'),
            ServicesPicker(
              available: p.availableServices,
              selected: p.selectedServices,
              onToggle: p.toggleService,
            ),
            const FormLabel('Estimated Value (₹)'),
            TextFormField(
              controller: p.valueController,
              keyboardType: TextInputType.number,
            ),
            const FormLabel('Source'),
            _Dropdown(
              value: p.source,
              options: const [
                'whatsapp',
                'call',
                'website',
                'instagram',
                'facebook',
                'referral',
                'walk-in',
                'other',
              ],
              onChanged: p.setSource,
            ),
            const FormLabel('Status'),
            _Dropdown(
              value: p.status,
              options: const [
                'new',
                'contacted',
                'qualified',
                'proposal',
                'negotiation',
                'won',
                'lost',
              ],
              onChanged: p.setStatus,
            ),
            const FormLabel('Priority'),
            _Dropdown(
              value: p.priority,
              options: const ['hot', 'warm', 'cold'],
              onChanged: p.setPriority,
            ),
            const FormLabel('Notes'),
            TextFormField(controller: p.notesController, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: p.busy
                  ? null
                  : () async {
                      final ok = await p.save(context);
                      if (ok && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
              child: Text(p.busy ? 'Saving...' : 'Save Lead'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _Dropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

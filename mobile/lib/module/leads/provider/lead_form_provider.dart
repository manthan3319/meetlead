import 'package:flutter/material.dart';
import '../../../models/lead_model.dart';
import '../../../services/lead_service.dart';
import '../../../services/service_service.dart';

class LeadFormProvider extends ChangeNotifier {
  final LeadModel? existing;
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController companyController;
  late final TextEditingController requirementController;
  late final TextEditingController valueController;
  late final TextEditingController notesController;

  String source = 'whatsapp';
  String status = 'new';
  String priority = 'warm';

  List<dynamic> _availableServices = [];
  final Set<String> _selectedServices = {};
  bool _busy = false;

  List<dynamic> get availableServices => _availableServices;
  Set<String> get selectedServices => _selectedServices;
  bool get busy => _busy;
  bool get isEdit => existing != null;

  LeadFormProvider({this.existing}) {
    final e = existing;
    nameController = TextEditingController(text: e?.name ?? '');
    phoneController = TextEditingController(text: e?.phone ?? '');
    emailController = TextEditingController(text: e?.email ?? '');
    companyController = TextEditingController(text: e?.company ?? '');
    requirementController = TextEditingController(text: e?.requirement ?? '');
    valueController =
        TextEditingController(text: e?.estimatedValue?.toString() ?? '');
    notesController = TextEditingController(text: e?.notes ?? '');
    if (e != null) {
      source = e.source;
      status = e.status;
      priority = e.priority;
    }
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      _availableServices = await ServiceService().list();
      notifyListeners();
    } catch (_) {}
  }

  void setSource(String v) {
    source = v;
    notifyListeners();
  }

  void setStatus(String v) {
    status = v;
    notifyListeners();
  }

  void setPriority(String v) {
    priority = v;
    notifyListeners();
  }

  void toggleService(String id, bool isOn) {
    if (isOn) {
      _selectedServices.add(id);
    } else {
      _selectedServices.remove(id);
    }
    notifyListeners();
  }

  String? validateName(String? v) =>
      v == null || v.isEmpty ? 'Required' : null;

  Future<bool> save(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;
    _busy = true;
    notifyListeners();
    try {
      final body = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'company': companyController.text.trim(),
        'requirement': requirementController.text.trim(),
        'estimatedValue': double.tryParse(valueController.text) ?? 0,
        'notes': notesController.text.trim(),
        'source': source,
        'status': status,
        'priority': priority,
        'services': _selectedServices.toList(),
      };
      if (existing != null) {
        await LeadService().update(existing!.id, body);
      } else {
        await LeadService().create(body);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    companyController.dispose();
    requirementController.dispose();
    valueController.dispose();
    notesController.dispose();
    super.dispose();
  }
}

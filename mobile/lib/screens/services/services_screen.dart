import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final r = await ApiService().dio.get('/services');
      _items = r.data['data'];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addService() async {
    final name = TextEditingController();
    final price = TextEditingController();
    String category = 'website';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('New Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: name, decoration: const InputDecoration(hintText: 'Service name')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  items: const [
                    DropdownMenuItem(value: 'website', child: Text('Website')),
                    DropdownMenuItem(value: 'graphics', child: Text('Graphics')),
                    DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
                    DropdownMenuItem(value: 'development', child: Text('Development')),
                    DropdownMenuItem(value: 'consulting', child: Text('Consulting')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setS(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(controller: price, keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Price (₹)')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (name.text.isEmpty) return;
                    try {
                      await ApiService().dio.post('/services', data: {
                        'name': name.text.trim(),
                        'category': category,
                        'price': double.tryParse(price.text) ?? 0,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      _load();
                    } catch (_) {}
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fildbg,
      appBar: AppBar(
        title: const Text('Services'),
        actions: [IconButton(icon: const Icon(Icons.add, color: AppColors.primary), onPressed: _addService)],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _items.isEmpty
          ? const Center(child: Text('No services yet. Tap + to add.', style: TextStyle(color: AppColors.textgrey)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final s = _items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
                        child: Icon(_iconFor(s['category']), color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(s['category'] ?? '', style: const TextStyle(color: AppColors.textgrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('₹${s['price'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _iconFor(String? cat) {
    switch (cat) {
      case 'website': return Icons.web;
      case 'graphics': return Icons.image;
      case 'marketing': return Icons.campaign;
      case 'development': return Icons.code;
      case 'consulting': return Icons.school;
      default: return Icons.work;
    }
  }
}

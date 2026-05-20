import '../models/lead_model.dart';
import 'api_service.dart';

class LeadService {
  final api = ApiService();

  Future<List<LeadModel>> list({String? status, String? q}) async {
    final r = await api.dio.get('/leads', queryParameters: {
      if (status != null) 'status': status,
      if (q != null) 'q': q,
    });
    return (r.data['data'] as List).map((e) => LeadModel.fromJson(e)).toList();
  }

  Future<LeadModel> create(Map<String, dynamic> body) async {
    final r = await api.dio.post('/leads', data: body);
    return LeadModel.fromJson(r.data['data']);
  }

  Future<LeadModel> update(String id, Map<String, dynamic> body) async {
    final r = await api.dio.put('/leads/$id', data: body);
    return LeadModel.fromJson(r.data['data']);
  }

  Future<void> remove(String id) async {
    await api.dio.delete('/leads/$id');
  }

  Future<Map<String, dynamic>> stats() async {
    final r = await api.dio.get('/leads/stats');
    return r.data;
  }
}

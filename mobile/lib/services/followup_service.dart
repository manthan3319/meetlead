import 'api_service.dart';

class FollowupService {
  final api = ApiService();

  Future<List<dynamic>> today() async {
    final r = await api.dio.get('/followups/today');
    return r.data['data'] as List;
  }

  Future<List<dynamic>> list({String? status, String? leadId}) async {
    final r = await api.dio.get('/followups', queryParameters: {
      if (status != null) 'status': status,
      if (leadId != null) 'leadId': leadId,
    });
    return r.data['data'] as List;
  }

  Future<dynamic> create(Map<String, dynamic> body) async {
    final r = await api.dio.post('/followups', data: body);
    return r.data['data'];
  }

  Future<dynamic> complete(String id, {String? outcome}) async {
    final r = await api.dio.patch('/followups/$id/complete', data: {
      if (outcome != null) 'outcome': outcome,
    });
    return r.data['data'];
  }

  Future<void> remove(String id) async {
    await api.dio.delete('/followups/$id');
  }
}

import 'api_service.dart';

class ServiceService {
  final api = ApiService();

  Future<List<dynamic>> list() async {
    final r = await api.dio.get('/services');
    return r.data['data'] as List;
  }

  Future<dynamic> create(Map<String, dynamic> body) async {
    final r = await api.dio.post('/services', data: body);
    return r.data['data'];
  }

  Future<dynamic> update(String id, Map<String, dynamic> body) async {
    final r = await api.dio.put('/services/$id', data: body);
    return r.data['data'];
  }

  Future<void> remove(String id) async {
    await api.dio.delete('/services/$id');
  }
}

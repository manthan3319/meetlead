import '../models/meeting_model.dart';
import 'api_service.dart';

class MeetingService {
  final api = ApiService();

  Future<List<MeetingModel>> upcoming() async {
    final r = await api.dio.get('/meetings/upcoming');
    return (r.data['data'] as List).map((e) => MeetingModel.fromJson(e)).toList();
  }

  Future<List<MeetingModel>> list({DateTime? from, DateTime? to, String? status}) async {
    final r = await api.dio.get('/meetings', queryParameters: {
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      if (status != null) 'status': status,
    });
    return (r.data['data'] as List).map((e) => MeetingModel.fromJson(e)).toList();
  }

  Future<MeetingModel> create(Map<String, dynamic> body) async {
    final r = await api.dio.post('/meetings', data: body);
    return MeetingModel.fromJson(r.data['data']);
  }

  Future<MeetingModel> update(String id, Map<String, dynamic> body) async {
    final r = await api.dio.put('/meetings/$id', data: body);
    return MeetingModel.fromJson(r.data['data']);
  }

  Future<MeetingModel> addNote(String id, {String? notes, String? outcome, String? status}) async {
    final r = await api.dio.put('/meetings/$id/note', data: {
      if (notes != null) 'notes': notes,
      if (outcome != null) 'outcome': outcome,
      if (status != null) 'status': status,
    });
    return MeetingModel.fromJson(r.data['data']);
  }

  Future<void> remove(String id) async {
    await api.dio.delete('/meetings/$id');
  }
}

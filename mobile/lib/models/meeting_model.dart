class MeetingModel {
  final String id;
  final String title;
  final String? description;
  final String type;
  final String? meetingLink;
  final String? location;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status;
  final String? notes;
  final String? outcome;
  final Map<String, dynamic>? leadInfo;

  MeetingModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.meetingLink,
    this.location,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    this.notes,
    this.outcome,
    this.leadInfo,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> j) => MeetingModel(
    id: j['_id'] ?? '',
    title: j['title'] ?? '',
    description: j['description'],
    type: j['type'] ?? 'online',
    meetingLink: j['meetingLink'],
    location: j['location'],
    scheduledAt: DateTime.tryParse(j['scheduledAt'] ?? '') ?? DateTime.now(),
    durationMinutes: j['durationMinutes'] ?? 30,
    status: j['status'] ?? 'scheduled',
    notes: j['notes'],
    outcome: j['outcome'],
    leadInfo: j['leadId'] is Map ? j['leadId'] : null,
  );
}

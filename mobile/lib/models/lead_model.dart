class LeadModel {
  final String id;
  final String name;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? company;
  final String source;
  final String status;
  final String priority;
  final String? requirement;
  final double? estimatedValue;
  final List<String> tags;
  final String? notes;
  final DateTime? nextFollowupAt;
  final DateTime createdAt;

  LeadModel({
    required this.id,
    required this.name,
    this.phone,
    this.whatsapp,
    this.email,
    this.company,
    required this.source,
    required this.status,
    required this.priority,
    this.requirement,
    this.estimatedValue,
    required this.tags,
    this.notes,
    this.nextFollowupAt,
    required this.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> j) => LeadModel(
    id: j['_id'] ?? '',
    name: j['name'] ?? '',
    phone: j['phone'],
    whatsapp: j['whatsapp'],
    email: j['email'],
    company: j['company'],
    source: j['source'] ?? 'other',
    status: j['status'] ?? 'new',
    priority: j['priority'] ?? 'warm',
    requirement: j['requirement'],
    estimatedValue: (j['estimatedValue'] ?? 0).toDouble(),
    tags: List<String>.from(j['tags'] ?? []),
    notes: j['notes'],
    nextFollowupAt: j['nextFollowupAt'] != null ? DateTime.tryParse(j['nextFollowupAt']) : null,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );
}

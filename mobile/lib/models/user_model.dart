class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? organizationId;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.organizationId,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] ?? j['_id'] ?? '',
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'],
    role: j['role'] ?? 'owner',
    organizationId: j['organizationId']?.toString(),
    avatar: j['avatar'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'phone': phone,
    'role': role, 'organizationId': organizationId, 'avatar': avatar,
  };
}

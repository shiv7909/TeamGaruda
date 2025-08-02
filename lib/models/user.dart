class CivicUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final int reportCount;
  final String status;

  CivicUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.reportCount = 0,
    this.status = 'active',
  });

  factory CivicUser.fromJson(Map<String, dynamic> json) {
    return CivicUser(
      id: json['id'] ?? '',
      name: json['user_name'] ?? '', // Note: your schema uses 'user_name' not 'name'
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      reportCount: json['report_count'] ?? 0, // This should be calculated separately
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': name, // Note: your schema uses 'user_name' not 'name'
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'report_count': reportCount,
      'status': status,
    };
  }

  String get displayId => 'USR-${id.substring(0, 8).toUpperCase()}';
  
  String get capitalizedStatus {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'flagged':
        return 'Flagged';
      case 'banned':
        return 'Banned';
      default:
        return 'Active';
    }
  }
  
  // Default values for missing fields
  String? get phone => null;
  bool get isVerified => true; // Default to verified
  DateTime get updatedAt => createdAt;
}

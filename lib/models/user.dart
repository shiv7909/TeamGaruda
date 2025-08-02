class CivicUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String remark; // Maps to remark field (active/inactive/etc)
  final int spamReports; // Maps to spam_reports field
  final int reports; // Maps to reports field

  CivicUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.remark = 'active',
    this.spamReports = 0,
    this.reports = 0,
  });

  factory CivicUser.fromJson(Map<String, dynamic> json) {
    return CivicUser(
      id: json['id'] ?? '',
      name: json['user_name'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      remark: json['remark'] ?? 'active',
      spamReports: json['spam_reports'] ?? 0,
      reports: json['reports'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'remark': remark,
      'spam_reports': spamReports,
      'reports': reports,
    };
  }

  String get displayId => 'USR-${id.substring(0, 8).toUpperCase()}';
  
  String get status => remark; // Use remark as status
  
  String get capitalizedStatus {
    switch (remark.toLowerCase()) {
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
  
  // Getter for backward compatibility
  int get reportCount => reports;
  
  // Default values for missing fields
  String? get phone => null;
  bool get isVerified => true;
  DateTime get updatedAt => createdAt;
}

class Department {
  final int id;
  final DateTime createdAt;
  final String department;
  final String mail;
  final String pass;

  Department({
    required this.id,
    required this.createdAt,
    required this.department,
    required this.mail,
    required this.pass,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      department: json['department'] as String,
      mail: json['mail'] as String,
      pass: json['pass'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'department': department,
      'mail': mail,
      'pass': pass,
    };
  }
}

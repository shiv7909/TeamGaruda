class Issue {
  final String id;
  final String title;
  final String description;
  final String issueType; // Your schema uses 'issue_type' not 'category'
  final String status;
  final double? latitude;
  final double? longitude;
  final String userId;
  final String? imageUrl;
  final DateTime createdAt;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.issueType,
    required this.status,
    this.latitude,
    this.longitude,
    required this.userId,
    this.imageUrl,
    required this.createdAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      issueType: json['issue_type'] ?? '', // Note: your schema uses 'issue_type'
      status: json['status'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      userId: json['user_id'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'issue_type': issueType, // Note: your schema uses 'issue_type'
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayId => 'CIV-${id.substring(0, 8).toUpperCase()}';
  
  // For backward compatibility, map issueType to category
  String get category => issueType;
  
  String get capitalizedCategory {
    return issueType.isEmpty 
        ? 'Unknown' 
        : issueType[0].toUpperCase() + issueType.substring(1);
  }
  
  String get capitalizedStatus {
    return status.isEmpty 
        ? 'Unknown' 
        : status[0].toUpperCase() + status.substring(1);
  }

  // Default priority since it's not in your schema
  String get priority => 'medium';
  String get capitalizedPriority => 'Medium';
  
  // Default values for missing fields
  String? get address => null;
  DateTime get updatedAt => createdAt; // Since your schema doesn't have updated_at
}

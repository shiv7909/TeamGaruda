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
  final List<String>? imageUrls;
  final List<String>? completedImageUrls;
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
    this.imageUrls,
    this.completedImageUrls,
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
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'] is List ? json['image_urls'] : [])
          : null,
      completedImageUrls: json['completed_image_urls'] != null 
          ? List<String>.from(json['completed_image_urls'] is List ? json['completed_image_urls'] : [])
          : null,
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
      'image_urls': imageUrls,
      'completed_image_urls': completedImageUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayId => 'CIV-${id.substring(0, 8).toUpperCase()}';
  
  // Get all available image URLs
  List<String> get allImageUrls {
    List<String> images = [];
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      images.add(imageUrl!);
    }
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      images.addAll(imageUrls!.where((url) => url.isNotEmpty));
    }
    return images;
  }
  
  // Get all completed image URLs
  List<String> get allCompletedImageUrls {
    List<String> images = [];
    if (completedImageUrls != null && completedImageUrls!.isNotEmpty) {
      images.addAll(completedImageUrls!.where((url) => url.isNotEmpty));
    }
    return images;
  }
  
  // Check if issue can be modified (can't change status back from resolved)
  bool get canModifyStatus => status.toLowerCase() != 'resolved';
  
  // Check if admin can upload completion images
  bool get canUploadCompletionImages => status.toLowerCase() == 'resolved';
  
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

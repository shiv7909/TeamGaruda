class DashboardAnalytics {
  final int totalIssues;
  final int pendingIssues;
  final int resolvedThisWeek;
  final int activeUsers;
  final int flaggedIssues;
  final int bannedUsers;

  DashboardAnalytics({
    required this.totalIssues,
    required this.pendingIssues,
    required this.resolvedThisWeek,
    required this.activeUsers,
    required this.flaggedIssues,
    required this.bannedUsers,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      totalIssues: json['total_issues'] ?? 0,
      pendingIssues: json['pending_issues'] ?? 0,
      resolvedThisWeek: json['resolved_this_week'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      flaggedIssues: json['flagged_issues'] ?? 0,
      bannedUsers: json['banned_users'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_issues': totalIssues,
      'pending_issues': pendingIssues,
      'resolved_this_week': resolvedThisWeek,
      'active_users': activeUsers,
      'flagged_issues': flaggedIssues,
      'banned_users': bannedUsers,
    };
  }
}

class CategoryAnalytics {
  final String category;
  final int count;
  final double averageResolutionTime; // in hours

  CategoryAnalytics({
    required this.category,
    required this.count,
    required this.averageResolutionTime,
  });

  factory CategoryAnalytics.fromJson(Map<String, dynamic> json) {
    return CategoryAnalytics(
      category: json['category'] ?? '',
      count: json['count'] ?? 0,
      averageResolutionTime: (json['avg_resolution_time'] ?? 0).toDouble(),
    );
  }
}

class TrendData {
  final DateTime date;
  final int reportsCount;
  final double averageResponseTime; // in hours
  final double userEngagement; // percentage
  final double spamDetection; // percentage

  TrendData({
    required this.date,
    required this.reportsCount,
    required this.averageResponseTime,
    required this.userEngagement,
    required this.spamDetection,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      reportsCount: json['reports_count'] ?? 0,
      averageResponseTime: (json['avg_response_time'] ?? 0).toDouble(),
      userEngagement: (json['user_engagement'] ?? 0).toDouble(),
      spamDetection: (json['spam_detection'] ?? 0).toDouble(),
    );
  }
}

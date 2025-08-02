import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/issue.dart';
import '../models/user.dart';
import '../models/analytics.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Test connection to Supabase
  static Future<bool> testConnection() async {
    try {
      // Try to make a simple query to test connection
      final response = await _client
          .from('profiles')
          .select('id')
          .limit(1);
      
      print('✅ Supabase connection successful!');
      print('Profiles table accessible, found ${response.length} records');
      return true;
    } catch (e) {
      print('❌ Supabase connection failed: $e');
      
      // Try to test with issues table if profiles fails
      try {
        final issuesResponse = await _client
            .from('issues')
            .select('id')
            .limit(1);
        print('✅ Issues table accessible, found ${issuesResponse.length} records');
        return true;
      } catch (e2) {
        print('❌ Issues table also failed: $e2');
        return false;
      }
    }
  }

  // Create sample data for testing
  static Future<void> createSampleData() async {
    try {
      // Insert sample profile
      final profileResponse = await _client.from('profiles').insert({
        'user_name': 'Test User',
        'email': 'test@example.com',
      }).select();

      if (profileResponse.isNotEmpty) {
        final userId = profileResponse[0]['id'];
        
        // Insert sample issue
        await _client.from('issues').insert({
          'user_id': userId,
          'title': 'Test Issue',
          'description': 'This is a test issue',
          'issue_type': 'infrastructure',
          'status': 'pending',
          'latitude': 12.9716,
          'longitude': 77.5946,
        });
        
        print('✅ Sample data created successfully!');
      }
    } catch (e) {
      print('Error creating sample data: $e');
    }
  }

  // Issues related methods
  static Future<List<Issue>> getIssues({
    String? status,
    String? category,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('issues').select('*');
      
      if (status != null && status != 'All') {
        query = query.eq('status', status.toLowerCase());
      }
      
      if (category != null && category != 'All') {
        query = query.eq('issue_type', category.toLowerCase()); // Note: your schema uses 'issue_type'
      }
      
      final response = await query.limit(limit).order('created_at', ascending: false);
      
      return (response as List).map((item) => Issue.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching issues: $e');
      return [];
    }
  }

  static Future<Map<String, int>> getIssuesByStatus() async {
    try {
      final response = await _client
          .from('issues')
          .select('status')
          .order('status');
      
      Map<String, int> statusCount = {};
      for (var item in response) {
        String status = item['status'] ?? 'unknown';
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }
      
      print('📊 Issues by status: $statusCount');
      return statusCount;
    } catch (e) {
      print('Error getting issues by status: $e');
      return {};
    }
  }

  static Future<int> getIssueCountByStatus(String status) async {
    try {
      final response = await _client
          .from('issues')
          .select('id')
          .eq('status', status) // Exact match without .toLowerCase()
          .count();
      return response.count;
    } catch (e) {
      print('Error getting issue count: $e');
      return 0;
    }
  }

  static Future<Map<String, int>> getIssuesByCategory() async {
    try {
      final response = await _client
          .from('issues')
          .select('issue_type') // Note: your schema uses 'issue_type'
          .order('issue_type');
      
      Map<String, int> categoryCount = {};
      for (var item in response) {
        String category = item['issue_type'] ?? 'Unknown'; // Note: your schema uses 'issue_type'
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
      
      return categoryCount;
    } catch (e) {
      print('Error getting issues by category: $e');
      return {};
    }
  }

  // Users related methods
  static Future<List<CivicUser>> getUsers({
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('profiles').select('*');
      
      // Note: Since your profiles table doesn't have a status field,
      // we'll need to get all profiles for now
      // You may want to add a status field to the profiles table
      
      final response = await query.limit(limit).order('created_at', ascending: false);
      
      return (response as List).map((item) => CivicUser.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  static Future<int> getUserReportCount(String userId) async {
    try {
      final response = await _client
          .from('issues')
          .select('id')
          .eq('user_id', userId)
          .count();
      return response.count;
    } catch (e) {
      print('Error getting user report count: $e');
      return 0;
    }
  }

  static Future<int> getUserCount() async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .count();
      return response.count;
    } catch (e) {
      print('Error getting user count: $e');
      return 0;
    }
  }

  static Future<int> getActiveUserCount() async {
    try {
      // Since profiles table doesn't have status, we'll count all profiles
      // You may want to add status tracking to profiles table
      final response = await _client
          .from('profiles')
          .select('id')
          .count();
      return response.count;
    } catch (e) {
      print('Error getting active user count: $e');
      return 0;
    }
  }

  // Analytics related methods
  static Future<DashboardAnalytics> getDashboardAnalytics() async {
    try {
      // Get total issues
      final totalIssues = await _client
          .from('issues')
          .select('id')
          .count();

      // Get all issues by status to see what statuses actually exist
      final statusBreakdown = await getIssuesByStatus();
      print('📊 Status breakdown: $statusBreakdown');

      // Get pending issues 
      // Current database statuses: "Report Submitted" (will become "Reported", "In Progress", "Resolved")
      int pendingIssues = 0;
      // Map current status to pending
      pendingIssues += (statusBreakdown['Report Submitted'] ?? 0).toInt();  // Current status in DB
      pendingIssues += (statusBreakdown['Reported'] ?? 0).toInt();          // Future status
      pendingIssues += (statusBreakdown['In Progress'] ?? 0).toInt();       // Future status

      // Get resolved issues this week
      final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
      int resolvedThisWeek = 0;
      try {
        // Get resolved issues from this week
        final resolvedResponse = await _client
            .from('issues')
            .select('id')
            .eq('status', 'Resolved')
            .gte('created_at', oneWeekAgo)
            .count();
        resolvedThisWeek = resolvedResponse.count;
      } catch (e) {
        print('Error getting resolved issues this week: $e');
        // Fallback: count all resolved issues (not just this week)
        resolvedThisWeek = (statusBreakdown['Resolved'] ?? 0).toInt();
      }

      // Get active users
      final activeUsers = await getActiveUserCount();

      // No flagged issues in your system (only Reported, In Progress, Resolved)
      int flaggedIssues = 0;

      // Get banned users - Note: profiles table doesn't have status field
      final bannedUsers = 0; // Placeholder since no status field exists

      print('📊 Final analytics: Total: ${totalIssues.count}, Pending: $pendingIssues, Resolved: $resolvedThisWeek, Flagged: $flaggedIssues');

      return DashboardAnalytics(
        totalIssues: totalIssues.count,
        pendingIssues: pendingIssues,
        resolvedThisWeek: resolvedThisWeek,
        activeUsers: activeUsers,
        flaggedIssues: flaggedIssues,
        bannedUsers: bannedUsers,
      );
    } catch (e) {
      print('Error getting dashboard analytics: $e');
      return DashboardAnalytics(
        totalIssues: 0,
        pendingIssues: 0,
        resolvedThisWeek: 0,
        activeUsers: 0,
        flaggedIssues: 0,
        bannedUsers: 0,
      );
    }
  }

  // Real-time subscriptions
  static Stream<List<Issue>> subscribeToIssues() {
    return _client
        .from('issues')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => Issue.fromJson(item)).toList());
  }

  static Stream<List<CivicUser>> subscribeToUsers() {
    return _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => CivicUser.fromJson(item)).toList());
  }

  // Update methods
  static Future<bool> updateIssueStatus(String issueId, String status) async {
    try {
      await _client
          .from('issues')
          .update({
            'status': status, // Use exact case for status
          })
          .eq('id', issueId);
      return true;
    } catch (e) {
      print('Error updating issue status: $e');
      return false;
    }
  }

  static Future<bool> updateUserStatus(String userId, String status) async {
    try {
      // Note: profiles table doesn't have status field in your schema
      // You may want to add a status field to profiles table or create a separate user_status table
      print('Warning: Cannot update user status - no status field in profiles table');
      return false;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/issue.dart';
import '../models/user.dart';
import '../models/analytics.dart';
import '../models/department.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get the Supabase client for real-time subscriptions
  static SupabaseClient getClient() => _client;

  // Authentication methods
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  static Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }

  static Future<String> getUserRole(String email) async {
    try {
      // Simple role check - you can expand this based on your needs
      if (email.contains('admin') || email == 'admin@teamgaruda.com') {
        return 'admin';
      }
      return 'user';
    } catch (e) {
      print('Error checking user role: $e');
      return 'user';
    }
  }

  // Test connection to Supabase
  static Future<bool> testConnection() async {
    try {
      // Try to make a simple query to test connection
      final response = await _client.from('profiles').select('id').limit(1);

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
        print(
          '✅ Issues table accessible, found ${issuesResponse.length} records',
        );
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
      final profileResponse =
          await _client.from('profiles').insert({
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
        // Keep exact case for 'Spam' status, convert others to lowercase for consistency
        String filterStatus =
            (status == 'Spam') ? 'Spam' : status.toLowerCase();
        query = query.eq('status', filterStatus);
      }

      if (category != null && category != 'All') {
        query = query.eq(
          'issue_type',
          category.toLowerCase(),
        ); // Note: your schema uses 'issue_type'
      }

      final response = await query
          .limit(limit)
          .order('created_at', ascending: false);

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
      final response =
          await _client
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
        String category =
            item['issue_type'] ??
            'Unknown'; // Note: your schema uses 'issue_type'
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
      print('📊 Fetching users from profiles table...');

      // Fetch all profiles
      var profilesQuery = _client.from('profiles').select('*');
      final profilesResponse = await profilesQuery
          .limit(limit)
          .order('created_at', ascending: false);

      print('📊 Found ${(profilesResponse as List).length} profiles');

      List<CivicUser> users = [];

      // For each profile, calculate report count and derive status
      for (var profileData in profilesResponse) {
        try {
          // Get report count for this user
          final reportCountResponse =
              await _client
                  .from('issues')
                  .select('id')
                  .eq('user_id', profileData['id'])
                  .count();

          int reportCount = reportCountResponse.count;

          // Create user object with calculated report count
          var userData = Map<String, dynamic>.from(profileData);
          userData['report_count'] = reportCount;

          // Derive status based on activity
          final user = CivicUser.fromJson(userData);

          // Simple logic to derive status based on activity
          String derivedStatus;
          final now = DateTime.now();
          final daysSinceCreation = now.difference(user.createdAt).inDays;

          if (user.reportCount > 10) {
            derivedStatus = 'active';
          } else if (user.reportCount == 0 && daysSinceCreation > 30) {
            derivedStatus = 'inactive';
          } else if (user.reportCount > 0) {
            derivedStatus = 'active';
          } else {
            derivedStatus = 'inactive';
          }

          userData['status'] = derivedStatus;

          // Create final user object with derived status
          final finalUser = CivicUser.fromJson(userData);

          // Filter by status if specified
          if (status == null ||
              status == 'All' ||
              finalUser.status.toLowerCase() == status.toLowerCase()) {
            users.add(finalUser);
          }
        } catch (e) {
          print('Error processing profile ${profileData['id']}: $e');
          // Add user with default values if error occurs
          var userData = Map<String, dynamic>.from(profileData);
          userData['report_count'] = 0;
          userData['status'] = 'inactive';
          users.add(CivicUser.fromJson(userData));
        }
      }

      print(
        '📊 Processed ${users.length} users (filtered by status: ${status ?? 'All'})',
      );
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  static Future<int> getUserReportCount(String userId) async {
    try {
      final response =
          await _client
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
      final response = await _client.from('profiles').select('id').count();
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
      final response = await _client.from('profiles').select('id').count();
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
      final totalIssues = await _client.from('issues').select('id').count();

      // Get all issues by status to see what statuses actually exist
      final statusBreakdown = await getIssuesByStatus();
      print('📊 Status breakdown: $statusBreakdown');

      // Get pending issues
      // Map new citizen-facing statuses to pending
      int pendingIssues = 0;
      pendingIssues += (statusBreakdown['reported'] ?? 0).toInt();
      pendingIssues += (statusBreakdown['under review'] ?? 0).toInt();

      // Get resolved issues this week
      final oneWeekAgo =
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
      int resolvedThisWeek = 0;
      try {
        // Get completed issues from this week
        final resolvedResponse =
            await _client
                .from('issues')
                .select('id')
                .eq('status', 'completed')
                .gte('created_at', oneWeekAgo)
                .count();
        resolvedThisWeek = resolvedResponse.count;
      } catch (e) {
        print('Error getting completed issues this week: $e');
        // Fallback: count all completed issues (not just this week)
        resolvedThisWeek = (statusBreakdown['completed'] ?? 0).toInt();
      }

      // Get active users
      final activeUsers = await getActiveUserCount();

      // No flagged issues in your system (only Reported, In Progress, Resolved)
      int flaggedIssues = 0;

      // Get banned users - Note: profiles table doesn't have status field
      final bannedUsers = 0; // Placeholder since no status field exists

      print(
        '📊 Final analytics: Total: ${totalIssues.count}, Pending: $pendingIssues, Resolved: $resolvedThisWeek, Flagged: $flaggedIssues',
      );

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

  // Department-specific analytics methods
  static Future<DashboardAnalytics> getDashboardAnalyticsByDepartment(
    String departmentName,
  ) async {
    try {
      // Get total issues for department
      final totalIssues =
          await _client
              .from('issues')
              .select('id')
              .eq('department', departmentName)
              .count();

      // Get issues by status for department
      final statusBreakdown = await getIssuesByStatusByDepartment(
        departmentName,
      );
      print('📊 Department $departmentName status breakdown: $statusBreakdown');

      // Get pending issues for department
      int pendingIssues = 0;
      pendingIssues += (statusBreakdown['reported'] ?? 0).toInt();
      pendingIssues += (statusBreakdown['under review'] ?? 0).toInt();

      // Get resolved issues this week for department
      final oneWeekAgo =
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
      int resolvedThisWeek = 0;
      try {
        final resolvedResponse =
            await _client
                .from('issues')
                .select('id')
                .eq('department', departmentName)
                .eq('status', 'completed')
                .gte('created_at', oneWeekAgo)
                .count();
        resolvedThisWeek = resolvedResponse.count;
      } catch (e) {
        print('Error getting completed issues this week for department: $e');
        resolvedThisWeek = (statusBreakdown['completed'] ?? 0).toInt();
      }

      // Get active users (same for all departments)
      final activeUsers = await getActiveUserCount();

      // No flagged issues in your system
      int flaggedIssues = 0;

      // Get banned users
      final bannedUsers = 0;

      print(
        '📊 Department $departmentName analytics: Total: ${totalIssues.count}, Pending: $pendingIssues, Resolved: $resolvedThisWeek',
      );

      return DashboardAnalytics(
        totalIssues: totalIssues.count,
        pendingIssues: pendingIssues,
        resolvedThisWeek: resolvedThisWeek,
        activeUsers: activeUsers,
        flaggedIssues: flaggedIssues,
        bannedUsers: bannedUsers,
      );
    } catch (e) {
      print(
        'Error getting dashboard analytics for department $departmentName: $e',
      );
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

  static Future<Map<String, int>> getIssuesByStatusByDepartment(
    String departmentName,
  ) async {
    try {
      final response = await _client
          .from('issues')
          .select('status')
          .eq('department', departmentName)
          .order('status');

      Map<String, int> statusCount = {};
      for (var item in response) {
        String status = item['status'] ?? 'unknown';
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }

      print('📊 Issues by status for department $departmentName: $statusCount');
      return statusCount;
    } catch (e) {
      print(
        'Error getting issues by status for department $departmentName: $e',
      );
      return {};
    }
  }

  static Future<Map<String, int>> getIssuesByCategoryByDepartment(
    String departmentName,
  ) async {
    try {
      final response = await _client
          .from('issues')
          .select('issue_type')
          .eq('department', departmentName)
          .order('issue_type');

      Map<String, int> categoryCount = {};
      for (var item in response) {
        String category = item['issue_type'] ?? 'Unknown';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      return categoryCount;
    } catch (e) {
      print(
        'Error getting issues by category for department $departmentName: $e',
      );
      return {};
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
      print(
        'Warning: Cannot update user status - no status field in profiles table',
      );
      return false;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  // Upload image to Supabase Storage
  static Future<String?> uploadImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final String path =
          'completion_images/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await _client.storage.from('issues').uploadBinary(path, imageBytes);

      // Get public URL
      final String publicUrl = _client.storage
          .from('issues')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload multiple completion images
  static Future<List<String>> uploadCompletionImages(
    List<Uint8List> imageBytesList,
    List<String> fileNames,
  ) async {
    List<String> uploadedUrls = [];

    for (int i = 0; i < imageBytesList.length; i++) {
      final String? url = await uploadImage(imageBytesList[i], fileNames[i]);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // Update issue with completion images
  static Future<bool> updateIssueCompletionImages(
    String issueId,
    List<String> completionImageUrls,
  ) async {
    try {
      await _client
          .from('issues')
          .update({'completed_image_urls': completionImageUrls})
          .eq('id', issueId);
      return true;
    } catch (e) {
      print('Error updating issue completion images: $e');
      return false;
    }
  }

  // Update issue status with restriction for completed issues
  static Future<bool> updateIssueStatusRestricted(
    String issueId,
    String newStatus,
  ) async {
    print(
      '🔄 updateIssueStatusRestricted called with issueId: $issueId, newStatus: $newStatus',
    );
    try {
      print('Updating issue $issueId to status: $newStatus');

      // First check current status
      final response =
          await _client
              .from('issues')
              .select('status')
              .eq('id', issueId)
              .single();

      final currentStatus = response['status'] as String;

      // Prevent changing status back from completed
      if (currentStatus.toLowerCase() == 'completed' &&
          newStatus.toLowerCase() != 'completed') {
        print('Cannot change status back from completed');
        return false;
      }

      // Map citizen-facing status to internal status description
      String statusDescription;
      switch (newStatus.toLowerCase()) {
        case 'reported':
          statusDescription = 'SUBMITTED';
          break;
        case 'under review':
          statusDescription = 'ACKNOWLEDGED';
          break;
        case 'in progress':
          statusDescription = 'IN_PROGRESS';
          break;
        case 'completed':
          statusDescription = 'RESOLVED';
          break;
        case 'approved':
          statusDescription = 'APPROVED';
          break;
        case 'spam':
          statusDescription = 'SPAM';
          break;
        default:
          statusDescription = 'SUBMITTED';
      }

      print(
        'Mapped status "$newStatus" to statusDescription: $statusDescription',
      );

      await _client
          .from('issues')
          .update({
            'status': newStatus,
            // 'status_description': statusDescription, // Temporarily commented out to test
          })
          .eq('id', issueId);
      print('Successfully updated issue $issueId');
      return true;
    } catch (e) {
      print('Error updating issue status: $e');
      return false;
    }
  }

  // Delete issue from database
  static Future<bool> deleteIssue(String issueId) async {
    try {
      await _client.from('issues').delete().eq('id', issueId);
      print('Successfully deleted issue $issueId');
      return true;
    } catch (e) {
      print('Error deleting issue: $e');
      return false;
    }
  }

  // Department authentication methods
  static Future<Department?> authenticateDepartment(
    String email,
    String password,
  ) async {
    try {
      // Fetch all departments from database
      final allDepartmentsResponse = await _client
          .from('departments')
          .select('*');
      final departments =
          (allDepartmentsResponse as List)
              .map((item) => Department.fromJson(item))
              .toList();

      print(
        '🔍 Checking ${departments.length} departments in table for login...',
      );
      print('📧 Looking for email: "$email"');

      // Find matching department by checking mail and pass fields
      Department? matchingDepartment;
      try {
        matchingDepartment = departments.firstWhere((dept) {
          bool emailMatch =
              dept.mail.trim().toLowerCase() == email.trim().toLowerCase();
          bool passMatch = dept.pass == password;
          print(
            '   Checking: "${dept.mail}" (${dept.department}) - Email match: $emailMatch, Pass match: $passMatch',
          );
          return emailMatch && passMatch;
        });
      } catch (e) {
        matchingDepartment = null;
      }

      if (matchingDepartment != null) {
        print(
          '✅ Login successful for ${matchingDepartment.mail} (${matchingDepartment.department})',
        );
        return matchingDepartment;
      } else {
        print('❌ No matching department found for email: $email');
        print(
          '   Available emails in table: ${departments.map((d) => d.mail).join(', ')}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error authenticating department: $e');
      return null;
    }
  }

  static Future<List<Issue>> getIssuesByDepartment(
    String departmentName, {
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = _client.from('issues').select('*');

      // Filter by department (assuming issues table has a department field)
      // If not, this will need to be modified based on your schema
      query = query.eq('department', departmentName);

      if (status != null && status != 'All') {
        // Keep exact case for 'Spam' status, convert others to lowercase for consistency
        String filterStatus =
            (status == 'Spam') ? 'Spam' : status.toLowerCase();
        query = query.eq('status', filterStatus);
      }

      final response = await query
          .limit(limit)
          .order('created_at', ascending: false);

      return (response as List).map((item) => Issue.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching issues for department $departmentName: $e');
      return [];
    }
  }

  static Future<bool> assignIssueToDepartment(
    String issueId,
    String departmentName,
  ) async {
    try {
      await _client
          .from('issues')
          .update({'department': departmentName})
          .eq('id', issueId);
      return true;
    } catch (e) {
      print('Error assigning issue $issueId to department $departmentName: $e');
      return false;
    }
  }

  static Future<Department?> getDepartmentByEmail(String email) async {
    try {
      final response =
          await _client
              .from('departments')
              .select('*')
              .eq('mail', email)
              .single();

      return Department.fromJson(response);
    } catch (e) {
      print('Error getting department by email: $e');
      return null;
    }
  }

  // Debug method to check departments in issues table
  static Future<void> debugDepartmentsInIssues() async {
    try {
      final response = await _client
          .from('issues')
          .select('department')
          .limit(100);

      final departments =
          (response as List)
              .map((item) => item['department'] as String?)
              .where((dept) => dept != null)
              .toSet();

      print('🔍 Departments found in issues table: $departments');

      // Also check departments table
      final deptResponse = await _client
          .from('departments')
          .select('department');

      final deptTableNames =
          (deptResponse as List)
              .map((item) => item['department'] as String)
              .toSet();

      print('🏢 Departments in departments table: $deptTableNames');
    } catch (e) {
      print('Error debugging departments: $e');
    }
  }

  // Fix department name mismatch
  static Future<void> fixDepartmentNameMismatch() async {
    try {
      // Update issues table to use correct department name
      await _client
          .from('issues')
          .update({'department': 'Water Supply & Sewerage'})
          .eq('department', 'Water Supply Department');

      print('✅ Fixed department name mismatch in issues table');
    } catch (e) {
      print('Error fixing department name mismatch: $e');
    }
  }
}

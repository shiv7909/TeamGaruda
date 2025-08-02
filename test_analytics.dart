import 'package:flutter/material.dart';
import 'lib/services/supabase_service.dart';
import 'lib/models/analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Testing status mapping with your exact status values...');
  print('Expected statuses: Reported, In Progress, Resolved');
  print('');
  
  // Initialize Supabase (you'll need to make sure this is called)
  // Note: This assumes your main.dart has proper Supabase initialization
  
  try {
    // Test connection first
    print('🔗 Testing Supabase connection...');
    final isConnected = await SupabaseService.testConnection();
    if (!isConnected) {
      print('❌ Failed to connect to Supabase');
      return;
    }
    print('✅ Connected to Supabase');
    print('');
    
    // Get actual status breakdown
    print('📊 Getting actual status breakdown from database...');
    final statusBreakdown = await SupabaseService.getIssuesByStatus();
    print('Status breakdown: $statusBreakdown');
    print('');
    
    // Test new analytics mapping
    print('📈 Testing updated analytics mapping...');
    final analytics = await SupabaseService.getDashboardAnalytics();
    
    print('Analytics Results:');
    print('- Total Issues: ${analytics.totalIssues}');
    print('- Pending Issues (Reported + In Progress): ${analytics.pendingIssues}');
    print('- Resolved This Week: ${analytics.resolvedThisWeek}');
    print('- Active Users: ${analytics.activeUsers}');
    print('- Flagged Issues: ${analytics.flaggedIssues}');
    print('');
    
    // Verify mapping
    int reportedCount = statusBreakdown['Reported'] ?? 0;
    int inProgressCount = statusBreakdown['In Progress'] ?? 0;
    int resolvedCount = statusBreakdown['Resolved'] ?? 0;
    
    print('✅ Mapping Verification:');
    print('- Reported: $reportedCount');
    print('- In Progress: $inProgressCount');
    print('- Resolved: $resolvedCount');
    print('- Expected Pending: ${reportedCount + inProgressCount}');
    print('- Actual Pending: ${analytics.pendingIssues}');
    print('- Mapping Correct: ${(reportedCount + inProgressCount) == analytics.pendingIssues ? "✅ YES" : "❌ NO"}');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
}

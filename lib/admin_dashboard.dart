import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'services/supabase_service.dart';
import 'models/analytics.dart';
import 'models/issue.dart';
import 'models/user.dart';

// Main Responsive Scaffold
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _testSupabaseConnection();
  }

  Future<void> _testSupabaseConnection() async {
    print('🔗 Testing Supabase connection...');

    try {
      final isConnected = await SupabaseService.testConnection();
      if (isConnected) {
        print('✅ Successfully connected to Supabase!');

        // Test loading some real data
        print('📊 Testing data loading...');
        final analytics = await SupabaseService.getDashboardAnalytics();
        print('Analytics loaded: ${analytics.totalIssues} total issues, ${analytics.activeUsers} users');

        final users = await SupabaseService.getUsers(limit: 5);
        print('Users loaded: ${users.length} users found');

        final issues = await SupabaseService.getIssues(limit: 5);
        print('Issues loaded: ${issues.length} issues found');

        // Debug: Let's see what's actually in the database
        if (issues.isNotEmpty) {
          print('🔍 Sample issue data:');
          for (int i = 0; i < issues.length && i < 3; i++) {
            final issue = issues[i];
            print('  Issue ${i + 1}: Status="${issue.status}", Type="${issue.issueType}", Title="${issue.title}"');
          }
        }

        // Debug: Check actual status values in database
        final statusBreakdown = await SupabaseService.getIssuesByStatus();
        print('📊 Actual status values in database: ${statusBreakdown.keys.toList()}');

      } else {
        print('❌ Failed to connect to Supabase. Please check your credentials and database setup.');
        print('💡 Make sure you have run the SQL commands to create the tables.');
      }
    } catch (e) {
      print('❌ Connection test error: $e');
    }
  }

  static final List<Widget> _pages = [
    const DashboardOverview(),
    const IssueManagement(),
    const Analytics(),
    const UserManagement(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isWideScreen = constraints.maxWidth >= 800;
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: isWideScreen
            ? null
            : AppBar(
          title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Color(0xFF334155)),
        ),
        drawer: null, // Remove drawer completely
        bottomNavigationBar: isWideScreen ? null : _buildBottomNavigationBar(),
        body: Row(
          children: [
            if (isWideScreen) _buildNavigationRail(),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      );
    });
  }

  BottomNavigationBar _buildBottomNavigationBar() => BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: const Color(0xFF6366F1),
    unselectedItemColor: const Color(0xFF64748B),
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
    elevation: 8,
    currentIndex: _selectedIndex,
    onTap: (index) => setState(() => _selectedIndex = index),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.report_problem_outlined),
        activeIcon: Icon(Icons.report_problem),
        label: 'Issues',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: 'Analytics',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: 'Users',
      ),
    ],
  );

  NavigationRail _buildNavigationRail() => NavigationRail(
      backgroundColor: Colors.white,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      labelType: NavigationRailLabelType.all,
      minWidth: 80,
      selectedIconTheme: const IconThemeData(color: Color(0xFF6366F1), size: 24),
      unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B), size: 22),
      selectedLabelTextStyle: const TextStyle(
        color: Color(0xFF6366F1),
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      leading: Container(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: const Column(
          children: [
            Icon(Icons.remove_red_eye, size: 32, color: Color(0xFF6366F1)),
            SizedBox(height: 8),
            Text('Third Eye', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
      destinations: const [
        NavigationRailDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard')
        ),
        NavigationRailDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem),
            label: Text('Issues')
        ),
        NavigationRailDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: Text('Analytics')
        ),
        NavigationRailDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: Text('Users')
        ),
      ]);
}

// --- OVERVIEW PAGE ---
class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  DashboardAnalytics? analytics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final data = await SupabaseService.getDashboardAnalytics();
      if (mounted) {
        setState(() {
          analytics = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading analytics: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                  'Dashboard Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  )
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (analytics != null)
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _StatCard(
                  title: 'Total Issues Reported',
                  value: '${analytics!.totalIssues}',
                  icon: Icons.report_problem,
                  color: const Color(0xFF3B82F6),
                ),
                _StatCard(
                  title: 'Pending Review',
                  value: '${analytics!.pendingIssues}',
                  icon: Icons.pending_actions,
                  color: const Color(0xFFF59E0B),
                ),
                _StatCard(
                  title: 'Resolved This Week',
                  value: '${analytics!.resolvedThisWeek}',
                  icon: Icons.check_circle,
                  color: const Color(0xFF10B981),
                ),
                _StatCard(
                  title: 'Active Users',
                  value: '${analytics!.activeUsers}',
                  icon: Icons.people_alt,
                  color: const Color(0xFF8B5CF6),
                ),
                _StatCard(
                  title: 'Flagged as Spam',
                  value: '${analytics!.flaggedIssues}',
                  icon: Icons.flag,
                  color: const Color(0xFFEF4444),
                ),
                _StatCard(
                  title: 'Banned Users',
                  value: '${analytics!.bannedUsers}',
                  icon: Icons.block,
                  color: const Color(0xFF64748B),
                ),
              ],
            )
          else
            const Center(child: Text('Failed to load analytics')),
        ],
      ),
    );
  }
}

// --- ANALYTICS PAGE (NOW STATEFUL) ---
class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  Map<String, int> issuesByCategory = {};
  Map<String, int> issuesByStatus = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        SupabaseService.getIssuesByCategory(),
        SupabaseService.getIssuesByStatus(),
      ]);

      if (mounted) {
        setState(() {
          issuesByCategory = results[0] as Map<String, int>;
          issuesByStatus = results[1] as Map<String, int>;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load chart data: $e';
          isLoading = false;
        });
      }
      print('Error loading chart data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                  'Analytics & Insights',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  )
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator()))
          else if (errorMessage != null)
            Center(child: Padding(padding: const EdgeInsets.all(48.0), child: Text(errorMessage!)))
          else
            LayoutBuilder(builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 800;
              return Column(
                children: [
                  Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: isWide ? 2 : 0,
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bar_chart, color: Colors.grey.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Issues by Category',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF334155),
                                        )
                                    ),
                                    const Spacer(),
                                    _FilterDropdown(
                                      label: 'Period',
                                      items: const ['Last 7 days', 'Last 30 days', 'Last 3 months', 'Last year'],
                                      onChanged: (value) {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(height: 300, child: _IssuesBarChart(data: issuesByCategory)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isWide) const SizedBox(width: 24),
                      if (!isWide) const SizedBox(height: 24),
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.donut_small, color: Colors.grey.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Status Overview',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF334155),
                                        )
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(height: 300, child: _IssuesDonutChart(data: issuesByStatus)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Resolution Times Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.grey.shade600, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Resolution Times',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Column(
                            children: [
                              _ResolutionTimeCard(category: 'Roads', avgTime: '2.3 days', color: Color(0xFF3B82F6)),
                              _ResolutionTimeCard(category: 'Lighting', avgTime: '1.8 days', color: Color(0xFFF59E0B)),
                              _ResolutionTimeCard(category: 'Water', avgTime: '3.1 days', color: Color(0xFF06B6D4)),
                              _ResolutionTimeCard(category: 'Cleanliness', avgTime: '1.2 days', color: Color(0xFF10B981)),
                              _ResolutionTimeCard(category: 'Safety', avgTime: '4.7 days', color: Color(0xFFEF4444)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// --- ISSUE MANAGEMENT PAGE AND WIDGETS ---
// ... This section remains unchanged ...
class IssueManagement extends StatefulWidget {
  const IssueManagement({super.key});

  @override
  State<IssueManagement> createState() => _IssueManagementState();
}

class _IssueManagementState extends State<IssueManagement> {
  List<Issue> issues = [];
  List<Issue> filteredIssues = [];
  DashboardAnalytics? analytics;
  bool isLoading = true;
  String selectedStatus = 'All';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final [issuesData, analyticsData] = await Future.wait([
        SupabaseService.getIssues(status: selectedStatus == 'All' ? null : selectedStatus),
        SupabaseService.getDashboardAnalytics(),
      ]);

      if (mounted) {
        setState(() {
          issues = issuesData as List<Issue>;
          filteredIssues = issues;
          analytics = analyticsData as DashboardAnalytics;
          isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      print('Error loading issue data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      filteredIssues = issues.where((issue) {
        bool statusMatch = selectedStatus == 'All' ||
            issue.status.toLowerCase() == selectedStatus.toLowerCase() ||
            (selectedStatus == 'Report Submitted' && issue.status.toLowerCase() == 'reported');
        bool categoryMatch = selectedCategory == 'All' ||
            issue.issueType.toLowerCase() == selectedCategory.toLowerCase();
        return statusMatch && categoryMatch;
      }).toList();
    });
  }

  Future<void> _updateIssueStatus(String issueId, String newStatus) async {
    try {
      final success = await SupabaseService.updateIssueStatusRestricted(issueId, newStatus);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Issue status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Refresh data
      } else {
        throw Exception('Cannot change status back from resolved');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.assignment, color: Color(0xFF6366F1), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Issue Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Quick Action Cards with real data
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (analytics != null)
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _QuickActionCard(
                title: 'Reported',
                count: '${issues.where((i) => i.status.toLowerCase() == 'reported').length}',
                icon: Icons.pending_actions,
                color: const Color(0xFFF59E0B),
                onTap: () {
                  setState(() {
                    selectedStatus = 'Reported';
                    _applyFilters();
                  });
                },
              ),
              _QuickActionCard(
                title: 'In Progress',
                count: '${issues.where((i) => i.status.toLowerCase() == 'in progress').length}',
                icon: Icons.engineering,
                color: const Color(0xFF3B82F6),
                onTap: () {
                  setState(() {
                    selectedStatus = 'In Progress';
                    _applyFilters();
                  });
                },
              ),
              _QuickActionCard(
                title: 'Resolved',
                count: '${issues.where((i) => i.status.toLowerCase() == 'resolved').length}',
                icon: Icons.check_circle,
                color: const Color(0xFF10B981),
                onTap: () {
                  setState(() {
                    selectedStatus = 'Resolved';
                    _applyFilters();
                  });
                },
              ),
              _QuickActionCard(
                title: 'Total Issues',
                count: '${issues.length}',
                icon: Icons.assignment,
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  setState(() {
                    selectedStatus = 'All';
                    _applyFilters();
                  });
                },
              ),
            ],
          )
        else
          const Center(child: Text('Failed to load statistics')),
        const SizedBox(height: 32),
        // Recent Issues Table - Mobile vs Desktop Layout
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 800;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list_alt, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Issues (${filteredIssues.length} of ${issues.length})',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Mobile vs Desktop Filter Layout
                    if (isMobile) ...[
                      // Mobile: Vertical stack layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FilterDropdown(
                            label: 'Status',
                            value: selectedStatus,
                            items: const ['All', 'Report Submitted', 'In Progress', 'Resolved'],
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value ?? 'All';
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _FilterDropdown(
                            label: 'Category',
                            value: selectedCategory,
                            items: const ['All', 'Road Damage', 'Water Leaks', 'Street Lighting', 'Waste Management', 'Safety Issues'],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value ?? 'All';
                                _applyFilters();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Refresh'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Desktop: Horizontal wrap layout
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          _FilterDropdown(
                            label: 'Status',
                            value: selectedStatus,
                            items: const ['All', 'Report Submitted', 'In Progress', 'Resolved'],
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value ?? 'All';
                                _applyFilters();
                              });
                            },
                          ),
                          _FilterDropdown(
                            label: 'Category',
                            value: selectedCategory,
                            items: const ['All', 'Road Damage', 'Water Leaks', 'Street Lighting', 'Waste Management', 'Safety Issues'],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value ?? 'All';
                                _applyFilters();
                              });
                            },
                          ),
                          TextButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _IssueTable(
                      issues: filteredIssues,
                      isMobile: isMobile,
                      isLoading: isLoading,
                      onStatusUpdate: _updateIssueStatus,
                      onRefresh: _loadData,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Summary Statistics Card
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Issue Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  _IssueSummaryStats(issues: filteredIssues),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ... USER MANAGEMENT PAGE AND WIDGETS (Unchanged) ...
class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  List<CivicUser> users = [];
  List<CivicUser> filteredUsers = [];
  DashboardAnalytics? analytics;
  bool isLoading = true;
  String selectedStatus = 'All';
  late Stream<List<Map<String, dynamic>>> _profilesStream;
  
  @override
  void initState() {
    super.initState();
    _setupRealtimeSubscription();
    _loadData();
  }

  void _setupRealtimeSubscription() {
    // Set up real-time subscription to profiles table
    _profilesStream = SupabaseService.getClient()
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
    
    // Listen to profile changes and refresh data
    _profilesStream.listen((profiles) {
      print('📡 Real-time update: ${profiles.length} profiles received');
      _refreshUsersData();
    });
  }

  Future<void> _refreshUsersData() async {
    // Only refresh if not currently loading to avoid conflicts
    if (!isLoading) {
      print('🔄 Refreshing users data due to real-time update...');
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      print('📊 Loading users data...');
      final [usersData, analyticsData] = await Future.wait([
        SupabaseService.getUsers(limit: 50), // Load all users first, then filter
        SupabaseService.getDashboardAnalytics(),
      ]);
      
      if (mounted) {
        setState(() {
          users = usersData as List<CivicUser>;
          analytics = analyticsData as DashboardAnalytics;
          isLoading = false;
        });
        _applyFilters(); // Apply filters after loading data
        print('✅ Users data loaded: ${users.length} users found');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      if (selectedStatus == 'All') {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((user) {
          return user.status.toLowerCase() == selectedStatus.toLowerCase();
        }).toList();
      }
    });
  }  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.people, color: Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'User Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        const SizedBox(height: 24),
        // User Stats
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _StatCard(
                title: 'Total Users',
                value: '${users.length}',
                icon: Icons.people,
                color: const Color(0xFF8B5CF6),
              ),
              _StatCard(
                title: 'Active Users',
                value: '${users.where((u) => u.status.toLowerCase() == 'active').length}',
                icon: Icons.trending_up,
                color: const Color(0xFF10B981),
              ),
              _StatCard(
                title: 'Inactive Users',
                value: '${users.where((u) => u.status.toLowerCase() == 'inactive').length}',
                icon: Icons.person_off,
                color: const Color(0xFF64748B),
              ),
              _StatCard(
                title: 'Total Reports',
                value: '${users.fold(0, (sum, user) => sum + user.reportCount)}',
                icon: Icons.report_problem,
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        const SizedBox(height: 32),
        // User Actions
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Users (${filteredUsers.length} of ${users.length})',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Responsive filter layout
                    if (isMobile) ...[
                      // Mobile: Vertical stack layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FilterDropdown(
                            label: 'Status',
                            value: selectedStatus,
                            items: const ['All', 'Active', 'Inactive', 'Flagged', 'Banned'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedStatus = value;
                                });
                                _applyFilters();
                              }
                            },
                          ),
                          
                        ],
                      ),
                    ] else ...[
                      // Desktop: Horizontal layout
                      Row(
                        children: [
                          const Spacer(),
                          _FilterDropdown(
                            label: 'Status',
                            value: selectedStatus,
                            items: const ['All', 'Active', 'Inactive', 'Flagged', 'Banned'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedStatus = value;
                                });
                                _applyFilters();
                              }
                            },
                          ),
                         
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _UserTable(
                      users: filteredUsers, 
                      isMobile: isMobile, 
                      isLoading: isLoading,
                      onRefresh: _loadData,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}


// --- CUSTOM REUSABLE WIDGETS ---
// ... This section remains unchanged ...
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              )
          ),
          const SizedBox(height: 4),
          Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              )
          ),
        ],
      ),
    );
  }
}

class _CircularStat extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  const _CircularStat({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 12,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${value.toInt()}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// --- CUSTOM CHART WIDGETS (NOW DYNAMIC) ---
class _IssuesBarChart extends StatelessWidget {
  final Map<String, int> data;
  const _IssuesBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      'Road Damage': const Color(0xFF3B82F6),
      'Water Leaks': const Color(0xFF06B6D4),
      'Street Lighting': const Color(0xFFF59E0B),
      'Waste Management': const Color(0xFF10B981),
      'Safety Issues': const Color(0xFFEF4444),
    };

    final barGroups = data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final value = entry.value.value.toDouble();
      final color = categoryColors[category] ?? Colors.grey;
      return _makeGroupData(index, value, color);
    }).toList();

    final maxYValue = data.values.isEmpty ? 50.0 : data.values.reduce((a, b) => a > b ? a : b).toDouble();
    final maxY = (maxYValue * 1.2).ceilToDouble(); // Add 20% padding to the top

    return BarChart(BarChartData(
      maxY: maxY,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => _getCategoryTitles(value, meta, data.keys.toList()),
              reservedSize: 38
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == 0 || value == maxY) return const Text('');
              return Text(
                '${value.toInt()}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY / 5).ceilToDouble(),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          );
        },
      ),
    ));
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) =>
      BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: y,
              color: color,
              width: 28,
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            )
          ]
      );

  Widget _getCategoryTitles(double value, TitleMeta meta, List<String> categories) {
    final style = TextStyle(
      color: Colors.grey.shade600,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    String text = '';
    final index = value.toInt();
    if (index >= 0 && index < categories.length) {
      text = categories[index].replaceAll(' ', '\n').replaceAll('Management', 'Mgmt.');
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 8, child: Text(text, style: style, textAlign: TextAlign.center));
  }
}

class _IssuesDonutChart extends StatelessWidget {
  final Map<String, int> data;
  const _IssuesDonutChart({required this.data});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
      case 'report submitted':
        return const Color(0xFFF59E0B);
      case 'in progress':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalIssues = data.values.fold(0, (sum, item) => sum + item);
    final sections = data.entries.map((entry) {
      final status = entry.key;
      final value = entry.value.toDouble();
      final color = _getStatusColor(status);
      final percentage = totalIssues == 0 ? 0 : (value / totalIssues) * 100;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 45,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      );
    }).toList();

    final legendItems = data.entries.map((entry) {
      final percentage = totalIssues == 0 ? 0 : (entry.value / totalIssues) * 100;
      return _buildLegendItem(entry.key, _getStatusColor(entry.key), '${percentage.toStringAsFixed(0)}%');
    }).toList();

    return Stack(
      children: [
        PieChart(PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, pieTouchResponse) {},
            enabled: true,
          ),
          sectionsSpace: 3,
          centerSpaceRadius: 70,
          startDegreeOffset: -90,
          sections: sections.isNotEmpty ? sections : [
            PieChartSectionData(
                color: Colors.grey.shade200,
                value: 1,
                title: 'No Data',
                radius: 40,
                titleStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600)
            )
          ],
        )),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$totalIssues',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Issues',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: legendItems,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

// --- ALL OTHER WIDGETS (CIVICTRACK, MOBILE-SPECIFIC, ETC.) REMAIN UNCHANGED ---
// ... The rest of your file from _QuickActionCard downwards remains the same ...

// --- CIVICTRACK SPECIFIC WIDGETS ---
class _QuickActionCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueTable extends StatelessWidget {
  final List<Issue> issues;
  final bool isMobile;
  final bool isLoading;
  final Function(String, String) onStatusUpdate;
  final VoidCallback? onRefresh;

  const _IssueTable({
    required this.issues,
    required this.isMobile,
    required this.isLoading,
    required this.onStatusUpdate,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (issues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.inbox,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No issues found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or refresh the data',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      // Mobile: Card-based layout
      return Column(
        children: issues.take(10).map((issue) => _IssueCard(
          issue: issue,
          onStatusUpdate: onStatusUpdate,
          onRefresh: onRefresh,
        )).toList(),
      );
    } else {
      // Desktop: Table layout
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          child: DataTable(
            headingRowHeight: 56,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 72,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.w600))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
            ],
            rows: issues.take(20).map((issue) => DataRow(
              cells: [
                DataCell(Text(
                  issue.id.substring(0, 8),
                  style: const TextStyle(fontFamily: 'monospace'),
                )),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      issue.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(issue.issueType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      issue.issueType,
                      style: TextStyle(
                        color: _getCategoryColor(issue.issueType),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(_StatusBadge(status: issue.status)),
                DataCell(Text(
                  _formatDate(issue.createdAt),
                  style: TextStyle(color: Colors.grey.shade600),
                )),
                DataCell(_IssueActions(
                  issue: issue,
                  onStatusUpdate: onStatusUpdate,
                  onRefresh: onRefresh,
                )),
              ],
            )).toList(),
          ),
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'road damage':
        return const Color(0xFF3B82F6);
      case 'water leaks':
        return const Color(0xFF06B6D4);
      case 'street lighting':
        return const Color(0xFFF59E0B);
      case 'waste management':
        return const Color(0xFF10B981);
      case 'safety issues':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class _IssueCard extends StatelessWidget {
  final Issue issue;
  final Function(String, String) onStatusUpdate;
  final VoidCallback? onRefresh;

  const _IssueCard({
    required this.issue,
    required this.onStatusUpdate,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    issue.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: issue.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  issue.issueType,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(issue.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (issue.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                issue.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'ID: ${issue.id.substring(0, 8)}',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                _IssueActions(
                  issue: issue,
                  onStatusUpdate: onStatusUpdate,
                  onRefresh: onRefresh,
                  isCompact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'reported':
      case 'report submitted':
        color = const Color(0xFFF59E0B);
        icon = Icons.pending_actions;
        break;
      case 'in progress':
        color = const Color(0xFF3B82F6);
        icon = Icons.engineering;
        break;
      case 'resolved':
        color = const Color(0xFF10B981);
        icon = Icons.check_circle;
        break;
      default:
        color = const Color(0xFF64748B);
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueActions extends StatelessWidget {
  final Issue issue;
  final Function(String, String) onStatusUpdate;
  final VoidCallback? onRefresh;
  final bool isCompact;

  const _IssueActions({
    required this.issue,
    required this.onStatusUpdate,
    this.onRefresh,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _showIssueDetails(context),
            icon: const Icon(Icons.visibility, size: 18),
            tooltip: 'View Details',
            color: const Color(0xFF6366F1),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, size: 20, color: Colors.grey.shade600),
            onSelected: (action) {
              if (action == 'View Details') {
                _showIssueDetails(context);
              } else {
                onStatusUpdate(issue.id, action);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'View Details',
                child: Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Color(0xFF6366F1)),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              if (issue.canModifyStatus && issue.status != 'In Progress')
                const PopupMenuItem(
                  value: 'In Progress',
                  child: Row(
                    children: [
                      Icon(Icons.engineering, size: 16, color: Color(0xFF3B82F6)),
                      SizedBox(width: 8),
                      Text('Set In Progress'),
                    ],
                  ),
                ),
              if (issue.canModifyStatus && issue.status != 'Resolved')
                const PopupMenuItem(
                  value: 'Resolved',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Color(0xFF10B981)),
                      SizedBox(width: 8),
                      Text('Mark Resolved'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showIssueDetails(context),
          icon: const Icon(Icons.visibility, size: 18),
          tooltip: 'View Details',
          color: const Color(0xFF6366F1),
        ),
        if (issue.canModifyStatus && issue.status != 'In Progress')
          IconButton(
            onPressed: () => onStatusUpdate(issue.id, 'In Progress'),
            icon: const Icon(Icons.engineering, size: 18),
            tooltip: 'Set In Progress',
            color: const Color(0xFF3B82F6),
          ),
        if (issue.canModifyStatus && issue.status != 'Resolved')
          IconButton(
            onPressed: () => onStatusUpdate(issue.id, 'Resolved'),
            icon: const Icon(Icons.check_circle, size: 18),
            tooltip: 'Mark Resolved',
            color: const Color(0xFF10B981),
          ),
      ],
    );
  }

  void _showIssueDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: const Color(0xFF6366F1),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Issue Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Title',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Issue Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _DetailItem(
                        icon: Icons.category,
                        label: 'Category',
                        value: issue.issueType,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailItem(
                        icon: _getStatusIcon(issue.status),
                        label: 'Status',
                        value: issue.status,
                        color: _getStatusColor(issue.status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _DetailItem(
                        icon: Icons.schedule,
                        label: 'Created',
                        value: _formatDetailDate(issue.createdAt),
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailItem(
                        icon: Icons.fingerprint,
                        label: 'Issue ID',
                        value: issue.id.substring(0, 8),
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),

                // Location Information
                if (issue.latitude != null && issue.longitude != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Latitude: ${issue.latitude!.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        Text(
                          'Longitude: ${issue.longitude!.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _openInMaps(issue.latitude!, issue.longitude!, context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Open in Maps',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_off,
                          color: const Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Location not available',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Description
                if (issue.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          issue.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Images Section
                if (issue.allImageUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.image,
                              color: const Color(0xFF8B5CF6),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Images (${issue.allImageUrls.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: issue.allImageUrls.length,
                            itemBuilder: (context, index) {
                              final imageUrl = issue.allImageUrls[index];
                              return Container(
                                margin: EdgeInsets.only(
                                  right: index < issue.allImageUrls.length - 1 ? 8 : 0,
                                ),
                                child: GestureDetector(
                                  onTap: () => _showImageDialog(context, imageUrl, index, issue.allImageUrls),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey.shade100,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: const Color(0xFF8B5CF6),
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade100,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey.shade400,
                                                  size: 32,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Failed to load',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Completion Images Section (for resolved issues)
                if (issue.canUploadCompletionImages) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.task_alt,
                              color: const Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Completion Images',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _showCompletionImageUpload(context, issue),
                              icon: Icon(
                                Icons.add_photo_alternate,
                                color: const Color(0xFF10B981),
                                size: 20,
                              ),
                              tooltip: 'Upload Completion Images',
                            ),
                          ],
                        ),
                        if (issue.allCompletedImageUrls.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: issue.allCompletedImageUrls.length,
                              itemBuilder: (context, index) {
                                final imageUrl = issue.allCompletedImageUrls[index];
                                return Container(
                                  margin: EdgeInsets.only(
                                    right: index < issue.allCompletedImageUrls.length - 1 ? 8 : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _showImageDialog(context, imageUrl, index, issue.allCompletedImageUrls),
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF10B981).withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              color: Colors.grey.shade100,
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: const Color(0xFF10B981),
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade100,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey.shade400,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Failed to load',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: const Color(0xFF10B981),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No completion images uploaded yet. Click the + button to add images.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          if (issue.latitude != null && issue.longitude != null)
            ElevatedButton.icon(
              onPressed: () => _openInMaps(issue.latitude!, issue.longitude!, context),
              icon: const Icon(Icons.map, size: 16),
              label: const Text('Open in Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl, int currentIndex, List<String> allImages) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            // Image display with zoom and swipe
            Container(
              width: double.infinity,
              height: double.infinity,
              child: PageView.builder(
                controller: PageController(initialPage: currentIndex),
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        allImages[index],
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            
            // Image counter (if multiple images)
            if (allImages.length > 1)
              Positioned(
                top: 40,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${currentIndex + 1} / ${allImages.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
            // Swipe indicator (if multiple images)
            if (allImages.length > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Swipe to view more images',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCompletionImageUpload(BuildContext context, Issue issue) {
    showDialog(
      context: context,
      builder: (context) => _CompletionImageUploadDialog(
        issue: issue,
        onUploadSuccess: () {
          // Call the refresh callback if available
          onRefresh?.call();
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
      case 'report submitted':
        return Icons.pending_actions;
      case 'in progress':
        return Icons.engineering;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reported':
      case 'report submitted':
        return const Color(0xFFF59E0B);
      case 'in progress':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatDetailDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }

  void _openInMaps(double latitude, double longitude, BuildContext context) async {
    // Create Google Maps URL with the coordinates
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    
    try {
      // Try to launch the URL in external browser
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: show coordinates and provide copy functionality
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location: $latitude, $longitude'),
              action: SnackBarAction(
                label: 'Copy URL',
                onPressed: () {
                  // In a real app, you'd copy to clipboard
                  print('Google Maps URL: $googleMapsUrl');
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Error handling: show coordinates as fallback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open maps. Location: $latitude, $longitude'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      print('Error opening maps: $e');
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueSummaryStats extends StatelessWidget {
  final List<Issue> issues;

  const _IssueSummaryStats({required this.issues});

  @override
  Widget build(BuildContext context) {
    final categoryStats = <String, int>{};
    final statusStats = <String, int>{};

    for (final issue in issues) {
      categoryStats[issue.issueType] = (categoryStats[issue.issueType] ?? 0) + 1;
      statusStats[issue.status] = (statusStats[issue.status] ?? 0) + 1;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatSection(
                title: 'By Category',
                stats: categoryStats,
                colorMap: {
                  'Road Damage': const Color(0xFF3B82F6),
                  'Water Leaks': const Color(0xFF06B6D4),
                  'Street Lighting': const Color(0xFFF59E0B),
                  'Waste Management': const Color(0xFF10B981),
                  'Safety Issues': const Color(0xFFEF4444),
                },
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: _StatSection(
                title: 'By Status',
                stats: statusStats,
                colorMap: {
                  'Report Submitted': const Color(0xFFF59E0B),
                  'In Progress': const Color(0xFF3B82F6),
                  'Resolved': const Color(0xFF10B981),
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatSection extends StatelessWidget {
  final String title;
  final Map<String, int> stats;
  final Map<String, Color> colorMap;

  const _StatSection({
    required this.title,
    required this.stats,
    required this.colorMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...stats.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorMap[entry.key] ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                '${entry.value}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _IssueTablePlaceholder extends StatelessWidget {
  final bool isMobile;
  const _IssueTablePlaceholder({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      // Mobile: Card-based layout
      return Column(
        children: List.generate(5, (index) => _MobileIssueCard(
          id: 'CIV-${1000 + index}',
          category: ['Roads', 'Lighting', 'Water', 'Cleanliness', 'Safety'][index],
          status: ['Pending', 'In Progress', 'Resolved', 'Flagged', 'Pending'][index],
          priority: ['High', 'Medium', 'Low', 'High', 'Medium'][index],
        )),
      );
    } else {
      // Desktop: Table layout
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Issue ID', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Category', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 3, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
              ],
            ),
          ),
          ...List.generate(5, (index) => _IssueRow(
            id: 'CIV-${1000 + index}',
            category: ['Roads', 'Lighting', 'Water', 'Cleanliness', 'Safety'][index],
            status: ['Pending', 'In Progress', 'Resolved', 'Flagged', 'Pending'][index],
            priority: ['High', 'Medium', 'Low', 'High', 'Medium'][index],
          )),
        ],
      );
    }
  }
}

class _IssueRow extends StatelessWidget {
  final String id;
  final String category;
  final String status;
  final String priority;

  const _IssueRow({
    required this.id,
    required this.category,
    required this.status,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Resolved' ? const Color(0xFF10B981) :
    status == 'In Progress' ? const Color(0xFF3B82F6) :
    status == 'Flagged' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(id, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(category, overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(priority, overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 16),
                  tooltip: 'View',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserTable extends StatelessWidget {
  final List<CivicUser> users;
  final bool isMobile;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const _UserTable({
    required this.users,
    required this.isMobile,
    required this.isLoading,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Users from the profiles table will appear here.\nReal-time updates enabled.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isMobile) {
      // Mobile: Card-based layout
      return Column(
        children: users.map((user) => _MobileUserCard(
          id: user.displayId,
          name: user.name,
          email: user.email,
          reports: user.reportCount.toString(),
          status: user.capitalizedStatus,
        )).toList(),
      );
    } else {
      // Desktop: Table layout
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('User ID', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Reports', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
              ],
            ),
          ),
          ...users.map((user) => _UserRow(
            id: user.displayId,
            name: user.name,
            email: user.email,
            reports: user.reportCount.toString(),
            status: user.capitalizedStatus,
          )),
        ],
      );
    }
  }
}

class _UserRow extends StatelessWidget {
  final String id;
  final String name;
  final String email;
  final String reports;
  final String status;

  const _UserRow({
    required this.id,
    required this.name,
    required this.email,
    required this.reports,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Active' ? const Color(0xFF10B981) :
    status == 'Inactive' ? const Color(0xFF64748B) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(id, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(name, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(email, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(reports, overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  tooltip: 'Edit User',
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    status == 'Flagged' ? Icons.block : Icons.visibility,
                    size: 16,
                    color: status == 'Flagged' ? const Color(0xFFEF4444) : null,
                  ),
                  tooltip: status == 'Flagged' ? 'Block User' : 'View User',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const _FilterDropdown({
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        isDense: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _BulkActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BulkActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolutionTimeCard extends StatelessWidget {
  final String category;
  final String avgTime;
  final Color color;

  const _ResolutionTimeCard({
    required this.category,
    required this.avgTime,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Text(
            avgTime,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileIssueCard extends StatelessWidget {
  final String id;
  final String category;
  final String status;
  final String priority;

  const _MobileIssueCard({
    required this.id,
    required this.category,
    required this.status,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Resolved' ? const Color(0xFF10B981) :
    status == 'In Progress' ? const Color(0xFF3B82F6) :
    status == 'Flagged' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(
                priority == 'High' ? Icons.priority_high :
                priority == 'Medium' ? Icons.remove : Icons.low_priority,
                size: 16,
                color: priority == 'High' ? const Color(0xFFEF4444) :
                priority == 'Medium' ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
              const SizedBox(width: 4),
              Text(
                priority,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileBulkActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MobileBulkActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileUserCard extends StatelessWidget {
  final String id;
  final String name;
  final String email;
  final String reports;
  final String status;

  const _MobileUserCard({
    required this.id,
    required this.name,
    required this.email,
    required this.reports,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Active' ? const Color(0xFF10B981) :
    status == 'Inactive' ? const Color(0xFF64748B) : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      id,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.report, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                '$reports reports',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        status == 'Flagged' ? Icons.block : Icons.visibility,
                        size: 18,
                        color: status == 'Flagged' ? const Color(0xFFEF4444) : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionImageUploadDialog extends StatefulWidget {
  final Issue issue;
  final VoidCallback? onUploadSuccess;

  const _CompletionImageUploadDialog({
    required this.issue,
    this.onUploadSuccess,
  });

  @override
  State<_CompletionImageUploadDialog> createState() => _CompletionImageUploadDialogState();
}

class _CompletionImageUploadDialogState extends State<_CompletionImageUploadDialog> {
  List<PlatformFile> selectedFiles = [];
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.task_alt,
            color: const Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Upload Completion Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload images showing the completed work for issue: ${widget.issue.title}',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            
            // File selection area
            GestureDetector(
              onTap: isUploading ? null : _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedFiles.isNotEmpty 
                        ? const Color(0xFF10B981) 
                        : Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: selectedFiles.isNotEmpty 
                      ? const Color(0xFF10B981).withOpacity(0.05)
                      : Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    Icon(
                      selectedFiles.isNotEmpty ? Icons.check_circle : Icons.add_photo_alternate,
                      size: 48,
                      color: selectedFiles.isNotEmpty 
                          ? const Color(0xFF10B981) 
                          : Colors.grey.shade500,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedFiles.isNotEmpty 
                          ? '${selectedFiles.length} image(s) selected'
                          : 'Tap to select images',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: selectedFiles.isNotEmpty 
                            ? const Color(0xFF10B981) 
                            : Colors.grey.shade600,
                      ),
                    ),
                    if (selectedFiles.isEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'All image formats supported',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Selected files preview
            if (selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Selected Images:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = selectedFiles[index];
                    return Container(
                      margin: EdgeInsets.only(right: index < selectedFiles.length - 1 ? 8 : 0),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: file.bytes != null
                                  ? Image.memory(
                                      file.bytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image,
                                          color: Colors.grey.shade500,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          file.name.length > 10 
                                              ? '${file.name.substring(0, 10)}...'
                                              : file.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Upload progress
            if (isUploading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Uploading images...',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUploading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isUploading ? Colors.grey.shade400 : const Color(0xFF64748B),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: isUploading || selectedFiles.isEmpty ? null : _uploadImages,
          icon: Icon(
            isUploading ? Icons.hourglass_empty : Icons.cloud_upload,
            size: 16,
          ),
          label: Text(isUploading ? 'Uploading...' : 'Upload'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          selectedFiles = result.files;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (selectedFiles.isEmpty) return;

    setState(() {
      isUploading = true;
    });

    try {
      // Prepare image data
      List<Uint8List> imageBytesList = [];
      List<String> fileNames = [];

      for (final file in selectedFiles) {
        if (file.bytes != null) {
          imageBytesList.add(file.bytes!);
          fileNames.add(file.name);
        }
      }

      // Upload images to Supabase Storage
      final uploadedUrls = await SupabaseService.uploadCompletionImages(imageBytesList, fileNames);

      if (uploadedUrls.isNotEmpty) {
        // Combine with existing completion images
        List<String> allCompletionUrls = List.from(widget.issue.allCompletedImageUrls);
        allCompletionUrls.addAll(uploadedUrls);

        // Update issue with new completion image URLs
        final success = await SupabaseService.updateIssueCompletionImages(
          widget.issue.id,
          allCompletionUrls,
        );

        if (success) {
          if (mounted) {
            Navigator.pop(context);
            _showSuccessSnackBar('${uploadedUrls.length} completion image(s) uploaded successfully!');
            // Call the callback to refresh the parent widget
            widget.onUploadSuccess?.call();
          }
        } else {
          throw Exception('Failed to update issue with completion images');
        }
      } else {
        throw Exception('No images were uploaded successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Main Responsive Scaffold
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

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

  Drawer _buildDrawer() => Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.remove_red_eye, size: 40, color: Colors.white),
                  SizedBox(height: 12),
                  Text('The Third Eye', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Admin Dashboard', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              )),
          const SizedBox(height: 8),
          _buildDrawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _buildDrawerItem(Icons.report_problem_outlined, 'Issues', 1),
          _buildDrawerItem(Icons.analytics_outlined, 'Analytics', 2),
          _buildDrawerItem(Icons.people_outline, 'Users', 3),
        ],
      ));

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

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color(0xFF6366F1).withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
          size: 22,
        ),
        title: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF334155),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
            )
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

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
class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

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
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: const [
              _StatCard(
                title: 'Total Issues Reported',
                value: '1,204',
                icon: Icons.report_problem,
                color: Color(0xFF3B82F6),
                trend: '+12%',
                trendUp: true,
              ),
              _StatCard(
                title: 'Pending Review',
                value: '12',
                icon: Icons.pending_actions,
                color: Color(0xFFF59E0B),
                trend: '-5%',
                trendUp: false,
              ),
              _StatCard(
                title: 'Resolved This Week',
                value: '48',
                icon: Icons.check_circle,
                color: Color(0xFF10B981),
                trend: '+8%',
                trendUp: true,
              ),
              _StatCard(
                title: 'Active Users',
                value: '352',
                icon: Icons.people_alt,
                color: Color(0xFF8B5CF6),
                trend: '+15%',
                trendUp: true,
              ),
              _StatCard(
                title: 'Flagged as Spam',
                value: '7',
                icon: Icons.flag,
                color: Color(0xFFEF4444),
                trend: '+2',
                trendUp: true,
              ),
              _StatCard(
                title: 'Banned Users',
                value: '3',
                icon: Icons.block,
                color: Color(0xFF64748B),
                trend: '0',
                trendUp: null,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
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
                        child: const Icon(Icons.trending_up, color: Color(0xFF6366F1), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                          'Key Performance Metrics',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 48,
                    runSpacing: 32,
                    alignment: WrapAlignment.center,
                    children: const [
                      _CircularStat(title: 'Resolution Rate', value: 78, color: Color(0xFF10B981)),
                      _CircularStat(title: 'Report Accuracy', value: 92, color: Color(0xFF3B82F6)),
                      _CircularStat(title: 'Spam Detection', value: 96, color: Color(0xFF6366F1)),
                      _CircularStat(title: 'User Satisfaction', value: 89, color: Color(0xFF8B5CF6)),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- ANALYTICS PAGE ---
class Analytics extends StatelessWidget {
  const Analytics({super.key});

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
          LayoutBuilder(builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 800;
            return Column(
              children: [
                // Charts Row
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
                              SizedBox(height: 300, child: _IssuesBarChart()),
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
                              SizedBox(height: 300, child: _IssuesDonutChart()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Analytics Cards Row - Mobile vs Desktop
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    
                    if (isMobile) {
                      // Mobile: Vertical stack
                      return Column(
                        children: [
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, color: Colors.grey.shade600, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Resolution Times',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Column(
                                    children: [
                                      _ResolutionTimeCard(category: 'Roads', avgTime: '2.3 days', color: const Color(0xFF3B82F6)),
                                      _ResolutionTimeCard(category: 'Lighting', avgTime: '1.8 days', color: const Color(0xFFF59E0B)),
                                      _ResolutionTimeCard(category: 'Water', avgTime: '3.1 days', color: const Color(0xFF06B6D4)),
                                      _ResolutionTimeCard(category: 'Cleanliness', avgTime: '1.2 days', color: const Color(0xFF10B981)),
                                      _ResolutionTimeCard(category: 'Safety', avgTime: '4.7 days', color: const Color(0xFFEF4444)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Geographic Distribution',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF334155),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.map, size: 40, color: Color(0xFF64748B)),
                                          SizedBox(height: 8),
                                          Text('Heat Map', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                          Text('Location density', style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Desktop: Side-by-side layout
                      return Row(
                        children: [
                          Expanded(
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
                                    Column(
                                      children: [
                                        _ResolutionTimeCard(category: 'Roads', avgTime: '2.3 days', color: const Color(0xFF3B82F6)),
                                        _ResolutionTimeCard(category: 'Lighting', avgTime: '1.8 days', color: const Color(0xFFF59E0B)),
                                        _ResolutionTimeCard(category: 'Water', avgTime: '3.1 days', color: const Color(0xFF06B6D4)),
                                        _ResolutionTimeCard(category: 'Cleanliness', avgTime: '1.2 days', color: const Color(0xFF10B981)),
                                        _ResolutionTimeCard(category: 'Safety', avgTime: '4.7 days', color: const Color(0xFFEF4444)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
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
                                        Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Geographic Distribution',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.map, size: 48, color: Color(0xFF64748B)),
                                            SizedBox(height: 8),
                                            Text('Heat Map', style: TextStyle(fontWeight: FontWeight.w600)),
                                            Text('Issues by location density'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Real-time Analytics
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
                            Icon(Icons.trending_up, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Real-time Trends',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                                  SizedBox(width: 4),
                                  Text('Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 24,
                          runSpacing: 16,
                          children: const [
                            _TrendCard(
                              title: 'Reports Today',
                              value: '47',
                              change: '+12%',
                              isPositive: true,
                              icon: Icons.today,
                            ),
                            _TrendCard(
                              title: 'Avg Response Time',
                              value: '2.4h',
                              change: '-8%',
                              isPositive: true,
                              icon: Icons.timer,
                            ),
                            _TrendCard(
                              title: 'User Engagement',
                              value: '89%',
                              change: '+5%',
                              isPositive: true,
                              icon: Icons.people,
                            ),
                            _TrendCard(
                              title: 'Spam Detection',
                              value: '96%',
                              change: '+2%',
                              isPositive: true,
                              icon: Icons.security,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Placeholder pages for other sections - Enhanced for CivicTrack
class IssueManagement extends StatelessWidget {
  const IssueManagement({super.key});
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
          ],
        ),
        const SizedBox(height: 24),
        // Quick Action Cards
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _QuickActionCard(
              title: 'Pending Review',
              count: '12',
              icon: Icons.pending_actions,
              color: const Color(0xFFF59E0B),
              onTap: () {},
            ),
            _QuickActionCard(
              title: 'Flagged Reports',
              count: '7',
              icon: Icons.flag,
              color: const Color(0xFFEF4444),
              onTap: () {},
            ),
            _QuickActionCard(
              title: 'High Priority',
              count: '23',
              icon: Icons.priority_high,
              color: const Color(0xFF8B5CF6),
              onTap: () {},
            ),
            _QuickActionCard(
              title: 'Overdue Issues',
              count: '5',
              icon: Icons.schedule,
              color: const Color(0xFF64748B),
              onTap: () {},
            ),
          ],
        ),
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
                            'Recent Reports',
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
                            items: const ['All', 'Pending', 'In Progress', 'Resolved', 'Flagged'],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 12),
                          _FilterDropdown(
                            label: 'Category',
                            items: const ['All', 'Roads', 'Lighting', 'Water', 'Cleanliness', 'Safety', 'Obstructions'],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {},
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
                            items: const ['All', 'Pending', 'In Progress', 'Resolved', 'Flagged'],
                            onChanged: (value) {},
                          ),
                          _FilterDropdown(
                            label: 'Category',
                            items: const ['All', 'Roads', 'Lighting', 'Water', 'Cleanliness', 'Safety', 'Obstructions'],
                            onChanged: (value) {},
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _IssueTablePlaceholder(isMobile: isMobile),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Map and Bulk Actions - Mobile vs Desktop Layout
        LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;
            
            if (isMobile) {
              // Mobile: Vertical stack layout
              return Column(
                children: [
                  // Geographic Overview Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.map, color: Colors.grey.shade600, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Geographic Overview',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Mobile filter chips - centered
                          Center(
                            child: Wrap(
                              spacing: 8,
                              children: [
                                _FilterChip(label: '1km', isSelected: false, onTap: () {}),
                                _FilterChip(label: '3km', isSelected: true, onTap: () {}),
                                _FilterChip(label: '5km', isSelected: false, onTap: () {}),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map, size: 40, color: Color(0xFF64748B)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Interactive Map',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'GPS issue locations',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bulk Actions Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bulk Actions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mobile: 2-column grid for actions
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 3,
                            children: [
                              _MobileBulkActionButton(
                                icon: Icons.check_circle,
                                label: 'Resolve',
                                color: const Color(0xFF10B981),
                                onTap: () {},
                              ),
                              _MobileBulkActionButton(
                                icon: Icons.work,
                                label: 'In Progress',
                                color: const Color(0xFF3B82F6),
                                onTap: () {},
                              ),
                              _MobileBulkActionButton(
                                icon: Icons.flag,
                                label: 'Flag Spam',
                                color: const Color(0xFFEF4444),
                                onTap: () {},
                              ),
                              _MobileBulkActionButton(
                                icon: Icons.priority_high,
                                label: 'High Priority',
                                color: const Color(0xFFF59E0B),
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: _MobileBulkActionButton(
                              icon: Icons.assignment,
                              label: 'Assign to Team',
                              color: const Color(0xFF8B5CF6),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Desktop: Side-by-side layout (existing)
              return Row(
                children: [
                  Expanded(
                    flex: 2,
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
                                Icon(Icons.map, color: Colors.grey.shade600, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Geographic Overview',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Move filter chips to separate row to prevent overflow
                            Row(
                              children: [
                                const Spacer(),
                                _FilterChip(label: '1km', isSelected: false, onTap: () {}),
                                const SizedBox(width: 8),
                                _FilterChip(label: '3km', isSelected: true, onTap: () {}),
                                const SizedBox(width: 8),
                                _FilterChip(label: '5km', isSelected: false, onTap: () {}),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map, size: 48, color: Color(0xFF64748B)),
                                    SizedBox(height: 12),
                                    Text(
                                      'Interactive Map View',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Shows issue locations with GPS coordinates',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
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
                            Text(
                              'Bulk Actions',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _BulkActionButton(
                              icon: Icons.check_circle,
                              label: 'Mark as Resolved',
                              color: const Color(0xFF10B981),
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            _BulkActionButton(
                              icon: Icons.work,
                              label: 'Set In Progress',
                              color: const Color(0xFF3B82F6),
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            _BulkActionButton(
                              icon: Icons.flag,
                              label: 'Flag as Spam',
                              color: const Color(0xFFEF4444),
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            _BulkActionButton(
                              icon: Icons.priority_high,
                              label: 'Set High Priority',
                              color: const Color(0xFFF59E0B),
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            _BulkActionButton(
                              icon: Icons.assignment,
                              label: 'Assign to Team',
                              color: const Color(0xFF8B5CF6),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    ),
  );
}

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});
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
          ],
        ),
        const SizedBox(height: 24),
        // User Stats
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: const [
            _StatCard(
              title: 'Total Users',
              value: '1,847',
              icon: Icons.people,
              color: Color(0xFF8B5CF6),
              trend: '+23',
              trendUp: true,
            ),
            _StatCard(
              title: 'Active This Month',
              value: '1,234',
              icon: Icons.trending_up,
              color: Color(0xFF10B981),
              trend: '+15%',
              trendUp: true,
            ),
            _StatCard(
              title: 'Banned Users',
              value: '3',
              icon: Icons.block,
              color: Color(0xFFEF4444),
              trend: '0',
              trendUp: null,
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
                            'User Management',
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
                            items: const ['All', 'Active', 'Inactive', 'Flagged', 'Banned'],
                            onChanged: (value) {},
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.person_add, size: 16),
                              label: const Text('Add Admin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                              ),
                            ),
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
                            items: const ['All', 'Active', 'Inactive', 'Flagged', 'Banned'],
                            onChanged: (value) {},
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.person_add, size: 16),
                            label: const Text('Add Admin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _UserTablePlaceholder(isMobile: isMobile),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // User Analytics and Verification - Mobile vs Desktop Layout
        LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 800;
            
            if (isMobile) {
              // Mobile: Vertical stack layout
              return Column(
                children: [
                  // User Verification Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.grey.shade600, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'User Verification Status',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _VerificationCard(
                                title: 'Verified Users',
                                count: '1,234',
                                percentage: 67,
                                color: const Color(0xFF10B981),
                              ),
                              const SizedBox(height: 12),
                              _VerificationCard(
                                title: 'Anonymous Reports',
                                count: '589',
                                percentage: 33,
                                color: const Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Moderation Actions Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.admin_panel_settings, color: Colors.grey.shade600, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Moderation Actions',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _ModerationAction(
                            icon: Icons.visibility,
                            label: 'Review Flagged Users',
                            count: '5',
                            color: const Color(0xFFF59E0B),
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _ModerationAction(
                            icon: Icons.block,
                            label: 'Ban User',
                            count: '',
                            color: const Color(0xFFEF4444),
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _ModerationAction(
                            icon: Icons.restore,
                            label: 'Restore User',
                            count: '',
                            color: const Color(0xFF10B981),
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _ModerationAction(
                            icon: Icons.verified_user,
                            label: 'Verify User',
                            count: '',
                            color: const Color(0xFF3B82F6),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // Desktop: Side-by-side layout
              return Row(
                children: [
                  Expanded(
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
                            Text(
                              'User Verification Status',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _VerificationCard(
                                    title: 'Verified Users',
                                    count: '1,234',
                                    percentage: 67,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _VerificationCard(
                                    title: 'Anonymous Reports',
                                    count: '589',
                                    percentage: 33,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
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
                            Text(
                              'Moderation Actions',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ModerationAction(
                              icon: Icons.visibility,
                              label: 'Review Flagged Users',
                              count: '5',
                              color: const Color(0xFFF59E0B),
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            _ModerationAction(
                              icon: Icons.block,
                              label: 'Ban User',
                              count: '',
                              color: const Color(0xFFEF4444),
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            _ModerationAction(
                              icon: Icons.restore,
                              label: 'Restore User',
                              count: '',
                              color: const Color(0xFF10B981),
                              onTap: () {},
                            ),
                            const SizedBox(height: 12),
                            _ModerationAction(
                              icon: Icons.verified_user,
                              label: 'Verify User',
                              count: '',
                              color: const Color(0xFF3B82F6),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ],
    ),
  );
}


// --- CUSTOM REUSABLE WIDGETS ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
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
              const Spacer(),
              if (trend != null) ...[
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trendUp == true ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp == true ? Icons.trending_up : Icons.trending_down,
                          size: 12,
                          color: trendUp == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            trend!,
                            style: TextStyle(
                              color: trendUp == true ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

// --- CUSTOM CHART WIDGETS ---

class _IssuesBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(BarChartData(
      maxY: 50,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _getCategoryTitles,
                reservedSize: 38
            )
        ),
        leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            )
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: _getBarGroups(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          );
        },
      ),
    ));
  }

  List<BarChartGroupData> _getBarGroups() => [
    _makeGroupData(0, 45, const Color(0xFF3B82F6)),
    _makeGroupData(1, 32, const Color(0xFFF59E0B)),
    _makeGroupData(2, 28, const Color(0xFF06B6D4)),
    _makeGroupData(3, 38, const Color(0xFF10B981)),
    _makeGroupData(4, 15, const Color(0xFFEF4444)),
  ];

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

  Widget _getCategoryTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.grey.shade600,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    String text;
    switch (value.toInt()) {
      case 0: text = 'Roads'; break;
      case 1: text = 'Lighting'; break;
      case 2: text = 'Water'; break;
      case 3: text = 'Cleanliness'; break;
      case 4: text = 'Safety'; break;
      default: text = '';
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 16, child: Text(text, style: style));
  }
}

class _IssuesDonutChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          sections: [
            PieChartSectionData(
              color: const Color(0xFF10B981),
              value: 65,
              title: '',
              radius: 40,
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            PieChartSectionData(
              color: const Color(0xFFF59E0B),
              value: 25,
              title: '',
              radius: 40,
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            PieChartSectionData(
              color: const Color(0xFFEF4444),
              value: 10,
              title: '',
              radius: 40,
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
          ],
        )),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '100%',
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Resolved', const Color(0xFF10B981), '65%'),
              _buildLegendItem('In Progress', const Color(0xFFF59E0B), '25%'),
              _buildLegendItem('Pending', const Color(0xFFEF4444), '10%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String percentage) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

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

class _UserTablePlaceholder extends StatelessWidget {
  final bool isMobile;
  const _UserTablePlaceholder({this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      // Mobile: Card-based layout
      return Column(
        children: List.generate(5, (index) => _MobileUserCard(
          id: 'USR-${2000 + index}',
          name: ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Wilson', 'Tom Brown'][index],
          reports: '${12 + index * 3}',
          status: ['Active', 'Active', 'Inactive', 'Active', 'Flagged'][index],
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
                Expanded(flex: 2, child: Text('User ID', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Reports', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                Expanded(flex: 2, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
              ],
            ),
          ),
          ...List.generate(5, (index) => _UserRow(
            id: 'USR-${2000 + index}',
            name: ['John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Wilson', 'Tom Brown'][index],
            reports: '${12 + index * 3}',
            status: ['Active', 'Active', 'Inactive', 'Active', 'Flagged'][index],
          )),
        ],
      );
    }
  }
}

class _UserRow extends StatelessWidget {
  final String id;
  final String name;
  final String reports;
  final String status;

  const _UserRow({
    required this.id,
    required this.name,
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
                  tooltip: status == 'Flagged' ? 'Ban User' : 'View Profile',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- ENHANCED UI COMPONENTS FOR CIVICTRACK ---

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final Function(String?) onChanged;

  const _FilterDropdown({
    required this.label,
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

class _VerificationCard extends StatelessWidget {
  final String title;
  final String count;
  final int percentage;
  final Color color;

  const _VerificationCard({
    required this.title,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModerationAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const _ModerationAction({
    required this.icon,
    required this.label,
    required this.count,
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
            ),
            if (count.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _TrendCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const _TrendCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- MOBILE-SPECIFIC WIDGETS ---

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
  final String reports;
  final String status;

  const _MobileUserCard({
    required this.id,
    required this.name,
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
                      id,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
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
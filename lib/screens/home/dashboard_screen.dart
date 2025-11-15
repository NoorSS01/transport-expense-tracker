import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../providers/daily_entry_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../daily_entry/add_entry_screen.dart';
import '../monthly_stats/monthly_stats_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dailyEntryProvider = Provider.of<DailyEntryProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await Future.wait([
        dailyEntryProvider.loadEntries(authProvider.user!.id),
        dailyEntryProvider.loadTodayEntry(authProvider.user!.id),
      ]);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ProfitTracker'),
                if (authProvider.userProfile?.fullName != null)
                  Text(
                    'Hello, ${authProvider.userProfile!.fullName!.split(' ').first}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.barChart3),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MonthlyStatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Summary Card
              _buildTodaySummaryCard(),
              
              const SizedBox(height: 16),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: 24),
              
              // Monthly Overview
              _buildMonthlyOverview(),
              
              const SizedBox(height: 24),
              
              // Recent Entries
              _buildRecentEntries(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEntryScreen()),
          ).then((_) => _loadData());
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Entry'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTodaySummaryCard() {
    return Consumer<DailyEntryProvider>(
      builder: (context, dailyEntryProvider, child) {
        final todayEntry = dailyEntryProvider.todayEntry;
        final today = DateFormat('EEEE, MMM d').format(DateTime.now());
        
        return Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: todayEntry != null && todayEntry.isProfitable
                  ? AppTheme.successGradient
                  : (todayEntry != null 
                      ? AppTheme.errorGradient 
                      : AppTheme.primaryGradient),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      today,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Icon(
                      todayEntry != null 
                          ? (todayEntry.isProfitable 
                              ? LucideIcons.trendingUp 
                              : LucideIcons.trendingDown)
                          : LucideIcons.calendar,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (todayEntry != null) ...[
                  Text(
                    todayEntry.isProfitable ? 'Profit Today' : 'Loss Today',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    '₹${todayEntry.netProfit.abs().toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTodayMetric(
                          'Distance',
                          '${todayEntry.kilometersRun.toStringAsFixed(0)} km',
                        ),
                      ),
                      Expanded(
                        child: _buildTodayMetric(
                          'Revenue',
                          '₹${todayEntry.totalRevenue.toStringAsFixed(0)}',
                        ),
                      ),
                      Expanded(
                        child: _buildTodayMetric(
                          'Expenses',
                          '₹${todayEntry.totalExpenses.toStringAsFixed(0)}',
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'No Entry Today',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    'Add your kilometers',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  CustomButton(
                    text: 'Add Today\'s Entry',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddEntryScreen()),
                      ).then((_) => _loadData());
                    },
                    backgroundColor: Colors.white,
                    textColor: AppTheme.primaryColor,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: LucideIcons.plus,
                title: 'Add Entry',
                subtitle: 'Log today\'s kilometers',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddEntryScreen()),
                  ).then((_) => _loadData());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: LucideIcons.barChart3,
                title: 'View Stats',
                subtitle: 'Monthly performance',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MonthlyStatsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    return Consumer<DailyEntryProvider>(
      builder: (context, dailyEntryProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Month',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MonthlyStatsScreen()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMonthlyMetricCard(
                    'Total Revenue',
                    '₹${dailyEntryProvider.monthlyRevenue.toStringAsFixed(0)}',
                    LucideIcons.trendingUp,
                    AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMonthlyMetricCard(
                    'Total Profit',
                    '₹${dailyEntryProvider.monthlyProfit.toStringAsFixed(0)}',
                    dailyEntryProvider.monthlyProfit >= 0 
                        ? LucideIcons.trendingUp 
                        : LucideIcons.trendingDown,
                    dailyEntryProvider.monthlyProfit >= 0 
                        ? AppTheme.secondaryColor 
                        : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMonthlyMetricCard(
                    'Working Days',
                    '${dailyEntryProvider.workingDaysThisMonth}',
                    LucideIcons.calendar,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMonthlyMetricCard(
                    'Avg Daily Profit',
                    '₹${dailyEntryProvider.averageDailyProfit.toStringAsFixed(0)}',
                    LucideIcons.target,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntries() {
    return Consumer<DailyEntryProvider>(
      builder: (context, dailyEntryProvider, child) {
        final recentEntries = dailyEntryProvider.getLastNDaysEntries(7);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Entries',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            
            if (recentEntries.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 48,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Start by adding your first daily entry',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...recentEntries.take(5).map((entry) => _buildEntryCard(entry)),
          ],
        );
      },
    );
  }

  Widget _buildEntryCard(entry) {
    final date = DateFormat('MMM d, yyyy').format(entry.date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: entry.isProfitable 
                    ? AppTheme.secondaryColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                entry.isProfitable 
                    ? LucideIcons.trendingUp 
                    : LucideIcons.trendingDown,
                color: entry.isProfitable 
                    ? AppTheme.secondaryColor 
                    : AppTheme.errorColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${entry.kilometersRun.toStringAsFixed(0)} km • ₹${entry.totalRevenue.toStringAsFixed(0)} revenue',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${entry.netProfit.abs().toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: entry.isProfitable 
                        ? AppTheme.secondaryColor 
                        : AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  entry.isProfitable ? 'Profit' : 'Loss',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: entry.isProfitable 
                        ? AppTheme.secondaryColor 
                        : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

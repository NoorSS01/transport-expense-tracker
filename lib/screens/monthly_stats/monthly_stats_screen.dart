import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/daily_entry_provider.dart';
import '../../utils/theme.dart';

class MonthlyStatsScreen extends StatefulWidget {
  const MonthlyStatsScreen({super.key});

  @override
  State<MonthlyStatsScreen> createState() => _MonthlyStatsScreenState();
}

class _MonthlyStatsScreenState extends State<MonthlyStatsScreen> {
  DateTime _selectedMonth = DateTime.now();
  int _selectedChartIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dailyEntryProvider = Provider.of<DailyEntryProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await dailyEntryProvider.loadMonthlyEntries(authProvider.user!.id, _selectedMonth);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
    _loadMonthlyData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Statistics'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            _buildMonthSelector(),
            
            const SizedBox(height: 24),
            
            // Summary Cards
            _buildSummaryCards(),
            
            const SizedBox(height: 24),
            
            // Chart Section
            _buildChartSection(),
            
            const SizedBox(height: 24),
            
            // Daily Breakdown
            _buildDailyBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final monthYear = DateFormat('MMMM yyyy').format(_selectedMonth);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: const Icon(LucideIcons.chevronLeft),
            ),
            Text(
              monthYear,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: const Icon(LucideIcons.chevronRight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<DailyEntryProvider>(
      builder: (context, dailyEntryProvider, child) {
        final entries = dailyEntryProvider.entries;
        
        if (entries.isEmpty) {
          return Card(
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
                      'No data for this month',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Start adding daily entries to see statistics',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final totalRevenue = entries.fold(0.0, (sum, entry) => sum + entry.totalRevenue);
        final totalExpenses = entries.fold(0.0, (sum, entry) => sum + entry.totalExpenses);
        final totalProfit = totalRevenue - totalExpenses;
        final totalKilometers = entries.fold(0.0, (sum, entry) => sum + entry.kilometersRun);
        final workingDays = entries.length;
        final profitableDays = entries.where((e) => e.isProfitable).length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Revenue',
                    '₹${totalRevenue.toStringAsFixed(0)}',
                    LucideIcons.trendingUp,
                    AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Profit',
                    '₹${totalProfit.toStringAsFixed(0)}',
                    totalProfit >= 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                    totalProfit >= 0 ? AppTheme.secondaryColor : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Distance',
                    '${totalKilometers.toStringAsFixed(0)} km',
                    LucideIcons.navigation,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Working Days',
                    '$workingDays days',
                    LucideIcons.calendar,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Avg Daily Profit',
                    '₹${workingDays > 0 ? (totalProfit / workingDays).toStringAsFixed(0) : '0'}',
                    LucideIcons.target,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Profitable Days',
                    '$profitableDays/$workingDays',
                    LucideIcons.checkCircle,
                    AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildChartSection() {
    return Consumer<DailyEntryProvider>(
      builder: (context, dailyEntryProvider, child) {
        final entries = dailyEntryProvider.entries;
        
        if (entries.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Charts',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Chart Type Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChartTypeButton('Profit Trend', 0),
                  const SizedBox(width: 8),
                  _buildChartTypeButton('Revenue vs Expenses', 1),
                  const SizedBox(width: 8),
                  _buildChartTypeButton('Daily Distance', 2),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 250,
                  child: _buildChart(entries),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartTypeButton(String title, int index) {
    final isSelected = _selectedChartIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List entries) {
    switch (_selectedChartIndex) {
      case 0:
        return _buildProfitTrendChart(entries);
      case 1:
        return _buildRevenueExpensesChart(entries);
      case 2:
        return _buildDistanceChart(entries);
      default:
        return _buildProfitTrendChart(entries);
    }
  }

  Widget _buildProfitTrendChart(List entries) {
    final sortedEntries = List.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.netProfit);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${value.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  return Text(
                    DateFormat('d').format(sortedEntries[index].date),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueExpensesChart(List entries) {
    final sortedEntries = List.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final revenueSpots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalRevenue);
    }).toList();

    final expenseSpots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalExpenses);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${value.toInt()}',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  return Text(
                    DateFormat('d').format(sortedEntries[index].date),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: revenueSpots,
            isCurved: true,
            color: AppTheme.secondaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: AppTheme.errorColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceChart(List entries) {
    final sortedEntries = List.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.kilometersRun);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}km',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedEntries.length) {
                  return Text(
                    DateFormat('d').format(sortedEntries[index].date),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.warningColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.warningColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdown() {
    return Consumer<DailyEntryProvider>(
      builder: (context, dailyEntryProvider, child) {
        final entries = dailyEntryProvider.entries;
        
        if (entries.isEmpty) return const SizedBox.shrink();

        final sortedEntries = List.from(entries)
          ..sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Breakdown',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            ...sortedEntries.map((entry) => _buildDailyEntryCard(entry)),
          ],
        );
      },
    );
  }

  Widget _buildDailyEntryCard(entry) {
    final date = DateFormat('MMM d, yyyy').format(entry.date);
    final dayName = DateFormat('EEEE').format(entry.date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: entry.isProfitable 
                        ? AppTheme.secondaryColor.withOpacity(0.1)
                        : AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '₹${entry.netProfit.abs().toStringAsFixed(0)} ${entry.isProfitable ? 'Profit' : 'Loss'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: entry.isProfitable 
                          ? AppTheme.secondaryColor 
                          : AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn('Distance', '${entry.kilometersRun.toStringAsFixed(0)} km'),
                ),
                Expanded(
                  child: _buildMetricColumn('Revenue', '₹${entry.totalRevenue.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: _buildMetricColumn('Expenses', '₹${entry.totalExpenses.toStringAsFixed(0)}'),
                ),
                Expanded(
                  child: _buildMetricColumn('Margin', '${entry.profitMargin.toStringAsFixed(1)}%'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

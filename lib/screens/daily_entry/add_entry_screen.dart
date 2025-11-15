import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../providers/daily_entry_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kilometersController = TextEditingController();
  
  bool _isCalculating = false;
  double? _calculatedRevenue;
  double? _calculatedFuelCost;
  double? _calculatedDailyEmi;
  double? _calculatedDailyExpenses;
  double? _calculatedNetProfit;

  @override
  void initState() {
    super.initState();
    _loadExistingEntry();
  }

  void _loadExistingEntry() {
    final dailyEntryProvider = Provider.of<DailyEntryProvider>(context, listen: false);
    if (dailyEntryProvider.todayEntry != null) {
      _kilometersController.text = dailyEntryProvider.todayEntry!.kilometersRun.toString();
      _calculateProfit();
    }
  }

  @override
  void dispose() {
    _kilometersController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final vehicleConfig = userDataProvider.vehicleConfig;
    
    if (vehicleConfig == null) return;
    
    final kilometers = double.tryParse(_kilometersController.text);
    if (kilometers == null || kilometers <= 0) {
      setState(() {
        _calculatedRevenue = null;
        _calculatedFuelCost = null;
        _calculatedDailyEmi = null;
        _calculatedDailyExpenses = null;
        _calculatedNetProfit = null;
      });
      return;
    }

    setState(() {
      _calculatedRevenue = kilometers * vehicleConfig.earningsPerKm;
      _calculatedFuelCost = kilometers * vehicleConfig.fuelCostPerKm;
      _calculatedDailyEmi = vehicleConfig.dailyEmi;
      _calculatedDailyExpenses = vehicleConfig.dailyExpenses;
      _calculatedNetProfit = _calculatedRevenue! - _calculatedFuelCost! - _calculatedDailyEmi! - _calculatedDailyExpenses!;
    });
  }

  Future<void> _handleSaveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final dailyEntryProvider = Provider.of<DailyEntryProvider>(context, listen: false);

    if (authProvider.user == null || userDataProvider.vehicleConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save entry. Please check your configuration.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    final kilometers = double.parse(_kilometersController.text);
    final success = await dailyEntryProvider.addDailyEntry(
      userId: authProvider.user!.id,
      kilometers: kilometers,
      vehicleConfig: userDataProvider.vehicleConfig!,
    );

    setState(() {
      _isCalculating = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dailyEntryProvider.todayEntry?.isProfitable == true
                ? 'Entry saved! You made a profit today 🎉'
                : 'Entry saved! Review your expenses to improve profit.',
          ),
          backgroundColor: dailyEntryProvider.todayEntry?.isProfitable == true
              ? AppTheme.secondaryColor
              : AppTheme.warningColor,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dailyEntryProvider.errorMessage ?? 'Failed to save entry'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Daily Entry'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      today,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Kilometers Input
              CustomTextField(
                controller: _kilometersController,
                label: 'Kilometers Traveled Today',
                hintText: 'Enter kilometers',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(LucideIcons.route),
                suffixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('km'),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (_) => _calculateProfit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter kilometers traveled';
                  }
                  final km = double.tryParse(value);
                  if (km == null || km <= 0) {
                    return 'Please enter valid kilometers';
                  }
                  if (km > 1000) {
                    return 'Please enter a reasonable distance';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Calculation Results
              if (_calculatedRevenue != null) ...[
                Text(
                  'Profit Calculation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                _buildCalculationCard(),
                
                const SizedBox(height: 24),
                
                // Net Profit Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: _calculatedNetProfit! >= 0 
                        ? AppTheme.successGradient 
                        : AppTheme.errorGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _calculatedNetProfit! >= 0 ? 'Profit Today' : 'Loss Today',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${_calculatedNetProfit!.abs().toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _calculatedNetProfit! >= 0 
                            ? 'Great job! You\'re making profit today 🎉'
                            : 'Consider optimizing routes or reducing expenses',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
              
              // Save Button
              CustomButton(
                text: Consumer<DailyEntryProvider>(
                  builder: (context, provider, child) {
                    return provider.hasTodayEntry ? 'Update Entry' : 'Save Entry';
                  },
                ),
                onPressed: _calculatedRevenue != null && !_isCalculating 
                    ? _handleSaveEntry 
                    : null,
                isLoading: _isCalculating,
              ),
              
              const SizedBox(height: 16),
              
              // Vehicle Config Info
              Consumer<UserDataProvider>(
                builder: (context, userDataProvider, child) {
                  final config = userDataProvider.vehicleConfig;
                  if (config == null) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Configuration',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildConfigRow('Earnings per km', '₹${config.earningsPerKm}'),
                        _buildConfigRow('Fuel cost per km', '₹${config.fuelCostPerKm.toStringAsFixed(2)}'),
                        _buildConfigRow('Daily EMI', '₹${config.dailyEmi.toStringAsFixed(0)}'),
                        _buildConfigRow('Daily expenses', '₹${config.dailyExpenses.toStringAsFixed(0)}'),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalculationRow(
              'Revenue',
              '₹${_calculatedRevenue!.toStringAsFixed(0)}',
              LucideIcons.trendingUp,
              AppTheme.secondaryColor,
              isPositive: true,
            ),
            const Divider(),
            _buildCalculationRow(
              'Fuel Cost',
              '₹${_calculatedFuelCost!.toStringAsFixed(0)}',
              LucideIcons.fuel,
              AppTheme.errorColor,
              isPositive: false,
            ),
            _buildCalculationRow(
              'Daily EMI',
              '₹${_calculatedDailyEmi!.toStringAsFixed(0)}',
              LucideIcons.creditCard,
              AppTheme.errorColor,
              isPositive: false,
            ),
            _buildCalculationRow(
              'Other Expenses',
              '₹${_calculatedDailyExpenses!.toStringAsFixed(0)}',
              LucideIcons.receipt,
              AppTheme.errorColor,
              isPositive: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(
    String label,
    String amount,
    IconData icon,
    Color color, {
    required bool isPositive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}$amount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

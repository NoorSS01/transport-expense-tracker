import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/dashboard_screen.dart';

class VehicleSetupScreen extends StatefulWidget {
  const VehicleSetupScreen({super.key});

  @override
  State<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends State<VehicleSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _mileageController = TextEditingController();
  final _earningsController = TextEditingController();
  final _emiController = TextEditingController();
  final _expensesController = TextEditingController();
  final _fuelPriceController = TextEditingController();

  String _selectedVehicleType = 'truck';
  int _currentStep = 0;

  final List<String> _vehicleTypes = [
    'truck',
    'taxi',
    'auto',
    'bus',
    'tempo',
    'other',
  ];

  final Map<String, IconData> _vehicleIcons = {
    'truck': LucideIcons.truck,
    'taxi': LucideIcons.car,
    'auto': LucideIcons.car,
    'bus': LucideIcons.bus,
    'tempo': LucideIcons.truck,
    'other': LucideIcons.car,
  };

  @override
  void initState() {
    super.initState();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    _mileageController.text = '15';
    _earningsController.text = '25';
    _emiController.text = '0';
    _expensesController.text = '1000';
    _fuelPriceController.text = '100';
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _mileageController.dispose();
    _earningsController.dispose();
    _emiController.dispose();
    _expensesController.dispose();
    _fuelPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final success = await userDataProvider.saveVehicleConfig(
      userId: authProvider.user!.id,
      vehicleType: _selectedVehicleType,
      vehicleNumber: _vehicleNumberController.text.trim().isEmpty 
          ? null 
          : _vehicleNumberController.text.trim(),
      mileage: double.parse(_mileageController.text),
      earningsPerKm: double.parse(_earningsController.text),
      monthlyEmi: double.parse(_emiController.text),
      monthlyExpenses: double.parse(_expensesController.text),
      currentFuelPrice: double.parse(_fuelPriceController.text),
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Setup'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep 
                            ? AppTheme.primaryColor 
                            : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: _buildStepContent(),
                ),
              ),
            ),
            
            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: CustomButton(
                        text: 'Previous',
                        onPressed: _previousStep,
                        isOutlined: true,
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<UserDataProvider>(
                      builder: (context, userDataProvider, child) {
                        return CustomButton(
                          text: _currentStep < 2 ? 'Next' : 'Complete Setup',
                          onPressed: userDataProvider.isLoading 
                              ? null 
                              : (_currentStep < 2 ? _nextStep : _handleSaveConfiguration),
                          isLoading: userDataProvider.isLoading,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVehicleTypeStep();
      case 1:
        return _buildVehicleDetailsStep();
      case 2:
        return _buildFinancialDetailsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVehicleTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Vehicle Type',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the type of vehicle you use for transport business',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _vehicleTypes.length,
          itemBuilder: (context, index) {
            final vehicleType = _vehicleTypes[index];
            final isSelected = _selectedVehicleType == vehicleType;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVehicleType = vehicleType;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _vehicleIcons[vehicleType],
                      size: 40,
                      color: isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicleType.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVehicleDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Details',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your vehicle specifications for accurate calculations',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        
        CustomTextField(
          controller: _vehicleNumberController,
          label: 'Vehicle Number (Optional)',
          hintText: 'e.g., MH 12 AB 1234',
          textCapitalization: TextCapitalization.characters,
          prefixIcon: const Icon(LucideIcons.hash),
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _mileageController,
          label: 'Mileage (km/liter)',
          hintText: 'Enter vehicle mileage',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(LucideIcons.gauge),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter mileage';
            }
            final mileage = double.tryParse(value);
            if (mileage == null || mileage <= 0) {
              return 'Please enter a valid mileage';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _earningsController,
          label: 'Earnings per Kilometer (₹)',
          hintText: 'Enter earnings per km',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(LucideIcons.indianRupee),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter earnings per km';
            }
            final earnings = double.tryParse(value);
            if (earnings == null || earnings <= 0) {
              return 'Please enter valid earnings';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _fuelPriceController,
          label: 'Current Fuel Price (₹/liter)',
          hintText: 'Enter current fuel price',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(LucideIcons.fuel),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter fuel price';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Please enter valid fuel price';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFinancialDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Details',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your monthly expenses for accurate profit calculations',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        
        CustomTextField(
          controller: _emiController,
          label: 'Monthly EMI (₹)',
          hintText: 'Enter monthly EMI amount',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(LucideIcons.creditCard),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter EMI amount (enter 0 if no EMI)';
            }
            final emi = double.tryParse(value);
            if (emi == null || emi < 0) {
              return 'Please enter valid EMI amount';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _expensesController,
          label: 'Other Monthly Expenses (₹)',
          hintText: 'Insurance, maintenance, etc.',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(LucideIcons.receipt),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter monthly expenses';
            }
            final expenses = double.tryParse(value);
            if (expenses == null || expenses < 0) {
              return 'Please enter valid expense amount';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Cost Breakdown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCostRow('Daily EMI', '₹${(double.tryParse(_emiController.text) ?? 0) / 30}'),
              _buildCostRow('Daily Expenses', '₹${(double.tryParse(_expensesController.text) ?? 0) / 30}'),
              _buildCostRow('Fuel per km', '₹${(double.tryParse(_fuelPriceController.text) ?? 0) / (double.tryParse(_mileageController.text) ?? 1)}'),
            ],
          ),
        ),
        
        // Error Message
        Consumer<UserDataProvider>(
          builder: (context, userDataProvider, child) {
            if (userDataProvider.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        color: AppTheme.errorColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userDataProvider.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, String value) {
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

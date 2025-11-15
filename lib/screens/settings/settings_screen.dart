import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_data_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _mileageController = TextEditingController();
  final _earningsController = TextEditingController();
  final _emiController = TextEditingController();
  final _expensesController = TextEditingController();
  final _fuelPriceController = TextEditingController();

  String _selectedVehicleType = 'truck';
  bool _isEditing = false;

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
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final config = userDataProvider.vehicleConfig;
    
    if (config != null) {
      _selectedVehicleType = config.vehicleType;
      _vehicleNumberController.text = config.vehicleNumber ?? '';
      _mileageController.text = config.mileage.toString();
      _earningsController.text = config.earningsPerKm.toString();
      _emiController.text = config.monthlyEmi.toString();
      _expensesController.text = config.monthlyExpenses.toString();
      _fuelPriceController.text = config.currentFuelPrice.toString();
    }
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

  Future<void> _handleSaveSettings() async {
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
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated successfully'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(LucideIcons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            _buildProfileSection(),
            
            const SizedBox(height: 32),
            
            // Vehicle Configuration
            _buildVehicleConfigSection(),
            
            const SizedBox(height: 32),
            
            // App Settings
            _buildAppSettingsSection(),
            
            const SizedBox(height: 32),
            
            // Sign Out Button
            CustomButton(
              text: 'Sign Out',
              onPressed: _handleSignOut,
              backgroundColor: AppTheme.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final profile = authProvider.userProfile;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    profile?.fullName?.substring(0, 1).toUpperCase() ?? 
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                if (profile?.fullName != null)
                  Text(
                    profile!.fullName!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleConfigSection() {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vehicle Configuration',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (_isEditing)
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                            });
                            _loadCurrentSettings();
                          },
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        CustomButton(
                          text: 'Save',
                          onPressed: userDataProvider.isLoading ? null : _handleSaveSettings,
                          isLoading: userDataProvider.isLoading,
                          width: 80,
                          height: 36,
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Vehicle Type
              if (_isEditing) ...[
                Text(
                  'Vehicle Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _vehicleTypes.map((type) {
                    final isSelected = _selectedVehicleType == type;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVehicleType = type;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppTheme.primaryColor 
                              : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                                ? AppTheme.primaryColor 
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _vehicleIcons[type],
                              size: 16,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected 
                                    ? Colors.white 
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
              ] else ...[
                _buildReadOnlyField('Vehicle Type', _selectedVehicleType.toUpperCase()),
              ],
              
              // Vehicle Number
              CustomTextField(
                controller: _vehicleNumberController,
                label: 'Vehicle Number',
                hintText: 'e.g., MH 12 AB 1234',
                enabled: _isEditing,
                readOnly: !_isEditing,
                textCapitalization: TextCapitalization.characters,
                prefixIcon: const Icon(LucideIcons.hash),
              ),
              
              const SizedBox(height: 16),
              
              // Mileage
              CustomTextField(
                controller: _mileageController,
                label: 'Mileage (km/liter)',
                hintText: 'Enter vehicle mileage',
                enabled: _isEditing,
                readOnly: !_isEditing,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(LucideIcons.gauge),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: _isEditing ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mileage';
                  }
                  final mileage = double.tryParse(value);
                  if (mileage == null || mileage <= 0) {
                    return 'Please enter a valid mileage';
                  }
                  return null;
                } : null,
              ),
              
              const SizedBox(height: 16),
              
              // Earnings per KM
              CustomTextField(
                controller: _earningsController,
                label: 'Earnings per Kilometer (₹)',
                hintText: 'Enter earnings per km',
                enabled: _isEditing,
                readOnly: !_isEditing,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(LucideIcons.indianRupee),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: _isEditing ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter earnings per km';
                  }
                  final earnings = double.tryParse(value);
                  if (earnings == null || earnings <= 0) {
                    return 'Please enter valid earnings';
                  }
                  return null;
                } : null,
              ),
              
              const SizedBox(height: 16),
              
              // Fuel Price
              CustomTextField(
                controller: _fuelPriceController,
                label: 'Current Fuel Price (₹/liter)',
                hintText: 'Enter current fuel price',
                enabled: _isEditing,
                readOnly: !_isEditing,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(LucideIcons.fuel),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: _isEditing ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fuel price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter valid fuel price';
                  }
                  return null;
                } : null,
              ),
              
              const SizedBox(height: 16),
              
              // Monthly EMI
              CustomTextField(
                controller: _emiController,
                label: 'Monthly EMI (₹)',
                hintText: 'Enter monthly EMI amount',
                enabled: _isEditing,
                readOnly: !_isEditing,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(LucideIcons.creditCard),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: _isEditing ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter EMI amount (enter 0 if no EMI)';
                  }
                  final emi = double.tryParse(value);
                  if (emi == null || emi < 0) {
                    return 'Please enter valid EMI amount';
                  }
                  return null;
                } : null,
              ),
              
              const SizedBox(height: 16),
              
              // Monthly Expenses
              CustomTextField(
                controller: _expensesController,
                label: 'Other Monthly Expenses (₹)',
                hintText: 'Insurance, maintenance, etc.',
                enabled: _isEditing,
                readOnly: !_isEditing,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(LucideIcons.receipt),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: _isEditing ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly expenses';
                  }
                  final expenses = double.tryParse(value);
                  if (expenses == null || expenses < 0) {
                    return 'Please enter valid expense amount';
                  }
                  return null;
                } : null,
              ),
              
              // Error Message
              if (userDataProvider.errorMessage != null)
                Padding(
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
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAppSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(LucideIcons.info),
                title: const Text('About'),
                subtitle: const Text('App version and information'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'ProfitTracker',
                    applicationVersion: '1.0.0',
                    applicationIcon: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    children: [
                      const Text('A simple yet powerful mobile app for transport owners to track daily profit and expenses.'),
                    ],
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(LucideIcons.helpCircle),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help and contact support'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  // TODO: Implement help screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help & Support coming soon'),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(LucideIcons.shield),
                title: const Text('Privacy Policy'),
                subtitle: const Text('View privacy policy'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  // TODO: Implement privacy policy screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy Policy coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/vehicle_config.dart';
import '../models/daily_entry.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // User Profile Operations
  Future<UserProfile> createUserProfile(String userId, String email, String? fullName) async {
    final now = DateTime.now();
    final data = {
      'id': userId,
      'email': email,
      'full_name': fullName,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabase
        .from('user_profiles')
        .insert(data)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> getUserProfile(String userId) async {
    final response = await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    final data = profile.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('user_profiles')
        .update(data)
        .eq('id', profile.id)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  // Vehicle Configuration Operations
  Future<VehicleConfig> createVehicleConfig({
    required String userId,
    required String vehicleType,
    String? vehicleNumber,
    required double mileage,
    required double earningsPerKm,
    required double monthlyEmi,
    required double monthlyExpenses,
    required double currentFuelPrice,
  }) async {
    final now = DateTime.now();
    final data = {
      'user_id': userId,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'mileage': mileage,
      'earnings_per_km': earningsPerKm,
      'monthly_emi': monthlyEmi,
      'monthly_expenses': monthlyExpenses,
      'current_fuel_price': currentFuelPrice,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final response = await _supabase
        .from('vehicle_configs')
        .insert(data)
        .select()
        .single();

    return VehicleConfig.fromJson(response);
  }

  Future<VehicleConfig> getVehicleConfig(String userId) async {
    final response = await _supabase
        .from('vehicle_configs')
        .select()
        .eq('user_id', userId)
        .single();

    return VehicleConfig.fromJson(response);
  }

  Future<VehicleConfig> updateVehicleConfig(VehicleConfig config) async {
    final data = config.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('vehicle_configs')
        .update(data)
        .eq('id', config.id)
        .select()
        .single();

    return VehicleConfig.fromJson(response);
  }

  // Daily Entry Operations
  Future<DailyEntry> createDailyEntry({
    required String userId,
    required DateTime date,
    required double kilometers,
    required VehicleConfig vehicleConfig,
  }) async {
    final now = DateTime.now();
    
    final entry = DailyEntry.calculateFromKilometers(
      id: '', // Will be set by database
      userId: userId,
      date: date,
      kilometers: kilometers,
      earningsPerKm: vehicleConfig.earningsPerKm,
      fuelCostPerKm: vehicleConfig.fuelCostPerKm,
      dailyEmi: vehicleConfig.dailyEmi,
      dailyExpenses: vehicleConfig.dailyExpenses,
      createdAt: now,
      updatedAt: now,
    );

    final data = entry.toJson();
    data.remove('id'); // Let database generate ID
    data['created_at'] = now.toIso8601String();
    data['updated_at'] = now.toIso8601String();

    final response = await _supabase
        .from('daily_entries')
        .insert(data)
        .select()
        .single();

    return DailyEntry.fromJson(response);
  }

  Future<DailyEntry> getDailyEntry(String userId, DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    
    final response = await _supabase
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .eq('date', dateString)
        .single();

    return DailyEntry.fromJson(response);
  }

  Future<List<DailyEntry>> getDailyEntries(String userId) async {
    final response = await _supabase
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => DailyEntry.fromJson(json))
        .toList();
  }

  Future<List<DailyEntry>> getMonthlyEntries(String userId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final startDate = startOfMonth.toIso8601String().split('T')[0];
    final endDate = endOfMonth.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('daily_entries')
        .select()
        .eq('user_id', userId)
        .gte('date', startDate)
        .lte('date', endDate)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => DailyEntry.fromJson(json))
        .toList();
  }

  Future<DailyEntry> updateDailyEntry(DailyEntry entry) async {
    final data = entry.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('daily_entries')
        .update(data)
        .eq('id', entry.id)
        .select()
        .single();

    return DailyEntry.fromJson(response);
  }

  Future<void> deleteDailyEntry(String entryId) async {
    await _supabase
        .from('daily_entries')
        .delete()
        .eq('id', entryId);
  }

  // Analytics and Statistics
  Future<Map<String, dynamic>> getMonthlyStats(String userId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final startDate = startOfMonth.toIso8601String().split('T')[0];
    final endDate = endOfMonth.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('daily_entries')
        .select('total_revenue, fuel_cost, daily_emi_cost, daily_expenses, net_profit, kilometers_run')
        .eq('user_id', userId)
        .gte('date', startDate)
        .lte('date', endDate);

    final entries = response as List;
    
    if (entries.isEmpty) {
      return {
        'total_revenue': 0.0,
        'total_expenses': 0.0,
        'total_profit': 0.0,
        'total_kilometers': 0.0,
        'working_days': 0,
        'average_daily_profit': 0.0,
      };
    }

    double totalRevenue = 0.0;
    double totalExpenses = 0.0;
    double totalProfit = 0.0;
    double totalKilometers = 0.0;

    for (final entry in entries) {
      totalRevenue += (entry['total_revenue'] as num).toDouble();
      totalExpenses += (entry['fuel_cost'] as num).toDouble() +
                      (entry['daily_emi_cost'] as num).toDouble() +
                      (entry['daily_expenses'] as num).toDouble();
      totalProfit += (entry['net_profit'] as num).toDouble();
      totalKilometers += (entry['kilometers_run'] as num).toDouble();
    }

    return {
      'total_revenue': totalRevenue,
      'total_expenses': totalExpenses,
      'total_profit': totalProfit,
      'total_kilometers': totalKilometers,
      'working_days': entries.length,
      'average_daily_profit': entries.isNotEmpty ? totalProfit / entries.length : 0.0,
    };
  }
}

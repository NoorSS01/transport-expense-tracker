import 'package:flutter/material.dart';
import '../models/daily_entry.dart';
import '../models/vehicle_config.dart';
import '../services/database_service.dart';

class DailyEntryProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<DailyEntry> _entries = [];
  DailyEntry? _todayEntry;
  bool _isLoading = false;
  String? _errorMessage;

  List<DailyEntry> get entries => _entries;
  DailyEntry? get todayEntry => _todayEntry;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTodayEntry => _todayEntry != null;

  // Monthly statistics
  double get monthlyRevenue => _entries
      .where((e) => _isCurrentMonth(e.date))
      .fold(0.0, (sum, entry) => sum + entry.totalRevenue);

  double get monthlyExpenses => _entries
      .where((e) => _isCurrentMonth(e.date))
      .fold(0.0, (sum, entry) => sum + entry.totalExpenses);

  double get monthlyProfit => monthlyRevenue - monthlyExpenses;

  double get monthlyKilometers => _entries
      .where((e) => _isCurrentMonth(e.date))
      .fold(0.0, (sum, entry) => sum + entry.kilometersRun);

  int get workingDaysThisMonth => _entries
      .where((e) => _isCurrentMonth(e.date))
      .length;

  double get averageDailyProfit => workingDaysThisMonth > 0 
      ? monthlyProfit / workingDaysThisMonth 
      : 0.0;

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  Future<void> loadEntries(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _entries = await _databaseService.getDailyEntries(userId);
      _loadTodayEntry();
    } catch (e) {
      _setError('Failed to load daily entries');
      debugPrint('Error loading entries: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTodayEntry(String userId) async {
    try {
      _clearError();

      final today = DateTime.now();
      _todayEntry = await _databaseService.getDailyEntry(userId, today);
      notifyListeners();
    } catch (e) {
      // Today's entry doesn't exist yet, which is normal
      _todayEntry = null;
      notifyListeners();
    }
  }

  void _loadTodayEntry() {
    final today = DateTime.now();
    _todayEntry = _entries.firstWhere(
      (entry) => _isSameDay(entry.date, today),
      orElse: () => null as DailyEntry,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<bool> addDailyEntry({
    required String userId,
    required double kilometers,
    required VehicleConfig vehicleConfig,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final today = DateTime.now();
      
      // Check if entry already exists for today
      if (_todayEntry != null) {
        return await updateDailyEntry(kilometers, vehicleConfig);
      }

      final entry = await _databaseService.createDailyEntry(
        userId: userId,
        date: today,
        kilometers: kilometers,
        vehicleConfig: vehicleConfig,
      );

      _entries.add(entry);
      _todayEntry = entry;
      
      return true;
    } catch (e) {
      _setError('Failed to add daily entry');
      debugPrint('Error adding daily entry: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDailyEntry(double kilometers, VehicleConfig vehicleConfig) async {
    if (_todayEntry == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updatedEntry = DailyEntry.calculateFromKilometers(
        id: _todayEntry!.id,
        userId: _todayEntry!.userId,
        date: _todayEntry!.date,
        kilometers: kilometers,
        earningsPerKm: vehicleConfig.earningsPerKm,
        fuelCostPerKm: vehicleConfig.fuelCostPerKm,
        dailyEmi: vehicleConfig.dailyEmi,
        dailyExpenses: vehicleConfig.dailyExpenses,
        createdAt: _todayEntry!.createdAt,
        updatedAt: DateTime.now(),
      );

      final updated = await _databaseService.updateDailyEntry(updatedEntry);
      
      // Update in local list
      final index = _entries.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _entries[index] = updated;
      }
      
      _todayEntry = updated;
      
      return true;
    } catch (e) {
      _setError('Failed to update daily entry');
      debugPrint('Error updating daily entry: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMonthlyEntries(String userId, DateTime month) async {
    try {
      _setLoading(true);
      _clearError();

      _entries = await _databaseService.getMonthlyEntries(userId, month);
    } catch (e) {
      _setError('Failed to load monthly entries');
      debugPrint('Error loading monthly entries: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<DailyEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return _entries.where((entry) {
      return entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
             entry.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<DailyEntry> getLastNDaysEntries(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _entries.where((entry) => entry.date.isAfter(cutoffDate)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void reset() {
    _entries = [];
    _todayEntry = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

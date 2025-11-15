import 'package:flutter/material.dart';
import '../models/vehicle_config.dart';
import '../services/database_service.dart';

class UserDataProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  VehicleConfig? _vehicleConfig;
  bool _isLoading = false;
  String? _errorMessage;

  VehicleConfig? get vehicleConfig => _vehicleConfig;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasVehicleConfig => _vehicleConfig != null;

  Future<void> loadVehicleConfig(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _vehicleConfig = await _databaseService.getVehicleConfig(userId);
    } catch (e) {
      _setError('Failed to load vehicle configuration');
      debugPrint('Error loading vehicle config: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveVehicleConfig({
    required String userId,
    required String vehicleType,
    String? vehicleNumber,
    required double mileage,
    required double earningsPerKm,
    required double monthlyEmi,
    required double monthlyExpenses,
    required double currentFuelPrice,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_vehicleConfig == null) {
        // Create new config
        _vehicleConfig = await _databaseService.createVehicleConfig(
          userId: userId,
          vehicleType: vehicleType,
          vehicleNumber: vehicleNumber,
          mileage: mileage,
          earningsPerKm: earningsPerKm,
          monthlyEmi: monthlyEmi,
          monthlyExpenses: monthlyExpenses,
          currentFuelPrice: currentFuelPrice,
        );
      } else {
        // Update existing config
        _vehicleConfig = await _databaseService.updateVehicleConfig(
          _vehicleConfig!.copyWith(
            vehicleType: vehicleType,
            vehicleNumber: vehicleNumber,
            mileage: mileage,
            earningsPerKm: earningsPerKm,
            monthlyEmi: monthlyEmi,
            monthlyExpenses: monthlyExpenses,
            currentFuelPrice: currentFuelPrice,
            updatedAt: DateTime.now(),
          ),
        );
      }

      return true;
    } catch (e) {
      _setError('Failed to save vehicle configuration');
      debugPrint('Error saving vehicle config: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateFuelPrice(double newPrice) async {
    if (_vehicleConfig == null) return false;

    try {
      _setLoading(true);
      _clearError();

      _vehicleConfig = await _databaseService.updateVehicleConfig(
        _vehicleConfig!.copyWith(
          currentFuelPrice: newPrice,
          updatedAt: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _setError('Failed to update fuel price');
      debugPrint('Error updating fuel price: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEarningsPerKm(double newEarnings) async {
    if (_vehicleConfig == null) return false;

    try {
      _setLoading(true);
      _clearError();

      _vehicleConfig = await _databaseService.updateVehicleConfig(
        _vehicleConfig!.copyWith(
          earningsPerKm: newEarnings,
          updatedAt: DateTime.now(),
        ),
      );

      return true;
    } catch (e) {
      _setError('Failed to update earnings per km');
      debugPrint('Error updating earnings per km: $e');
      return false;
    } finally {
      _setLoading(false);
    }
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
    _vehicleConfig = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}

class VehicleConfig {
  final String id;
  final String userId;
  final String vehicleType; // truck, taxi, auto, etc.
  final String? vehicleNumber;
  final double mileage; // km per liter
  final double earningsPerKm; // rupees per km
  final double monthlyEmi; // monthly EMI amount
  final double monthlyExpenses; // other monthly expenses
  final double currentFuelPrice; // rupees per liter
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleConfig({
    required this.id,
    required this.userId,
    required this.vehicleType,
    this.vehicleNumber,
    required this.mileage,
    required this.earningsPerKm,
    required this.monthlyEmi,
    required this.monthlyExpenses,
    required this.currentFuelPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleConfig.fromJson(Map<String, dynamic> json) {
    return VehicleConfig(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      vehicleType: json['vehicle_type'] as String,
      vehicleNumber: json['vehicle_number'] as String?,
      mileage: (json['mileage'] as num).toDouble(),
      earningsPerKm: (json['earnings_per_km'] as num).toDouble(),
      monthlyEmi: (json['monthly_emi'] as num).toDouble(),
      monthlyExpenses: (json['monthly_expenses'] as num).toDouble(),
      currentFuelPrice: (json['current_fuel_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'mileage': mileage,
      'earnings_per_km': earningsPerKm,
      'monthly_emi': monthlyEmi,
      'monthly_expenses': monthlyExpenses,
      'current_fuel_price': currentFuelPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Calculate daily EMI impact
  double get dailyEmi => monthlyEmi / 30;

  // Calculate daily other expenses impact
  double get dailyExpenses => monthlyExpenses / 30;

  // Calculate fuel cost per km
  double get fuelCostPerKm => currentFuelPrice / mileage;

  VehicleConfig copyWith({
    String? id,
    String? userId,
    String? vehicleType,
    String? vehicleNumber,
    double? mileage,
    double? earningsPerKm,
    double? monthlyEmi,
    double? monthlyExpenses,
    double? currentFuelPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      mileage: mileage ?? this.mileage,
      earningsPerKm: earningsPerKm ?? this.earningsPerKm,
      monthlyEmi: monthlyEmi ?? this.monthlyEmi,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      currentFuelPrice: currentFuelPrice ?? this.currentFuelPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

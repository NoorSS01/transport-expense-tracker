class DailyEntry {
  final String id;
  final String userId;
  final DateTime date;
  final double kilometersRun;
  final double totalRevenue;
  final double fuelCost;
  final double dailyEmiCost;
  final double dailyExpenses;
  final double netProfit;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.kilometersRun,
    required this.totalRevenue,
    required this.fuelCost,
    required this.dailyEmiCost,
    required this.dailyExpenses,
    required this.netProfit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      kilometersRun: (json['kilometers_run'] as num).toDouble(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      fuelCost: (json['fuel_cost'] as num).toDouble(),
      dailyEmiCost: (json['daily_emi_cost'] as num).toDouble(),
      dailyExpenses: (json['daily_expenses'] as num).toDouble(),
      netProfit: (json['net_profit'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0], // Date only
      'kilometers_run': kilometersRun,
      'total_revenue': totalRevenue,
      'fuel_cost': fuelCost,
      'daily_emi_cost': dailyEmiCost,
      'daily_expenses': dailyExpenses,
      'net_profit': netProfit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Calculate total expenses
  double get totalExpenses => fuelCost + dailyEmiCost + dailyExpenses;

  // Check if it's a profitable day
  bool get isProfitable => netProfit > 0;

  // Get profit margin percentage
  double get profitMargin => totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

  DailyEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? kilometersRun,
    double? totalRevenue,
    double? fuelCost,
    double? dailyEmiCost,
    double? dailyExpenses,
    double? netProfit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      kilometersRun: kilometersRun ?? this.kilometersRun,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      fuelCost: fuelCost ?? this.fuelCost,
      dailyEmiCost: dailyEmiCost ?? this.dailyEmiCost,
      dailyExpenses: dailyExpenses ?? this.dailyExpenses,
      netProfit: netProfit ?? this.netProfit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory method to create a daily entry from vehicle config and kilometers
  static DailyEntry calculateFromKilometers({
    required String id,
    required String userId,
    required DateTime date,
    required double kilometers,
    required double earningsPerKm,
    required double fuelCostPerKm,
    required double dailyEmi,
    required double dailyExpenses,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final totalRevenue = kilometers * earningsPerKm;
    final fuelCost = kilometers * fuelCostPerKm;
    final netProfit = totalRevenue - fuelCost - dailyEmi - dailyExpenses;

    return DailyEntry(
      id: id,
      userId: userId,
      date: date,
      kilometersRun: kilometers,
      totalRevenue: totalRevenue,
      fuelCost: fuelCost,
      dailyEmiCost: dailyEmi,
      dailyExpenses: dailyExpenses,
      netProfit: netProfit,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

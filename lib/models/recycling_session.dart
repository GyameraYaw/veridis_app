import 'bottle_item.dart';

export 'bottle_item.dart';

enum MaterialType { plastic, glass, unknown }

// Earnings rate per kg
const double kPlasticRateGhs = 0.30;
const double kGlassRateGhs = 0.20;

// CO2 saved per kg
const double kPlasticCo2PerKg = 2.5;
const double kGlassCo2PerKg = 0.5;

class RecyclingSession {
  final String id;
  final String machineId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<BottleItem> bottles;

  const RecyclingSession({
    required this.id,
    required this.machineId,
    required this.startTime,
    this.endTime,
    required this.bottles,
  });

  // Computed totals derived from the bottles list
  double get totalWeight =>
      bottles.fold(0.0, (sum, b) => sum + b.weightKg);

  double get totalEarnings =>
      bottles.fold(0.0, (sum, b) => sum + b.earnings);

  double get totalCo2Saved =>
      bottles.fold(0.0, (sum, b) => sum + b.co2Saved);

  int get bottleCount => bottles.length;

  // Returns a copy with the session marked as ended
  RecyclingSession end() => RecyclingSession(
        id: id,
        machineId: machineId,
        startTime: startTime,
        endTime: DateTime.now(),
        bottles: bottles,
      );

  // --- Static helpers used throughout the app ---

  static double earningsFor(MaterialType type, double kg) {
    switch (type) {
      case MaterialType.plastic:
        return double.parse((kg * kPlasticRateGhs).toStringAsFixed(2));
      case MaterialType.glass:
        return double.parse((kg * kGlassRateGhs).toStringAsFixed(2));
      case MaterialType.unknown:
        return 0.0;
    }
  }

  static double co2For(MaterialType type, double kg) {
    switch (type) {
      case MaterialType.plastic:
        return double.parse((kg * kPlasticCo2PerKg).toStringAsFixed(2));
      case MaterialType.glass:
        return double.parse((kg * kGlassCo2PerKg).toStringAsFixed(2));
      case MaterialType.unknown:
        return 0.0;
    }
  }
}

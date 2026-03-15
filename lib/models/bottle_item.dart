import 'recycling_session.dart';

/// Represents one bottle dropped during a recycling session.
/// A session contains a list of these.
class BottleItem {
  final MaterialType materialType;
  final double weightKg;
  final double earnings;
  final double co2Saved;
  final DateTime scannedAt;

  const BottleItem({
    required this.materialType,
    required this.weightKg,
    required this.earnings,
    required this.co2Saved,
    required this.scannedAt,
  });

  String get materialLabel {
    switch (materialType) {
      case MaterialType.plastic:
        return 'Plastic';
      case MaterialType.glass:
        return 'Glass';
      case MaterialType.unknown:
        return 'Unknown';
    }
  }
}

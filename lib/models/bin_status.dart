class BinStatus {
  final String binId;
  final String location;
  final double fillPercent;
  final DateTime lastUpdated;
  final bool isActive;

  const BinStatus({
    required this.binId,
    required this.location,
    required this.fillPercent,
    required this.lastUpdated,
    required this.isActive,
  });
}

class AdminUser {
  final String uid;
  final String name;
  final String email;
  final String mobileMoneyNumber;
  final int totalBottleCount;
  final double totalEarnings;
  final int sessionCount;
  final DateTime createdAt;

  const AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.mobileMoneyNumber,
    required this.totalBottleCount,
    required this.totalEarnings,
    required this.sessionCount,
    required this.createdAt,
  });
}

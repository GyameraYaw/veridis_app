enum TransactionType { credit, withdrawalRequest }

class WalletTransaction {
  final String id;
  final DateTime timestamp;
  final TransactionType type;
  final double amount;
  final String description;
  final bool isPending; // true for withdrawal requests awaiting admin processing
  final String? mobileMoneyNumber; // only set for withdrawalRequest transactions

  const WalletTransaction({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.amount,
    required this.description,
    this.isPending = false,
    this.mobileMoneyNumber,
  });
}

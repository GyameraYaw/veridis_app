import '../models/wallet_transaction.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final List<WalletTransaction> _transactions = [];

  List<WalletTransaction> get transactions =>
      List.unmodifiable(_transactions);

  /// Current spendable balance: sum of credits minus confirmed withdrawals
  double get balance {
    double total = 0.0;
    for (final t in _transactions) {
      if (t.type == TransactionType.credit) {
        total += t.amount;
      } else {
        // Deduct withdrawal requests immediately (pending or processed)
        total -= t.amount;
      }
    }
    return double.parse(total.toStringAsFixed(2));
  }

  /// Called by SessionService when a session ends with earnings
  void creditEarnings(double amount, String description) {
    _transactions.insert(
      0,
      WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: TransactionType.credit,
        amount: amount,
        description: description,
      ),
    );
  }

  /// Creates a pending withdrawal request. Returns false if insufficient balance.
  bool requestWithdrawal(double amount, String momoNumber) {
    if (amount > balance) return false;
    _transactions.insert(
      0,
      WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: TransactionType.withdrawalRequest,
        amount: amount,
        description: 'Withdrawal to $momoNumber',
        isPending: true,
      ),
    );
    return true;
  }
}

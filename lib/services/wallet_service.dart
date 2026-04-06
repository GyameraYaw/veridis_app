import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_transaction.dart';

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<WalletTransaction> _transactions = [];

  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  double get balance {
    double total = 0.0;
    for (final t in _transactions) {
      if (t.type == TransactionType.credit) {
        total += t.amount;
      } else {
        total -= t.amount;
      }
    }
    return double.parse(total.toStringAsFixed(2));
  }

  // --- Load from Firestore on login ---

  Future<void> loadUserTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('walletTransactions')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .get();

    _transactions.clear();
    for (final doc in snapshot.docs) {
      _transactions.add(_txFromDoc(doc));
    }
  }

  WalletTransaction _txFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletTransaction(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] == 'credit'
          ? TransactionType.credit
          : TransactionType.withdrawalRequest,
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] as String,
      isPending: data['isPending'] as bool? ?? false,
    );
  }

  void clearLocalData() {
    _transactions.clear();
  }

  // --- Operations ---

  void creditEarnings(double amount, String description) {
    final tx = WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: TransactionType.credit,
      amount: amount,
      description: description,
    );
    _transactions.insert(0, tx);
    _writeTxToFirestore(tx);
  }

  bool requestWithdrawal(double amount, String momoNumber) {
    if (amount > balance) return false;
    final tx = WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      type: TransactionType.withdrawalRequest,
      amount: amount,
      description: 'Withdrawal to $momoNumber',
      isPending: true,
    );
    _transactions.insert(0, tx);
    _writeTxToFirestore(tx);
    return true;
  }

  // --- Firestore write (fire-and-forget) ---

  void _writeTxToFirestore(WalletTransaction tx) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _db.collection('walletTransactions').doc(tx.id).set({
      'userId': uid,
      'type': tx.type == TransactionType.credit ? 'credit' : 'withdrawalRequest',
      'amount': tx.amount,
      'description': tx.description,
      'isPending': tx.isPending,
      'timestamp': Timestamp.fromDate(tx.timestamp),
    });
  }
}

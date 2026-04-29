import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_user.dart';
import '../models/bin_status.dart';

class PendingWithdrawal {
  final String txId;
  final String userId;
  final String userName;
  final double amount;
  final String description;
  final String mobileMoneyNumber;
  final DateTime timestamp;

  const PendingWithdrawal({
    required this.txId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.description,
    required this.mobileMoneyNumber,
    required this.timestamp,
  });
}

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<bool> isCurrentUserAdmin() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['isAdmin'] as bool? ?? false;
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final usersSnap = await _db.collection('users').get();
    int totalUsers = 0;
    double totalWeightKg = 0.0;
    for (final doc in usersSnap.docs) {
      final data = doc.data();
      if (data['isAdmin'] == true) continue;
      totalUsers++;
      totalWeightKg += (data['totalWeight'] as num? ?? 0).toDouble();
    }

    final pendingSnap = await _db
        .collection('walletTransactions')
        .where('isPending', isEqualTo: true)
        .get();
    int pendingCount = pendingSnap.docs.length;
    double pendingTotalGhs = 0.0;
    for (final doc in pendingSnap.docs) {
      pendingTotalGhs += (doc.data()['amount'] as num? ?? 0).toDouble();
    }

    return {
      'totalUsers': totalUsers,
      'totalWeightKg': double.parse(totalWeightKg.toStringAsFixed(2)),
      'pendingCount': pendingCount,
      'pendingTotalGhs': double.parse(pendingTotalGhs.toStringAsFixed(2)),
    };
  }

  // ── User Management ───────────────────────────────────────────────────────

  Future<List<AdminUser>> fetchAllUsers() async {
    final snap = await _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();

    final users = <AdminUser>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['isAdmin'] == true) continue;
      users.add(AdminUser(
        uid: doc.id,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        mobileMoneyNumber: data['mobileMoneyNumber'] as String? ?? '',
        totalWeight: (data['totalWeight'] as num? ?? 0).toDouble(),
        totalEarnings: (data['totalEarnings'] as num? ?? 0).toDouble(),
        sessionCount: (data['sessionCount'] as num? ?? 0).toInt(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ));
    }
    return users;
  }

  // ── User Detail ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchUserSessions(String uid) async {
    final snap = await _db
        .collection('sessions')
        .where('userId', isEqualTo: uid)
        .orderBy('startTime', descending: true)
        .limit(20)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'machineId': data['machineId'] as String? ?? '',
        'startTime': (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'bottleCount': (data['bottleCount'] as num? ?? 0).toInt(),
        'totalWeight': (data['totalWeight'] as num? ?? 0).toDouble(),
        'totalEarnings': (data['totalEarnings'] as num? ?? 0).toDouble(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchUserTransactions(String uid) async {
    final snap = await _db
        .collection('walletTransactions')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'type': data['type'] as String? ?? '',
        'amount': (data['amount'] as num? ?? 0).toDouble(),
        'description': data['description'] as String? ?? '',
        'isPending': data['isPending'] as bool? ?? false,
        'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      };
    }).toList();
  }

  // ── Withdrawal Processing ─────────────────────────────────────────────────

  Stream<List<PendingWithdrawal>> streamPendingWithdrawals() {
    return _db
        .collection('walletTransactions')
        .where('isPending', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      if (snap.docs.isEmpty) return <PendingWithdrawal>[];

      // Collect unique userIds
      final userIds = snap.docs.map((d) => d.data()['userId'] as String).toSet();

      // Batch-fetch user names
      final nameMap = <String, String>{};
      for (final uid in userIds) {
        final userDoc = await _db.collection('users').doc(uid).get();
        nameMap[uid] = userDoc.data()?['name'] as String? ?? 'Unknown';
      }

      return snap.docs.map((doc) {
        final data = doc.data();
        final uid = data['userId'] as String;
        final desc = data['description'] as String? ?? '';
        final momo = data['mobileMoneyNumber'] as String? ??
            _parseMomoFromDescription(desc);
        return PendingWithdrawal(
          txId: doc.id,
          userId: uid,
          userName: nameMap[uid] ?? 'Unknown',
          amount: (data['amount'] as num).toDouble(),
          description: desc,
          mobileMoneyNumber: momo,
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  String _parseMomoFromDescription(String description) {
    final match = RegExp(r'Withdrawal to (\S+)').firstMatch(description);
    return match?.group(1) ?? '';
  }

  Future<void> markWithdrawalPaid(String txId) async {
    await _db.collection('walletTransactions').doc(txId).update({
      'isPending': false,
    });
  }

  Future<void> rejectWithdrawal({
    required String txId,
    required String userId,
    required double amount,
  }) async {
    final batch = _db.batch();

    batch.update(
      _db.collection('walletTransactions').doc(txId),
      {'isPending': false, 'isRejected': true},
    );

    final refundRef = _db.collection('walletTransactions').doc();
    batch.set(refundRef, {
      'userId': userId,
      'type': 'credit',
      'amount': amount,
      'description': 'Refund — withdrawal rejected by admin',
      'isPending': false,
      'timestamp': Timestamp.now(),
    });

    await batch.commit();
  }

  // ── Bin Monitoring ────────────────────────────────────────────────────────

  Stream<List<BinStatus>> streamBinStatuses() {
    return _db.collection('bins').snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return BinStatus(
          binId: data['binId'] as String? ?? doc.id,
          location: data['location'] as String? ?? 'Unknown',
          fillPercent: (data['fillPercent'] as num? ?? 0).toDouble(),
          lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] as bool? ?? false,
        );
      }).toList();
    });
  }
}

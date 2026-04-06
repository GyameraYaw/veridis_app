import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recycling_session.dart'; // also exports BottleItem via export directive
import 'wallet_service.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<RecyclingSession> _completedSessions = [];
  RecyclingSession? _activeSession;

  RecyclingSession? get activeSession => _activeSession;
  List<RecyclingSession> get completedSessions =>
      List.unmodifiable(_completedSessions);

  bool get hasActiveSession => _activeSession != null;

  // --- Load from Firestore on login ---

  Future<void> loadUserSessions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('sessions')
        .where('userId', isEqualTo: uid)
        .orderBy('startTime', descending: true)
        .get();

    _completedSessions.clear();
    for (final doc in snapshot.docs) {
      _completedSessions.add(_sessionFromDoc(doc));
    }
  }

  RecyclingSession _sessionFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final bottlesList = (data['bottles'] as List<dynamic>? ?? []).map((b) {
      final map = b as Map<String, dynamic>;
      return BottleItem(
        materialType: _materialFromString(map['materialType'] as String),
        weightKg: (map['weightKg'] as num).toDouble(),
        earnings: (map['earnings'] as num).toDouble(),
        co2Saved: (map['co2Saved'] as num).toDouble(),
        scannedAt: (map['scannedAt'] as Timestamp).toDate(),
      );
    }).toList();

    return RecyclingSession(
      id: doc.id,
      machineId: data['machineId'] as String,
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      bottles: bottlesList,
    );
  }

  MaterialType _materialFromString(String value) {
    switch (value) {
      case 'plastic':
        return MaterialType.plastic;
      case 'glass':
        return MaterialType.glass;
      default:
        return MaterialType.unknown;
    }
  }

  // --- Active session lifecycle ---

  void startSession(String machineId) {
    _activeSession = RecyclingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      machineId: machineId,
      startTime: DateTime.now(),
      bottles: [],
    );
  }

  void addBottleToActive(BottleItem bottle) {
    if (_activeSession == null) return;
    _activeSession = RecyclingSession(
      id: _activeSession!.id,
      machineId: _activeSession!.machineId,
      startTime: _activeSession!.startTime,
      bottles: [..._activeSession!.bottles, bottle],
    );
  }

  RecyclingSession endSession() {
    final finished = _activeSession!.end();
    _completedSessions.insert(0, finished);
    _activeSession = null;

    if (finished.totalEarnings > 0) {
      WalletService().creditEarnings(
        finished.totalEarnings,
        'Session #${_completedSessions.length} — ${finished.bottleCount} bottle(s)',
      );
    }

    _writeSessionToFirestore(finished);
    _updateUserAggregates(finished);

    return finished;
  }

  void cancelSession() {
    _activeSession = null;
  }

  void clearLocalData() {
    _completedSessions.clear();
    _activeSession = null;
  }

  // --- Firestore writes (fire-and-forget) ---

  void _writeSessionToFirestore(RecyclingSession session) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _db.collection('sessions').doc(session.id).set({
      'userId': uid,
      'machineId': session.machineId,
      'startTime': Timestamp.fromDate(session.startTime),
      'endTime': session.endTime != null
          ? Timestamp.fromDate(session.endTime!)
          : null,
      'bottles': session.bottles.map((b) => {
        'materialType': b.materialType.name,
        'weightKg': b.weightKg,
        'earnings': b.earnings,
        'co2Saved': b.co2Saved,
        'scannedAt': Timestamp.fromDate(b.scannedAt),
      }).toList(),
      'totalWeight': session.totalWeight,
      'totalEarnings': session.totalEarnings,
      'totalCo2Saved': session.totalCo2Saved,
      'bottleCount': session.bottleCount,
    });
  }

  void _updateUserAggregates(RecyclingSession session) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _db.collection('users').doc(uid).update({
      'totalWeight': FieldValue.increment(session.totalWeight),
      'totalEarnings': FieldValue.increment(session.totalEarnings),
      'totalCo2Saved': FieldValue.increment(session.totalCo2Saved),
      'sessionCount': FieldValue.increment(1),
    });
  }

  // --- Aggregates ---

  double get totalWeight =>
      _completedSessions.fold(0.0, (sum, s) => sum + s.totalWeight);

  double get totalEarnings =>
      _completedSessions.fold(0.0, (sum, s) => sum + s.totalEarnings);

  double get totalCo2Saved =>
      _completedSessions.fold(0.0, (sum, s) => sum + s.totalCo2Saved);

  int get sessionCount => _completedSessions.length;

  double get plasticWeight => _completedSessions.fold(
      0.0,
      (sum, s) => sum +
          s.bottles
              .where((b) => b.materialType == MaterialType.plastic)
              .fold(0.0, (bSum, b) => bSum + b.weightKg));

  double get glassWeight => _completedSessions.fold(
      0.0,
      (sum, s) => sum +
          s.bottles
              .where((b) => b.materialType == MaterialType.glass)
              .fold(0.0, (bSum, b) => bSum + b.weightKg));
}

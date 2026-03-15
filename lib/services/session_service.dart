import '../models/recycling_session.dart'; // also exports BottleItem via export directive
import 'wallet_service.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final List<RecyclingSession> _completedSessions = [];

  // The session currently in progress (null when idle)
  RecyclingSession? _activeSession;

  RecyclingSession? get activeSession => _activeSession;
  List<RecyclingSession> get completedSessions =>
      List.unmodifiable(_completedSessions);

  bool get hasActiveSession => _activeSession != null;

  // --- Active session lifecycle ---

  void startSession(String machineId) {
    _activeSession = RecyclingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      machineId: machineId,
      startTime: DateTime.now(),
      bottles: [],
    );
  }

  /// Adds a scanned bottle to the active session.
  void addBottleToActive(BottleItem bottle) {
    if (_activeSession == null) return;
    _activeSession = RecyclingSession(
      id: _activeSession!.id,
      machineId: _activeSession!.machineId,
      startTime: _activeSession!.startTime,
      bottles: [..._activeSession!.bottles, bottle],
    );
  }

  /// Ends the active session: saves it to history and credits the wallet.
  RecyclingSession endSession() {
    final finished = _activeSession!.end();
    _completedSessions.insert(0, finished); // newest first
    _activeSession = null;

    // Credit earnings to wallet
    if (finished.totalEarnings > 0) {
      WalletService().creditEarnings(
        finished.totalEarnings,
        'Session #${_completedSessions.length} — ${finished.bottleCount} bottle(s)',
      );
    }

    return finished;
  }

  void cancelSession() {
    _activeSession = null;
  }

  // --- Aggregates across all completed sessions ---

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

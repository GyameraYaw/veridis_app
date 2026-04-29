import 'package:flutter/material.dart' hide MaterialType;
import '../../models/admin_user.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/responsive_layout.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final AdminUser user;
  const AdminUserDetailScreen({super.key, required this.user});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late Future<List<Map<String, dynamic>>> _sessionsFuture;
  late Future<List<Map<String, dynamic>>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = AdminService().fetchUserSessions(widget.user.uid);
    _transactionsFuture = AdminService().fetchUserTransactions(widget.user.uid);
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('VERIDIS Admin', style: AppTextStyles.heroCaption),
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── User header card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: AppDecorations.heroCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: AppTextStyles.heroTitle),
                    const SizedBox(height: 4),
                    Text(user.email, style: AppTextStyles.heroLabel),
                    if (user.mobileMoneyNumber.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_android,
                              size: 14, color: Color(0xCCFFFFFF)),
                          const SizedBox(width: 4),
                          Text(user.mobileMoneyNumber,
                              style: AppTextStyles.heroLabel),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: Color(0x33FFFFFF), height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _heroStat('${user.sessionCount}', 'Sessions'),
                        _divider(),
                        _heroStat(
                            '${user.totalWeight.toStringAsFixed(1)} kg',
                            'Recycled'),
                        _divider(),
                        _heroStat(
                            'GHS ${user.totalEarnings.toStringAsFixed(2)}',
                            'Earned'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Recent Sessions ──────────────────────────────────────────
              const Text('Recent Sessions',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _sessionsFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(
                            color: AppColors.forestGreen),
                      ),
                    );
                  }
                  final sessions = snap.data ?? [];
                  if (sessions.isEmpty) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text('No sessions yet.',
                          style: AppTextStyles.bodyMedium),
                    );
                  }
                  return Column(
                    children: sessions
                        .map((s) => _SessionTile(
                            session: s, timeAgo: _timeAgo))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Recent Transactions ──────────────────────────────────────
              const Text('Recent Transactions',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _transactionsFuture,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(
                            color: AppColors.forestGreen),
                      ),
                    );
                  }
                  final txs = snap.data ?? [];
                  if (txs.isEmpty) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text('No transactions yet.',
                          style: AppTextStyles.bodyMedium),
                    );
                  }
                  return Column(
                    children: txs
                        .map((t) => _TransactionTile(
                            tx: t, timeAgo: _timeAgo))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.heroTitle),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.heroCaption),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: const Color(0x33FFFFFF),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}

// ── Session tile ──────────────────────────────────────────────────────────────

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;
  final String Function(DateTime) timeAgo;
  const _SessionTile({required this.session, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final startTime = session['startTime'] as DateTime;
    final bottleCount = session['bottleCount'] as int;
    final totalWeight = session['totalWeight'] as double;
    final totalEarnings = session['totalEarnings'] as double;
    final machineId = session['machineId'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.contentCard,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: const Icon(Icons.recycling,
                size: 22, color: AppColors.freshGreen),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machineId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$bottleCount bottle${bottleCount == 1 ? '' : 's'} · '
                  '${totalWeight.toStringAsFixed(2)} kg',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(timeAgo(startTime), style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Text(
            'GHS ${totalEarnings.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.earningsGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final String Function(DateTime) timeAgo;
  const _TransactionTile({required this.tx, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final type = tx['type'] as String;
    final amount = tx['amount'] as double;
    final description = tx['description'] as String;
    final isPending = tx['isPending'] as bool;
    final timestamp = tx['timestamp'] as DateTime;
    final isCredit = type == 'credit';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.contentCard,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCredit ? AppColors.mintGreen : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 22,
              color: isCredit ? AppColors.freshGreen : AppColors.pendingAmber,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(timeAgo(timestamp), style: AppTextStyles.labelSmall),
                if (isPending) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.pendingAmber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pendingAmber,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}GHS ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.earningsGreen : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

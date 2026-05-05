import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = AdminService().fetchDashboardStats();
  }

  void _refresh() {
    setState(() {
      _statsFuture = AdminService().fetchDashboardStats();
    });
  }

  Future<void> _runMigration() async {
    try {
      await AdminService().migrateBottleCounts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bottle counts updated for all users.')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Migration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forestGreen),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Failed to load stats.',
                    style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
              ],
            ),
          );
        }

        final stats = snapshot.data!;
        final totalUsers = stats['totalUsers'] as int;
        final totalBottleCount = stats['totalBottleCount'] as int;
        final pendingCount = stats['pendingCount'] as int;
        final pendingTotalGhs = stats['pendingTotalGhs'] as double;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const Text('Campus Overview', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              const Text('Live platform statistics',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.lg),

              // ── Hero card ────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: AppDecorations.heroCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Bottles Recycled',
                        style: AppTextStyles.heroLabel),
                    const SizedBox(height: 6),
                    Text(
                      '$totalBottleCount',
                      style: AppTextStyles.heroDisplayLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: Color(0x33FFFFFF), height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _heroStat('$totalUsers', 'Registered Users'),
                        Container(
                          width: 1,
                          height: 32,
                          color: const Color(0x33FFFFFF),
                          margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                        ),
                        _heroStat('$pendingCount', 'Pending Payouts'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── 2×2 metric grid ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      icon: Icons.people_outline,
                      value: '$totalUsers',
                      label: 'Registered Users',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _metricCard(
                      icon: Icons.recycling,
                      value: '$totalBottleCount',
                      label: 'Total Bottles',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      icon: Icons.pending_actions_outlined,
                      value: '$pendingCount',
                      label: 'Pending Payouts',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _metricCard(
                      icon: Icons.payments_outlined,
                      value: 'GHS ${pendingTotalGhs.toStringAsFixed(2)}',
                      label: 'Pending Amount',
                      valueColor: AppColors.pendingAmber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _runMigration,
                  icon: const Icon(Icons.sync),
                  label: const Text('Recalculate Bottle Counts'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
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

  Widget _metricCard({
    required IconData icon,
    required String value,
    required String label,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.contentCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Icon(icon, size: 22, color: AppColors.freshGreen),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

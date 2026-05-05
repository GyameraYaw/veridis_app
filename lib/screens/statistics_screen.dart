// hide MaterialType to avoid conflict with Flutter's material.dart
import 'package:flutter/material.dart' hide MaterialType;
import '../services/session_service.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _svc = SessionService();

  @override
  Widget build(BuildContext context) {
    final sessions = _svc.completedSessions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          const Text('Your Statistics', style: AppTextStyles.displayMedium),
          const SizedBox(height: 6),
          const Text(
            'Track your recycling progress and impact.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Total waste + CO2 row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.recycling,
                  value: '${_svc.totalBottleCount}',
                  label: 'Bottles Recycled',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.cloud_queue,
                  value: '${_svc.totalCo2Saved.toStringAsFixed(2)} kg',
                  label: 'CO\u2082 Emissions Saved',
                  valueColor: AppColors.co2DeepGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Sessions + earnings row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timeline,
                  value: '${_svc.sessionCount}',
                  label: 'Sessions Completed',
                  valueColor: AppColors.sessionGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.attach_money,
                  value: 'GHS ${_svc.totalEarnings.toStringAsFixed(2)}',
                  label: 'Total Earnings',
                  valueColor: AppColors.earningsGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Plastic vs Glass breakdown
          Container(
            decoration: AppDecorations.contentCard,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMaterialBreakdown(
                      icon: Icons.water_drop,
                      label: 'Plastic',
                      value: '${_svc.plasticCount} bottles',
                      color: AppColors.freshGreen,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.divider,
                  ),
                  Expanded(
                    child: _buildMaterialBreakdown(
                      icon: Icons.local_drink,
                      label: 'Glass',
                      value: '${_svc.glassCount} bottles',
                      color: AppColors.midGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text('Session History', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),

          sessions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inbox,
                            size: 60, color: AppColors.textDisabled),
                        const SizedBox(height: 12),
                        const Text(
                          'No sessions recorded yet.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final s = sessions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: AppDecorations.contentCard,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.mintGreen,
                          child: Text(
                            '${sessions.length - index}',
                            style: const TextStyle(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${s.bottleCount} bottle${s.bottleCount == 1 ? '' : 's'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(_formatDate(s.startTime)),
                        trailing: Text(
                          'GHS ${s.totalEarnings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.earningsGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildStatCard({
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
          Text(label, style: AppTextStyles.bodyMedium, textAlign: TextAlign.left),
        ],
      ),
    );
  }

  Widget _buildMaterialBreakdown({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year}  $h:$mi';
  }
}

import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = SessionService().completedSessions;

    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(title: const Text('Session History')),
        body: sessions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 80,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text('No sessions yet', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Start a session to see your history here.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: AppDecorations.contentCard,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
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
                        '${s.bottleCount} bottle${s.bottleCount == 1 ? '' : 's'} — ${s.totalWeight.toStringAsFixed(2)} kg',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _formatDate(s.startTime),
                        style: AppTextStyles.bodyMedium,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'GHS ${s.totalEarnings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.earningsGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Machine ${s.machineId}',
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
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

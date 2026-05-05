import 'package:flutter/material.dart';
import '../../models/bin_status.dart';
import '../../services/admin_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class AdminBinsScreen extends StatefulWidget {
  const AdminBinsScreen({super.key});

  @override
  State<AdminBinsScreen> createState() => _AdminBinsScreenState();
}

class _AdminBinsScreenState extends State<AdminBinsScreen> {
  // Tracks the last fill % at which each bin triggered a notification
  final Map<String, double> _lastNotifiedPercent = {};

  void _checkThresholds(List<BinStatus> bins) {
    for (final bin in bins) {
      final last = _lastNotifiedPercent[bin.binId] ?? 0.0;
      if (bin.fillPercent >= 100 && last < 100) {
        NotificationService.showBinAlert(
          binId: bin.binId,
          location: bin.location,
          fillPercent: bin.fillPercent,
        );
        _lastNotifiedPercent[bin.binId] = 100;
      } else if (bin.fillPercent >= 80 && last < 80) {
        NotificationService.showBinAlert(
          binId: bin.binId,
          location: bin.location,
          fillPercent: bin.fillPercent,
        );
        _lastNotifiedPercent[bin.binId] = 80;
      } else if (bin.fillPercent < 80) {
        // Reset so alert fires again if bin fills up again after being emptied
        _lastNotifiedPercent[bin.binId] = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BinStatus>>(
      stream: AdminService().streamBinStatuses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forestGreen),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading bin data.', style: AppTextStyles.bodyLarge),
          );
        }

        final bins = snapshot.data ?? [];
        _checkThresholds(bins);
        final alertBins = bins.where((b) => b.fillPercent >= 80).toList();

        if (bins.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.delete_outline, size: 64, color: AppColors.textDisabled),
              SizedBox(height: AppSpacing.md),
              Text('No bins configured', style: AppTextStyles.titleLarge),
              SizedBox(height: 4),
              Text('Add bins in Firestore Console',
                  style: AppTextStyles.bodyMedium),
            ],
          );
        }

        return Column(
          children: [
            // Alert banner
            if (alertBins.isNotEmpty)
              Container(
                width: double.infinity,
                color: AppColors.pendingAmber.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.pendingAmber, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${alertBins.length} bin${alertBins.length == 1 ? '' : 's'} need emptying!',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.pendingAmber,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.85,
                ),
                itemCount: bins.length,
                itemBuilder: (context, index) => _BinCard(bin: bins[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BinCard extends StatelessWidget {
  final BinStatus bin;
  const _BinCard({required this.bin});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inDays < 1) return '${diff.inHours} hr ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final isFull = bin.fillPercent >= 80;
    final barColor = isFull ? AppColors.pendingAmber : AppColors.freshGreen;
    final percentColor = isFull ? AppColors.pendingAmber : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.contentCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bin.location,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!bin.isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: AppDecorations.infoBox,
                  child: const Text('Offline',
                      style: AppTextStyles.labelSmall),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Fill bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: LinearProgressIndicator(
              value: (bin.fillPercent / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.mintGreen,
              color: barColor,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${bin.fillPercent.toStringAsFixed(0)}% full',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: percentColor,
                ),
              ),
              Text(bin.binId, style: AppTextStyles.labelSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Updated ${_timeAgo(bin.lastUpdated)}',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

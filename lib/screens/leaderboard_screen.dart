import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              const Text('Leaderboard', style: AppTextStyles.displayMedium),
              const SizedBox(height: 6),
              const Text(
                'See how you rank among fellow recyclers.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: 10,
            itemBuilder: (context, index) {
              final isCurrentUser = index == 2;
              final rankLabel = index < 3
                  ? ['1', '2', '3'][index]
                  : '${index + 1}';

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppColors.mintGreen
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: isCurrentUser
                      ? Border.all(color: AppColors.freshGreen, width: 1.5)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentUser
                        ? AppColors.forestGreen
                        : AppColors.freshGreen,
                    child: Text(
                      rankLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    isCurrentUser
                        ? 'You'
                        : 'User ${String.fromCharCode(65 + index)}',
                    style: TextStyle(
                      fontWeight: isCurrentUser
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    'Total Waste: ${200 - index * 10} kg',
                    style: AppTextStyles.bodyMedium,
                  ),
                  trailing: isCurrentUser
                      ? const Icon(Icons.star, color: AppColors.forestGreen)
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: AppColors.textSubtle,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

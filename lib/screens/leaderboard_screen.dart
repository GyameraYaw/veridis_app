import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _fetchLeaderboard();
  }

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('totalWeight', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .where((doc) => doc.data()['isAdmin'] != true)
        .map((doc) => {'uid': doc.id, ...doc.data()})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

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
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _leaderboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Failed to load leaderboard.\n\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                );
              }
              final entries = snapshot.data ?? [];
              if (entries.isEmpty) {
                return const Center(child: Text('No data yet. Start recycling!'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final isCurrentUser = entry['uid'] == currentUid;
                  final rankLabel = index < 3 ? ['1', '2', '3'][index] : '${index + 1}';
                  final name = entry['name'] as String? ?? 'Unknown';
                  final totalWeight = (entry['totalWeight'] as num?)?.toDouble() ?? 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? AppColors.mintGreen : AppColors.white,
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
                        isCurrentUser ? 'You ($name)' : name,
                        style: TextStyle(
                          fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        'Total Waste: ${totalWeight.toStringAsFixed(2)} kg',
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
              );
            },
          ),
        ),
      ],
    );
  }
}

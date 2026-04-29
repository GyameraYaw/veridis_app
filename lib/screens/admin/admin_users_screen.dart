import 'package:flutter/material.dart';
import '../../models/admin_user.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<AdminUser>> _usersFuture;
  String _filter = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersFuture = AdminService().fetchAllUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminUser> _filtered(List<AdminUser> users) {
    if (_filter.isEmpty) return users;
    return users
        .where((u) =>
            u.name.toLowerCase().contains(_filter) ||
            u.email.toLowerCase().contains(_filter))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminUser>>(
      future: _usersFuture,
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
                const Text('Failed to load users.',
                    style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => _usersFuture = AdminService().fetchAllUsers()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allUsers = snapshot.data!;
        final users = _filtered(allUsers);

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by name or email...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                onChanged: (val) =>
                    setState(() => _filter = val.toLowerCase()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${users.length} user${users.length == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // User list
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: Text('No users found.', style: AppTextStyles.bodyLarge),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      itemCount: users.length,
                      itemBuilder: (context, index) =>
                          _UserTile(user: users[index]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final AdminUser user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminUserDetailScreen(user: user),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: AppDecorations.contentCard,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.forestGreen,
              radius: 24,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(user.email, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 2),
                  Text(user.mobileMoneyNumber,
                      style: AppTextStyles.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'GHS ${user.totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.earningsGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text('${user.sessionCount} sessions',
                    style: AppTextStyles.labelSmall),
                const SizedBox(height: 2),
                Text('${user.totalWeight.toStringAsFixed(1)} kg',
                    style: AppTextStyles.labelSmall),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.textSubtle),
          ],
        ),
      ),
    );
  }
}

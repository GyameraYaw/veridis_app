import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController(
    text: 'John Doe',
  );
  final TextEditingController _mobileController = TextEditingController(
    text: '+233 24 123 4567',
  );
  final _svc = SessionService();
  final _wallet = WalletService();

  @override
  void dispose() {
    _usernameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          const Text('Your Profile', style: AppTextStyles.displayMedium),
          const SizedBox(height: 6),
          const Text(
            'Manage your account details and view your stats.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppDecorations.contentCard,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.forestGreen,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                        ),
                      );
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          const Text('Your Stats', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timeline,
                  value: '${_svc.sessionCount}',
                  label: 'Sessions',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.eco,
                  value: '${_svc.totalWeight.toStringAsFixed(2)} kg',
                  label: 'Total Waste',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Wallet balance — tappable shortcut
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            ),
            child: Container(
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
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 22,
                      color: AppColors.earningsGreen,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GHS ${_wallet.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.earningsGreen,
                          ),
                        ),
                        const Text(
                          'Wallet Balance — tap to open',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSubtle,
                  ),
                ],
              ),
            ),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

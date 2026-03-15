import 'package:flutter/material.dart';
import '../models/wallet_transaction.dart';
import '../services/wallet_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _wallet = WalletService();

  void _showWithdrawSheet() {
    final amountController = TextEditingController();
    final momoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Withdraw Funds', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Available: GHS ${_wallet.balance.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: momoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'MTN Mobile Money Number',
                  hintText: '024 XXX XXXX',
                  prefixIcon: Icon(Icons.phone_android),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter your MoMo number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (GHS)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter an amount';
                  final amount = double.tryParse(v.trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  if (amount > _wallet.balance) {
                    return 'Amount exceeds your balance';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final amount =
                        double.parse(amountController.text.trim());
                    final momo = momoController.text.trim();
                    final success = _wallet.requestWithdrawal(amount, momo);
                    Navigator.pop(ctx);
                    if (success) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Withdrawal requested! You\'ll receive your funds within 24 hours.',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Request Withdrawal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _wallet.transactions;

    return ResponsiveWrapper(
      child: Scaffold(
        appBar: AppBar(title: const Text('My Wallet')),
        body: Column(
          children: [
            // ── Hero balance header ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.forestGreen, AppColors.freshGreen],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.hero),
                  bottomRight: Radius.circular(AppRadius.hero),
                ),
              ),
              child: Column(
                children: [
                  const Text('Available Balance', style: AppTextStyles.heroLabel),
                  const SizedBox(height: 8),
                  Text(
                    'GHS ${_wallet.balance.toStringAsFixed(2)}',
                    style: AppTextStyles.heroDisplayLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: 200,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed:
                          _wallet.balance > 0 ? _showWithdrawSheet : null,
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      label: const Text('Withdraw to MoMo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.forestGreen,
                        disabledBackgroundColor: Colors.white38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Transaction history ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Transaction History',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: AppColors.textDisabled,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'No transactions yet.',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Complete a recycling session to earn rewards.',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        final isCredit = t.type == TransactionType.credit;
                        return Container(
                          margin:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: AppDecorations.contentCard,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.mintGreen,
                              child: Icon(
                                isCredit
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isCredit
                                    ? AppColors.freshGreen
                                    : AppColors.midGreen,
                              ),
                            ),
                            title: Text(
                              t.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  _formatDate(t.timestamp),
                                  style: AppTextStyles.labelSmall,
                                ),
                                if (t.isPending) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.pendingAmber
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Pending',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.pendingAmber
                                            .withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Text(
                              '${isCredit ? '+' : '-'}GHS ${t.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isCredit
                                    ? AppColors.earningsGreen
                                    : AppColors.textBody,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
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

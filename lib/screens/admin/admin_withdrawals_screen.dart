import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/paystack_service.dart';
import '../../theme/app_theme.dart';

class AdminWithdrawalsScreen extends StatelessWidget {
  const AdminWithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PendingWithdrawal>>(
      stream: AdminService().streamPendingWithdrawals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forestGreen),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading withdrawals.', style: AppTextStyles.bodyLarge),
          );
        }

        final withdrawals = snapshot.data ?? [];
        final total = withdrawals.fold(0.0, (sum, w) => sum + w.amount);

        return Column(
          children: [
            // Summary bar
            Container(
              color: AppColors.mintGreen,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text(
                    '${withdrawals.length} pending',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Total: GHS ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.pendingAmber,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: withdrawals.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.check_circle_outline,
                            size: 64, color: AppColors.textDisabled),
                        SizedBox(height: AppSpacing.md),
                        Text('No pending withdrawals',
                            style: AppTextStyles.titleLarge),
                        SizedBox(height: 4),
                        Text('All caught up!', style: AppTextStyles.bodyMedium),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: withdrawals.length,
                      itemBuilder: (context, index) =>
                          _WithdrawalTile(withdrawal: withdrawals[index]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _WithdrawalTile extends StatefulWidget {
  final PendingWithdrawal withdrawal;
  const _WithdrawalTile({required this.withdrawal});

  @override
  State<_WithdrawalTile> createState() => _WithdrawalTileState();
}

class _WithdrawalTileState extends State<_WithdrawalTile> {
  bool _isProcessing = false;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _confirmAndReject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Withdrawal'),
        content: Text(
          'Reject GHS ${widget.withdrawal.amount.toStringAsFixed(2)} withdrawal '
          'for ${widget.withdrawal.userName}?\n\n'
          'The amount will be refunded to their wallet balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await AdminService().rejectWithdrawal(
      txId: widget.withdrawal.txId,
      userId: widget.withdrawal.userId,
      amount: widget.withdrawal.amount,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal rejected & refunded')),
      );
    }
  }

  Future<void> _confirmAndMarkPaid(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Mark GHS ${widget.withdrawal.amount.toStringAsFixed(2)} for '
          '${widget.withdrawal.userName} as paid?\n\n'
          'A real Paystack transfer will be initiated. The withdrawal will '
          'only be marked paid on success.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      final transferCode =
          await AdminService().markWithdrawalPaid(widget.withdrawal);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paid via MoMo — Ref: $transferCode')),
        );
      }
    } on PaystackTransferException catch (e) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Transfer Failed'),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unexpected Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: AppDecorations.contentCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.withdrawal.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                if (widget.withdrawal.mobileMoneyNumber.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone_android,
                          size: 14, color: AppColors.forestGreen),
                      const SizedBox(width: 4),
                      Text(
                        widget.withdrawal.mobileMoneyNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 2),
                Text(widget.withdrawal.description,
                    style: AppTextStyles.labelSmall),
                const SizedBox(height: 2),
                Text(_formatDate(widget.withdrawal.timestamp),
                    style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                // Pending badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'GHS ${widget.withdrawal.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.earningsGreen,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: 110,
                height: 36,
                child: ElevatedButton(
                  onPressed:
                      _isProcessing ? null : () => _confirmAndMarkPaid(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Mark Paid'),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 110,
                height: 36,
                child: OutlinedButton(
                  onPressed:
                      _isProcessing ? null : () => _confirmAndReject(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    side: const BorderSide(color: AppColors.errorRed),
                    foregroundColor: AppColors.errorRed,
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Reject'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

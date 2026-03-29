import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key, required this.payments});

  final List<PaymentRecord> payments;

  @override
  Widget build(BuildContext context) {
    final totalProcessed =
        payments.fold<int>(0, (sum, payment) => sum + payment.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'A calmer place to track transfers, approvals, and release logic across every pool.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [AppTheme.coral, AppTheme.peach],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total money moved',
                  style: TextStyle(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs.$totalProcessed',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin Control sends the full checkout to the admin. Get Back only returns each person\'s own contribution.',
                  style: TextStyle(
                    color: AppTheme.ink,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Column(
              children: [
                _PaymentHint(
                  icon: Icons.account_tree_outlined,
                  title: 'Splitwise checkout',
                  subtitle: 'Every member gets an equal share when the pool closes.',
                ),
                SizedBox(height: 14),
                _PaymentHint(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Control checkout',
                  subtitle: 'One admin receives the full amount for central handling.',
                ),
                SizedBox(height: 14),
                _PaymentHint(
                  icon: Icons.replay_circle_filled_outlined,
                  title: 'Get Back checkout',
                  subtitle: 'Members only retrieve exactly what they put in.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recent activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...payments.map(
            (payment) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.mint,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.currency_rupee_rounded,
                        color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text('${payment.poolName} | ${payment.status}'),
                        ],
                      ),
                    ),
                    Text(
                      'Rs.${payment.amount}',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHint extends StatelessWidget {
  const _PaymentHint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.ink),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ],
    );
  }
}

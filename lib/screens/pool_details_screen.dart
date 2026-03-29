import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import 'contribute_screen.dart';

class PoolDetailsScreen extends StatelessWidget {
  const PoolDetailsScreen({super.key, required this.pool});

  final PoolModel pool;

  @override
  Widget build(BuildContext context) {
    final nextAdmin = pool.nextAdminCandidate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pool Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [AppTheme.ink, Color(0xFF33415C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pool.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pool.description,
                    style: const TextStyle(
                      color: Color(0xFFE7ECF5),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _TopMetric(
                          label: 'Collected',
                          value: 'Rs.${pool.collectedAmount}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TopMetric(
                          label: 'Target',
                          value: 'Rs.${pool.targetAmount}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: pool.progress,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      color: AppTheme.coral,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContributeScreen(pool: pool),
                    ),
                  );
                },
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Contribute Money'),
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Pool rules',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RuleRow(
                    icon: Icons.policy_outlined,
                    title: 'Specification',
                    subtitle: pool.style == PoolStyle.strict
                        ? 'Strict: every member permission is needed to checkout.'
                        : 'Casual: half of the members can release half the amount. The rest stays, and admin shifts to the most active member.',
                  ),
                  const SizedBox(height: 14),
                  _RuleRow(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Checkout mode',
                    subtitle: switch (pool.settlementMode) {
                      PoolSettlementMode.splitwise =>
                        'Splitwise: each member gets an equal share at checkout.',
                      PoolSettlementMode.adminControl =>
                        'Admin Control: the admin receives the full money amount.',
                      PoolSettlementMode.getBack =>
                        'Get Back: everyone only retrieves exactly what they contributed.',
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Admin now',
                    child: Text(
                      pool.adminName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _InfoCard(
                    title: 'Next admin',
                    child: Text(
                      nextAdmin?.name ?? 'TBD',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Approval snapshot',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pool.approvalsNeeded} approvals needed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pool.style == PoolStyle.strict
                        ? 'No money leaves this pool until every member approves.'
                        : 'Once majority approval lands, Rs.${pool.casualReleaseAmount} can move and the rest remains inside the pool.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Members',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...pool.members.map(
              (member) => Padding(
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
                      CircleAvatar(
                        backgroundColor: AppTheme.mint,
                        child: Text(
                          member.name.substring(0, 1),
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Contributed Rs.${member.contributedAmount} | Activity ${member.activityScore}',
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${member.approvalsGiven} approvals',
                        style: const TextStyle(
                          color: AppTheme.slate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopMetric extends StatelessWidget {
  const _TopMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFE7ECF5))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
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

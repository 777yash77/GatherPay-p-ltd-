import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';
import 'create_pool_screen.dart';
import 'payments_screen.dart';
import 'pool_details_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late List<PoolModel> _pools;
  late List<PaymentRecord> _payments;

  @override
  void initState() {
    super.initState();
    _pools = MockDataService.samplePools();
    _payments = MockDataService.samplePayments();
  }

  void _addPool(PoolModel pool) {
    setState(() {
      _pools = [pool, ..._pools];
    });
  }

  void _openCreatePool() async {
    final newPool = await Navigator.push<PoolModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePoolScreen(),
      ),
    );

    if (newPool != null) {
      _addPool(newPool);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newPool.name} is live and ready for invites.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(
        pools: _pools,
        payments: _payments,
        onCreatePool: _openCreatePool,
      ),
      PaymentsScreen(payments: _payments),
      ProfileScreen(
        profile: MockDataService.profile,
        pools: _pools,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openCreatePool,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create pool'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.pools,
    required this.payments,
    required this.onCreatePool,
  });

  final List<PoolModel> pools;
  final List<PaymentRecord> payments;
  final VoidCallback onCreatePool;

  @override
  Widget build(BuildContext context) {
    final totalCollected =
        pools.fold<int>(0, (sum, pool) => sum + pool.collectedAmount);
    final totalTarget = pools.fold<int>(0, (sum, pool) => sum + pool.targetAmount);
    final pendingApprovals = pools.fold<int>(0, (sum, pool) => sum + pool.approvalsNeeded);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey Yaswanth',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your pools feel alive now: money in motion, people synced, decisions clear.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [AppTheme.coral, AppTheme.peach],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.waving_hand_rounded, color: AppTheme.ink),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [AppTheme.ink, Color(0xFF33415C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22172033),
                  blurRadius: 24,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Beautifully organized pool money',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Collect fast. Approve smart. Payout with confidence.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Strict pools lock checkout until everyone agrees. Casual pools can release half with majority approval and rotate admin to the most active member.',
                  style: TextStyle(
                    color: Color(0xFFE7ECF5),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _HeroStat(label: 'Collected', value: 'Rs.$totalCollected'),
                    _HeroStat(label: 'Targeted', value: 'Rs.$totalTarget'),
                    _HeroStat(
                      label: 'Approvals',
                      value: '$pendingApprovals checkpoints',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  title: 'Live pools',
                  value: '${pools.length}',
                  accent: AppTheme.mint,
                  icon: Icons.groups_rounded,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _QuickStatCard(
                  title: 'This week',
                  value: 'Rs.${payments.fold<int>(0, (sum, p) => sum + p.amount)}',
                  accent: AppTheme.peach,
                  icon: Icons.auto_graph_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  title: 'Create a guided pool',
                  subtitle: 'Choose strict or casual rules and set the payout style.',
                  icon: Icons.tune_rounded,
                  onTap: onCreatePool,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ActionTile(
                  title: 'Sync contacts',
                  subtitle: 'Pull people from your phone, or search app users by number.',
                  icon: Icons.contact_phone_rounded,
                  onTap: onCreatePool,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Active Pools', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ...pools.map(
            (pool) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PoolPreviewCard(pool: pool),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Today at a glance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Column(
              children: [
                _InsightRow(
                  icon: Icons.verified_user_outlined,
                  title: 'Strict pools protect large withdrawals',
                  subtitle: 'Everyone must approve before checkout can complete.',
                ),
                SizedBox(height: 14),
                _InsightRow(
                  icon: Icons.diversity_3_outlined,
                  title: 'Casual pools keep momentum',
                  subtitle:
                      'Half approvals release half the funds and pass admin to the most active member.',
                ),
                SizedBox(height: 14),
                _InsightRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Settlement is now pool-specific',
                  subtitle:
                      'Splitwise, Admin Control, or Get Back change exactly who receives money at checkout.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PoolPreviewCard extends StatelessWidget {
  const _PoolPreviewCard({required this.pool});

  final PoolModel pool;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PoolDetailsScreen(pool: pool),
          ),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.peach,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pool.category,
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  pool.styleLabel,
                  style: const TextStyle(
                    color: AppTheme.slate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(pool.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(pool.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rs.${pool.collectedAmount} collected',
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Target Rs.${pool.targetAmount}',
                  style: const TextStyle(color: AppTheme.slate),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pool.progress,
                minHeight: 10,
                backgroundColor: AppTheme.cloud,
                color: AppTheme.coral,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniPill(label: '${pool.members.length} members'),
                _MiniPill(label: pool.settlementLabel),
                _MiniPill(label: '${pool.approvalsNeeded} approvals'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.ink),
          ),
          const SizedBox(height: 16),
          Text(title),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.ink),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

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
          const SizedBox(height: 8),
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

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cloud,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.mint,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: AppTheme.ink),
        ),
        const SizedBox(width: 14),
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

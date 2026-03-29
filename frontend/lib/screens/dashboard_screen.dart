import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import 'create_pool_screen.dart';
import 'notifications_screen.dart';
import 'pool_details_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.session,
    required this.onSessionUpdated,
    required this.onLogout,
  });

  final AuthSession session;
  final ValueChanged<AuthSession> onSessionUpdated;
  final VoidCallback onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _showCompletedPools = false;
  bool _loading = true;
  List<PoolModel> _pools = const [];
  List<AppNotificationModel> _notifications = const [];
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = widget.session.user;
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
    });

    try {
      final results = await Future.wait([
        ApiService.fetchPools(widget.session.token),
        ApiService.fetchNotifications(widget.session.token),
        ApiService.getProfile(widget.session.token),
      ]);

      final pools = results[0] as List<PoolModel>;
      final notifications = results[1] as List<AppNotificationModel>;
      final profile = results[2] as UserProfile;
      final session = AuthSession(token: widget.session.token, user: profile);
      await SessionService.saveSession(session);

      if (!mounted) {
        return;
      }

      setState(() {
        _pools = pools;
        _notifications = notifications;
        _profile = profile;
        _loading = false;
      });
      widget.onSessionUpdated(session);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _openCreatePool() async {
    final draftPool = await Navigator.push<PoolModel>(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePoolScreen(
          currentUser: _profile,
          token: widget.session.token,
        ),
      ),
    );

    if (draftPool == null) {
      return;
    }

    try {
      final createdPool = await ApiService.createPool(widget.session.token, draftPool);
      setState(() {
        _pools = [createdPool, ..._pools];
      });
      await _refresh();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _openPool(PoolModel pool) async {
    final updatedPool = await Navigator.push<PoolModel>(
      context,
      MaterialPageRoute(
        builder: (_) => PoolDetailsScreen(
          token: widget.session.token,
          pool: pool,
          currentUser: _profile,
          onPoolUpdated: _replacePool,
          onPoolDeleted: _removePool,
        ),
      ),
    );

    if (updatedPool != null) {
      _replacePool(updatedPool);
    }
  }

  void _replacePool(PoolModel updatedPool) {
    setState(() {
      _pools = _pools
          .map((pool) => pool.id == updatedPool.id ? updatedPool : pool)
          .toList();
    });
  }

  void _removePool(String poolId) {
    setState(() {
      _pools = _pools.where((pool) => pool.id != poolId).toList();
    });
  }

  Future<void> _editProfile() async {
    final updated = await showDialog<UserProfile>(
      context: context,
      builder: (context) => _EditProfileDialog(profile: _profile),
    );

    if (updated == null) {
      return;
    }

    try {
      final saved = await ApiService.updateProfile(widget.session.token, updated);
      final session = AuthSession(token: widget.session.token, user: saved);
      await SessionService.saveSession(session);
      widget.onSessionUpdated(session);
      setState(() {
        _profile = saved;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _markNotificationRead(AppNotificationModel notification) async {
    try {
      final updated = await ApiService.markNotificationRead(
        token: widget.session.token,
        notificationId: notification.id,
        read: true,
      );
      setState(() {
        _notifications = _notifications
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePools = _pools.where((pool) => !pool.payoutCompleted).toList();
    final completedPools = _pools.where((pool) => pool.payoutCompleted).toList();
    final pages = [
      _HomeTab(
        profile: _profile,
        activePools: activePools,
        completedPools: completedPools,
        showCompletedPools: _showCompletedPools,
        onToggleCompletedPools: (value) {
          setState(() {
            _showCompletedPools = value;
          });
        },
        onCreatePool: _openCreatePool,
        onOpenPool: _openPool,
      ),
      NotificationsScreen(
        notifications: _notifications,
        onMarkRead: _markNotificationRead,
      ),
      ProfileScreen(
        profile: _profile,
        pools: _pools,
        onEdit: _editProfile,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                child: IndexedStack(index: _currentIndex, children: pages),
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
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alerts',
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
    required this.profile,
    required this.activePools,
    required this.completedPools,
    required this.showCompletedPools,
    required this.onToggleCompletedPools,
    required this.onCreatePool,
    required this.onOpenPool,
  });

  final UserProfile profile;
  final List<PoolModel> activePools;
  final List<PoolModel> completedPools;
  final bool showCompletedPools;
  final ValueChanged<bool> onToggleCompletedPools;
  final VoidCallback onCreatePool;
  final ValueChanged<PoolModel> onOpenPool;

  @override
  Widget build(BuildContext context) {
    final pools = [...activePools, ...completedPools];
    final totalCollected = pools.fold<int>(0, (sum, pool) => sum + pool.collectedAmount);
    final totalTarget = pools.fold<int>(0, (sum, pool) => sum + pool.targetAmount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        Text('Hey ${profile.name.split(' ').first}', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Your live pools, profile, and notifications are now driven by the backend.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: AppTheme.ink,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Live pool control',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create pools, update members, track contributions, and notify people automatically.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _HeroStat(label: 'Collected', value: 'Rs.$totalCollected'),
                  _HeroStat(label: 'Targeted', value: 'Rs.$totalTarget'),
                  _HeroStat(label: 'Pools', value: '${pools.length} live'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _PoolFilterButton(
                label: 'Active Pools',
                count: activePools.length,
                selected: !showCompletedPools,
                onTap: () => onToggleCompletedPools(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PoolFilterButton(
                label: 'Completed Pools',
                count: completedPools.length,
                selected: showCompletedPools,
                onTap: () => onToggleCompletedPools(true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!showCompletedPools && activePools.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Text('No active pools right now.'),
          ),
        if (!showCompletedPools)
          ...activePools.map(
          (pool) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => onOpenPool(pool),
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
                    Text(pool.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(pool.description),
                    const SizedBox(height: 14),
                    Text(
                      'Rs.${pool.collectedAmount} collected / Rs.${pool.targetAmount} target',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: pool.progress, minHeight: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showCompletedPools && completedPools.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: const Text('No completed pools yet.'),
          ),
        if (showCompletedPools)
          ...completedPools.map(
          (pool) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () => onOpenPool(pool),
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
                        Expanded(
                          child: Text(pool.name, style: Theme.of(context).textTheme.titleLarge),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.softGreen,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Completed',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(pool.description),
                    const SizedBox(height: 14),
                    Text(
                      'Payout Rs.${pool.payoutAmount ?? pool.collectedAmount}',
                      style: const TextStyle(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pool.settlementMode == PoolSettlementMode.adminControl
                          ? 'Sent to admin control flow'
                          : 'Released to members',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PoolFilterButton extends StatelessWidget {
  const _PoolFilterButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppTheme.ink : AppTheme.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count pool${count == 1 ? '' : 's'}',
              style: TextStyle(
                color: selected ? const Color(0xFFD2D7D3) : AppTheme.slate,
              ),
            ),
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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFD2D7D3))),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _cityController;
  late final TextEditingController _upiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _mobileController = TextEditingController(text: widget.profile.mobileNumber);
    _cityController = TextEditingController(text: widget.profile.city);
    _upiController = TextEditingController(text: widget.profile.upiId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _cityController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _mobileController, decoration: const InputDecoration(labelText: 'Mobile Number')),
            const SizedBox(height: 12),
            TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 12),
            TextField(controller: _upiController, decoration: const InputDecoration(labelText: 'UPI ID')),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty ||
                _emailController.text.trim().isEmpty ||
                _mobileController.text.trim().isEmpty ||
                _cityController.text.trim().isEmpty ||
                _upiController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fill every profile field before saving.')),
              );
              return;
            }

            Navigator.pop(
              context,
              widget.profile.copyWith(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                mobileNumber: _mobileController.text.trim(),
                city: _cityController.text.trim(),
                upiId: _upiController.text.trim(),
                profileCompleted: true,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

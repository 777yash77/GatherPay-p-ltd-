import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'contribute_screen.dart';
import 'edit_pool_screen.dart';

class PoolDetailsScreen extends StatefulWidget {
  const PoolDetailsScreen({
    super.key,
    required this.token,
    required this.pool,
    required this.currentUser,
    required this.onPoolUpdated,
    required this.onPoolDeleted,
  });

  final String token;
  final PoolModel pool;
  final UserProfile currentUser;
  final ValueChanged<PoolModel> onPoolUpdated;
  final ValueChanged<String> onPoolDeleted;

  @override
  State<PoolDetailsScreen> createState() => _PoolDetailsScreenState();
}

class _PoolDetailsScreenState extends State<PoolDetailsScreen> {
  late PoolModel _pool;
  final TextEditingController _chatController = TextEditingController();
  List<PoolChatMessage> _chatMessages = const [];
  bool _chatLoading = true;
  bool _sendingMessage = false;
  bool _processingPayout = false;

  @override
  void initState() {
    super.initState();
    _pool = widget.pool;
    _loadChat();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  bool get _isAdmin => _pool.members.any(
        (member) =>
            member.phoneNumber == widget.currentUser.mobileNumber &&
            member.role == PoolMemberRole.admin,
      );

  Future<void> _openContribute() async {
    final updatedPool = await Navigator.push<PoolModel>(
      context,
      MaterialPageRoute(
        builder: (_) => ContributeScreen(
          token: widget.token,
          pool: _pool,
          currentUser: widget.currentUser,
          onPoolUpdated: _applyPoolUpdate,
        ),
      ),
    );

    if (updatedPool != null) {
      _applyPoolUpdate(updatedPool);
    }
  }

  Future<void> _loadChat() async {
    try {
      final messages = await ApiService.fetchPoolChat(
        token: widget.token,
        poolId: _pool.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _chatMessages = messages;
        _chatLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _chatLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _openEdit() async {
    final draft = await Navigator.push<PoolModel>(
      context,
      MaterialPageRoute(
        builder: (_) => EditPoolScreen(
          pool: _pool,
          token: widget.token,
          currentUser: widget.currentUser,
        ),
      ),
    );
    if (draft == null) {
      return;
    }

    try {
      final updatedPool = await ApiService.updatePool(widget.token, draft);
      _applyPoolUpdate(updatedPool);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deletePool() async {
    try {
      await ApiService.deletePool(widget.token, _pool.id);
      widget.onPoolDeleted(_pool.id);
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _applyPoolUpdate(PoolModel updatedPool) {
    setState(() {
      _pool = updatedPool;
    });
    widget.onPoolUpdated(updatedPool);
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    if (message.isEmpty || _sendingMessage) {
      return;
    }

    setState(() {
      _sendingMessage = true;
    });

    try {
      final created = await ApiService.sendPoolChatMessage(
        token: widget.token,
        poolId: _pool.id,
        message: message,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _chatMessages = [..._chatMessages, created];
        _chatController.clear();
        _sendingMessage = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sendingMessage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _runPayout({required bool force}) async {
    if (_processingPayout) {
      return;
    }

    setState(() {
      _processingPayout = true;
    });

    try {
      final updatedPool = await ApiService.payoutPool(
        token: widget.token,
        poolId: _pool.id,
        force: force,
      );
      if (!mounted) {
        return;
      }
      _applyPoolUpdate(updatedPool);
      setState(() {
        _processingPayout = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            force
                ? 'Force payout completed and members were notified.'
                : 'Payout completed and members were notified.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _processingPayout = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = (_pool.targetAmount - _pool.collectedAmount).clamp(0, _pool.targetAmount);
    final canRunNormalPayout = _pool.payoutEligible && !_pool.payoutCompleted;
    final canRunForcePayout = _isAdmin && _pool.forcePayoutEligible && !_pool.payoutEligible && !_pool.payoutCompleted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pool Details'),
        actions: [
          if (_isAdmin)
            IconButton(
              onPressed: _deletePool,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.ink, borderRadius: BorderRadius.circular(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_pool.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(_pool.description, style: const TextStyle(color: Color(0xFFD2D7D3))),
                  const SizedBox(height: 16),
                  Text('Rs.${_pool.collectedAmount} collected / Rs.${_pool.targetAmount} target', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _pool.progress, minHeight: 12),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openContribute,
                    icon: const Icon(Icons.payments_rounded),
                    label: const Text('Contribute'),
                  ),
                ),
                if (_isAdmin) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Pool'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            Container(
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
                  Text('Payout Control', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (_pool.payoutCompleted) ...[
                    Text(
                      _pool.settlementMode == PoolSettlementMode.adminControl
                          ? 'Released to admin ${_pool.payoutTriggeredBy ?? _pool.adminName}'
                          : 'Released to members',
                    ),
                    const SizedBox(height: 4),
                    Text('Amount: Rs.${_pool.payoutAmount ?? _pool.collectedAmount}'),
                    if (_pool.payoutTriggeredAt != null)
                      Text('At: ${_pool.payoutTriggeredAt!.toLocal()}'),
                  ] else ...[
                    Text(
                      canRunNormalPayout
                          ? 'Full target reached. Payout is ready now.'
                          : _pool.forcePayoutEligible
                              ? 'Half target reached. Admin can force payout now.'
                              : 'Payout unlocks at full target. Admin force payout unlocks at 50%.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: canRunNormalPayout && !_processingPayout
                                ? () => _runPayout(force: false)
                                : null,
                            icon: const Icon(Icons.account_balance_wallet_outlined),
                            label: const Text('Payout'),
                          ),
                        ),
                        if (_isAdmin) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: canRunForcePayout && !_processingPayout
                                  ? () => _runPayout(force: true)
                                  : null,
                              icon: const Icon(Icons.priority_high_rounded),
                              label: const Text('Force Payout'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
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
                  Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Target amount: Rs.${_pool.targetAmount}'),
                  Text('Collected amount: Rs.${_pool.collectedAmount}'),
                  Text('Remaining amount: Rs.$remainingAmount'),
                  Text('Admin: ${_pool.adminName}'),
                  Text('Mode: ${_pool.settlementLabel}'),
                  Text('Live share: Rs.${_pool.liveShareAmount} per member'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Pool Chat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                children: [
                  if (_chatLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    )
                  else if (_chatMessages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No messages yet. Start the pool conversation here.'),
                    )
                  else
                    ..._chatMessages.map(
                      (message) {
                        final isMe = message.senderPhoneNumber == widget.currentUser.mobileNumber;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isMe ? AppTheme.softGreen : AppTheme.cloud,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMe ? 'You' : message.senderName,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(message.message),
                                const SizedBox(height: 6),
                                Text(
                                  message.createdAt.toLocal().toString(),
                                  style: const TextStyle(color: AppTheme.slate, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Send an update to everyone in this pool',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _sendingMessage ? null : _sendMessage,
                        child: Text(_sendingMessage ? 'Sending...' : 'Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Members', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ..._pool.members.map(
              (member) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: member.phoneNumber == widget.currentUser.mobileNumber ? AppTheme.softGreen : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(member.phoneNumber),
                    const SizedBox(height: 6),
                    Text('Contributed Rs.${member.contributedAmount} / Target share Rs.${_pool.perMemberShare}'),
                    const SizedBox(height: 4),
                    Text('${member.roleLabel} • ${member.approvalsGiven} approvals • Activity ${member.activityScore}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

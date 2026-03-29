import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../services/mock_data_service.dart';
import '../theme/app_theme.dart';

class CreatePoolScreen extends StatefulWidget {
  const CreatePoolScreen({super.key});

  @override
  State<CreatePoolScreen> createState() => _CreatePoolScreenState();
}

class _CreatePoolScreenState extends State<CreatePoolScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _memberCountController = TextEditingController(text: '4');
  final _searchController = TextEditingController();

  PoolStyle _style = PoolStyle.strict;
  PoolSettlementMode _settlementMode = PoolSettlementMode.splitwise;
  bool _isSyncingContacts = false;

  List<MemberDirectoryEntry> _phoneContacts = [];
  List<MemberDirectoryEntry> _suggestions = [];
  final List<MemberDirectoryEntry> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _syncContacts();
  }

  Future<void> _syncContacts() async {
    setState(() {
      _isSyncingContacts = true;
    });

    final contacts = await MockDataService.syncPhoneContacts();

    if (!mounted) {
      return;
    }

    setState(() {
      _phoneContacts = contacts;
      _suggestions = contacts;
      _isSyncingContacts = false;
    });
  }

  void _searchDirectory(String query) {
    setState(() {
      _suggestions = MockDataService.searchDirectory(
        query: query,
        phoneContacts: _phoneContacts,
      );
    });
  }

  void _addMember(MemberDirectoryEntry member) {
    final alreadyAdded = _selectedMembers.any(
      (entry) => entry.phoneNumber == member.phoneNumber,
    );

    if (alreadyAdded) {
      return;
    }

    setState(() {
      _selectedMembers.add(member);
    });
  }

  void _removeMember(MemberDirectoryEntry member) {
    setState(() {
      _selectedMembers.removeWhere(
        (entry) => entry.phoneNumber == member.phoneNumber,
      );
    });
  }

  void _createPool() {
    if (_nameController.text.trim().isEmpty ||
        _targetController.text.trim().isEmpty ||
        _selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a pool name, target amount, and at least one member.'),
        ),
      );
      return;
    }

    final targetAmount = int.tryParse(_targetController.text.trim());
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target amount should be a valid number.'),
        ),
      );
      return;
    }

    final members = _selectedMembers
        .map(
          (member) => PoolMember(
            name: member.name,
            phoneNumber: member.phoneNumber,
            contributedAmount: 0,
            approvalsGiven: member.source == MemberSource.phoneContact ? 2 : 1,
            activityScore: member.source == MemberSource.phoneContact ? 80 : 68,
          ),
        )
        .toList();

    final pool = PoolModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? 'A fresh pool built for shared plans and smooth approvals.'
          : _descriptionController.text.trim(),
      targetAmount: targetAmount,
      adminName: 'Yaswanth Kumar',
      style: _style,
      settlementMode: _settlementMode,
      category: 'Custom',
      createdAt: DateTime.now(),
      members: [
        const PoolMember(
          name: 'Yaswanth Kumar',
          phoneNumber: '+91 90000 00000',
          contributedAmount: 0,
          approvalsGiven: 5,
          activityScore: 100,
        ),
        ...members,
      ],
    );

    Navigator.pop(context, pool);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _descriptionController.dispose();
    _memberCountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specsDescription = _style == PoolStyle.strict
        ? 'Strict means every member approval is required before checkout.'
        : 'Casual means majority approval can release half the money, and the next admin becomes the most active member.';

    final payoutDescription = switch (_settlementMode) {
      PoolSettlementMode.splitwise =>
        'Splitwise sends each user an equal share during checkout.',
      PoolSettlementMode.adminControl =>
        'Admin Control sends the full pool amount to the admin.',
      PoolSettlementMode.getBack =>
        'Get Back returns only the amount each member personally contributed.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Pool'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pool basics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pool name',
                      hintText: 'Trip fund, rent helper, studio setup...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Pool description',
                      hintText: 'Tell members what this pool is for and how it should be used.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _targetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Target amount',
                            hintText: '20000',
                            prefixText: 'Rs. ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _memberCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Expected members',
                            hintText: '4',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Pool specification',
              subtitle: specsDescription,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Strict'),
                    selected: _style == PoolStyle.strict,
                    onSelected: (_) {
                      setState(() {
                        _style = PoolStyle.strict;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Casual'),
                    selected: _style == PoolStyle.casual,
                    onSelected: (_) {
                      setState(() {
                        _style = PoolStyle.casual;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Checkout mode',
              subtitle: payoutDescription,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Splitwise'),
                    selected: _settlementMode == PoolSettlementMode.splitwise,
                    onSelected: (_) {
                      setState(() {
                        _settlementMode = PoolSettlementMode.splitwise;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Admin Control'),
                    selected: _settlementMode == PoolSettlementMode.adminControl,
                    onSelected: (_) {
                      setState(() {
                        _settlementMode = PoolSettlementMode.adminControl;
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Get Back'),
                    selected: _settlementMode == PoolSettlementMode.getBack,
                    onSelected: (_) {
                      setState(() {
                        _settlementMode = PoolSettlementMode.getBack;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Add members',
              subtitle:
                  'We sync phone contacts first. If the typed number is not found there, matched GatherPay users from the app database appear below.',
              action: TextButton.icon(
                onPressed: _isSyncingContacts ? null : _syncContacts,
                icon: _isSyncingContacts
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync_rounded),
                label: const Text('Sync contacts'),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.phone,
                    onChanged: _searchDirectory,
                    decoration: const InputDecoration(
                      labelText: 'Search by name or phone number',
                      hintText: 'Type a name or number',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_selectedMembers.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedMembers
                          .map(
                            (member) => Chip(
                              label: Text('${member.name} | ${member.phoneNumber}'),
                              onDeleted: () => _removeMember(member),
                            ),
                          )
                          .toList(),
                    ),
                  if (_selectedMembers.isNotEmpty) const SizedBox(height: 14),
                  ..._suggestions.take(6).map(
                    (member) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: member.source == MemberSource.phoneContact
                            ? AppTheme.mint
                            : AppTheme.peach,
                        child: Text(
                          member.avatarSeed.isEmpty
                              ? member.name.substring(0, 1).toUpperCase()
                              : member.avatarSeed.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(member.name),
                      subtitle: Text(
                        '${member.phoneNumber} | ${member.source == MemberSource.phoneContact ? 'Phone contact' : 'Found in GatherPay'}',
                      ),
                      trailing: IconButton(
                        onPressed: () => _addMember(member),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ),
                  ),
                  if (_suggestions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'No contact match yet. Try a full number to trigger GatherPay database lookup.',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createPool,
                child: const Text('Create Pool'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? action;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

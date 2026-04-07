import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class EditPoolScreen extends StatefulWidget {
  const EditPoolScreen({
    super.key,
    required this.pool,
    required this.token,
    required this.currentUser,
  });

  final PoolModel pool;
  final String token;
  final UserProfile currentUser;

  @override
  State<EditPoolScreen> createState() => _EditPoolScreenState();
}

class _EditPoolScreenState extends State<EditPoolScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  final _memberNameController = TextEditingController();
  final _memberPhoneController = TextEditingController();
  final _directorySearchController = TextEditingController();
  late PoolStyle _style;
  late PoolSettlementMode _settlementMode;
  late List<PoolMember> _members;
  List<MemberDirectoryEntry> _directoryResults = const [];
  bool _searchingDirectory = false;
  String _lastDirectoryQuery = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pool.name);
    _targetController = TextEditingController(text: widget.pool.targetAmount.toString());
    _descriptionController = TextEditingController(text: widget.pool.description);
    _categoryController = TextEditingController(text: widget.pool.category);
    _style = widget.pool.style;
    _settlementMode = widget.pool.settlementMode;
    _members = widget.pool.members.map((member) => member.copyWith()).toList();
  }

  bool _memberExists(String phone) {
    final normalizedPhone = normalizePhoneNumber(phone);
    return _members.any(
      (member) => normalizePhoneNumber(member.phoneNumber) == normalizedPhone,
    );
  }

  void _addMember() {
    final name = _memberNameController.text.trim();
    final phone = _memberPhoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      return;
    }
    final normalizedPhone = normalizePhoneNumber(phone);
    if (normalizedPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid member phone number.')),
      );
      return;
    }
    if (_memberExists(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member already exists in this pool.')),
      );
      return;
    }
    setState(() {
      _members = [
        ..._members,
        PoolMember(
          id: '',
          name: name,
          phoneNumber: normalizedPhone,
          contributedAmount: 0,
          approvalsGiven: 0,
          activityScore: 0,
        ),
      ];
      _memberNameController.clear();
      _memberPhoneController.clear();
    });
  }

  void _addMemberFromEntry(MemberDirectoryEntry entry) {
    if (_memberExists(entry.phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member already exists in this pool.')),
      );
      return;
    }
    setState(() {
      _members = [
        ..._members,
        PoolMember(
          id: entry.id,
          name: entry.name,
          phoneNumber: entry.phoneNumber,
          contributedAmount: 0,
          approvalsGiven: 0,
          activityScore: entry.isRegistered ? 10 : 0,
        ),
      ];
    });
  }

  Future<void> _searchDirectory(String query) async {
    final trimmed = query.trim();
    _lastDirectoryQuery = trimmed;
    if (trimmed.isEmpty) {
      setState(() {
        _directoryResults = const [];
      });
      return;
    }
    setState(() {
      _searchingDirectory = true;
    });
    try {
      final results = await ApiService.searchUsers(
        token: widget.token,
        query: trimmed,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _directoryResults = results
            .where((entry) => !_memberExists(entry.phoneNumber))
            .toList();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _searchingDirectory = false;
        });
      }
    }
  }

  Future<void> _importPhoneContacts() async {
    final granted = await FlutterContacts.requestPermission(readonly: true);
    if (!granted) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission is needed to import phone contacts.')),
      );
      return;
    }
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    if (!mounted) {
      return;
    }
    final entries = contacts
        .where((contact) => contact.phones.isNotEmpty)
        .map((contact) => MemberDirectoryEntry(
              id: contact.id,
              name: contact.displayName,
              phoneNumber: normalizePhoneNumber(contact.phones.first.number),
              source: MemberSource.phoneContact,
              isRegistered: false,
            ))
        .where((entry) => !_memberExists(entry.phoneNumber))
        .take(30)
        .toList();
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No new phone contacts available to add.')),
      );
      return;
    }
    final picked = await showModalBottomSheet<MemberDirectoryEntry>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditDirectoryPickerSheet(
        title: 'Phone Contacts',
        entries: entries,
      ),
    );
    if (picked != null) {
      _addMemberFromEntry(picked);
    }
  }

  void _save() {
    final targetAmount = int.tryParse(_targetController.text.trim());
    if (_nameController.text.trim().isEmpty || targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a valid name and target amount.')),
      );
      return;
    }
    final adminCount = _members.where((member) => member.role == PoolMemberRole.admin).length;
    if (adminCount != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exactly one admin is required.')),
      );
      return;
    }
    final admin = _members.firstWhere((member) => member.role == PoolMemberRole.admin);
    Navigator.pop(
      context,
      widget.pool.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        targetAmount: targetAmount,
        category: _categoryController.text.trim(),
        style: _style,
        settlementMode: _settlementMode,
        adminName: admin.name,
        members: _members,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _memberNameController.dispose();
    _memberPhoneController.dispose();
    _directorySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pool')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _EditCard(
              title: 'Pool basics',
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Pool name')),
                  const SizedBox(height: 12),
                  TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 12),
                  TextField(controller: _targetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target amount', prefixText: 'Rs. ')),
                  const SizedBox(height: 12),
                  TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _EditCard(
              title: 'Rules',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(label: const Text('Strict'), selected: _style == PoolStyle.strict, onSelected: (_) => setState(() => _style = PoolStyle.strict)),
                  ChoiceChip(label: const Text('Casual'), selected: _style == PoolStyle.casual, onSelected: (_) => setState(() => _style = PoolStyle.casual)),
                  ChoiceChip(label: const Text('Splitwise'), selected: _settlementMode == PoolSettlementMode.splitwise, onSelected: (_) => setState(() => _settlementMode = PoolSettlementMode.splitwise)),
                  ChoiceChip(label: const Text('Admin Control'), selected: _settlementMode == PoolSettlementMode.adminControl, onSelected: (_) => setState(() => _settlementMode = PoolSettlementMode.adminControl)),
                  ChoiceChip(label: const Text('Get Back'), selected: _settlementMode == PoolSettlementMode.getBack, onSelected: (_) => setState(() => _settlementMode = PoolSettlementMode.getBack)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _EditCard(
              title: 'Members and permissions',
              child: Column(
                children: [
                  TextField(
                    controller: _directorySearchController,
                    onChanged: _searchDirectory,
                    decoration: InputDecoration(
                      labelText: 'Search registered GatherPay users',
                      suffixIcon: _searchingDirectory
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.search),
                    ),
                  ),
                  if (_directoryResults.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._directoryResults.take(5).map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_search_outlined),
                        title: Text(entry.name),
                        subtitle: Text('${entry.phoneNumber}${entry.email.isNotEmpty ? ' • ${entry.email}' : ''}'),
                        trailing: TextButton(
                          onPressed: () => _addMemberFromEntry(entry),
                          child: const Text('Add'),
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                  ] else if (_lastDirectoryQuery.isNotEmpty && !_searchingDirectory) ...[
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'No registered GatherPay user found for that search. If it is your own number, you are already in the pool.',
                        style: TextStyle(color: AppTheme.slate),
                      ),
                    ),
                    const Divider(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _importPhoneContacts,
                      icon: const Icon(Icons.contact_phone_outlined),
                      label: const Text('Import From Phone Contacts'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _memberNameController, decoration: const InputDecoration(labelText: 'Member name')),
                  const SizedBox(height: 12),
                  TextField(controller: _memberPhoneController, decoration: const InputDecoration(labelText: 'Member phone number')),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: OutlinedButton(onPressed: _addMember, child: const Text('Add Member Manually'))),
                  const SizedBox(height: 12),
                  ..._members.map(
                    (member) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: member.isAdmin ? AppTheme.softGreen : AppTheme.cloud,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text('${member.name} • ${member.phoneNumber}')),
                              IconButton(
                                onPressed: member.isAdmin
                                    ? null
                                    : () => setState(() {
                                          _members.removeWhere((item) => item.phoneNumber == member.phoneNumber);
                                        }),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Admin'),
                                  selected: member.role == PoolMemberRole.admin,
                                  onSelected: (_) {
                                    setState(() {
                                      _members = _members
                                          .map((item) => item.phoneNumber == member.phoneNumber
                                              ? item.copyWith(role: PoolMemberRole.admin)
                                              : item.copyWith(role: PoolMemberRole.member))
                                          .toList();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Member'),
                                  selected: member.role == PoolMemberRole.member,
                                  onSelected: (_) {
                                    if (_members.where((item) => item.role == PoolMemberRole.admin).length == 1 && member.isAdmin) {
                                      return;
                                    }
                                    setState(() {
                                      _members = _members
                                          .map((item) => item.phoneNumber == member.phoneNumber
                                              ? item.copyWith(role: PoolMemberRole.member)
                                              : item)
                                          .toList();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Save Changes'))),
          ],
        ),
      ),
    );
  }
}

class _EditCard extends StatelessWidget {
  const _EditCard({required this.title, required this.child});

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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EditDirectoryPickerSheet extends StatelessWidget {
  const _EditDirectoryPickerSheet({
    required this.title,
    required this.entries,
  });

  final String title;
  final List<MemberDirectoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.name),
                    subtitle: Text(entry.phoneNumber),
                    trailing: TextButton(
                      onPressed: () => Navigator.pop(context, entry),
                      child: const Text('Add'),
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
}

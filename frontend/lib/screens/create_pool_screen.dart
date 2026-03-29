import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/app_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CreatePoolScreen extends StatefulWidget {
  const CreatePoolScreen({
    super.key,
    required this.currentUser,
    required this.token,
  });

  final UserProfile currentUser;
  final String token;

  @override
  State<CreatePoolScreen> createState() => _CreatePoolScreenState();
}

class _CreatePoolScreenState extends State<CreatePoolScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Custom');
  final _memberNameController = TextEditingController();
  final _memberPhoneController = TextEditingController();
  final _directorySearchController = TextEditingController();

  PoolStyle _style = PoolStyle.strict;
  PoolSettlementMode _settlementMode = PoolSettlementMode.splitwise;
  final List<PoolMember> _members = [];
  List<MemberDirectoryEntry> _directoryResults = const [];
  bool _searchingDirectory = false;
  String _lastDirectoryQuery = '';

  bool _memberExists(String phone) {
    final normalizedPhone = normalizePhoneNumber(phone);
    return _members.any(
          (member) => normalizePhoneNumber(member.phoneNumber) == normalizedPhone,
        ) ||
        normalizedPhone == normalizePhoneNumber(widget.currentUser.mobileNumber);
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
        const SnackBar(content: Text('That member is already in the pool.')),
      );
      return;
    }
    setState(() {
      _members.add(
        PoolMember(
          id: '',
          name: name,
          phoneNumber: normalizedPhone,
          contributedAmount: 0,
          approvalsGiven: 0,
          activityScore: 0,
        ),
      );
      _memberNameController.clear();
      _memberPhoneController.clear();
    });
  }

  void _addMemberFromEntry(MemberDirectoryEntry entry) {
    if (_memberExists(entry.phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That member is already in the pool.')),
      );
      return;
    }
    setState(() {
      _members.add(
        PoolMember(
          id: entry.id,
          name: entry.name,
          phoneNumber: entry.phoneNumber,
          contributedAmount: 0,
          approvalsGiven: 0,
          activityScore: entry.isRegistered ? 10 : 0,
        ),
      );
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
      builder: (context) => _DirectoryPickerSheet(
        title: 'Phone Contacts',
        entries: entries,
      ),
    );
    if (picked != null) {
      _addMemberFromEntry(picked);
    }
  }

  void _createPool() {
    final targetAmount = int.tryParse(_targetController.text.trim());
    if (_nameController.text.trim().isEmpty ||
        targetAmount == null ||
        targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a valid name and target amount.')),
      );
      return;
    }
    final pool = PoolModel(
      id: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? 'A fresh pool for shared plans.'
          : _descriptionController.text.trim(),
      targetAmount: targetAmount,
      adminName: widget.currentUser.name,
      style: _style,
      settlementMode: _settlementMode,
      category: _categoryController.text.trim().isEmpty ? 'Custom' : _categoryController.text.trim(),
      createdAt: DateTime.now(),
      members: [
        PoolMember(
          id: widget.currentUser.id,
          name: widget.currentUser.name,
          phoneNumber: normalizePhoneNumber(widget.currentUser.mobileNumber),
          contributedAmount: 0,
          approvalsGiven: 0,
          activityScore: 100,
          role: PoolMemberRole.admin,
        ),
        ..._members,
      ],
    );
    Navigator.pop(context, pool);
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
      appBar: AppBar(title: const Text('Create Pool')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _CardSection(
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
            _CardSection(
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
            _CardSection(
              title: 'Add members',
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
                        'No registered GatherPay user found for that search. Your own number is already included automatically.',
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _addMember,
                      child: const Text('Add Member Manually'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._members.map(
                    (member) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(member.name),
                      subtitle: Text(member.phoneNumber),
                      trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            _members.removeWhere((item) => item.phoneNumber == member.phoneNumber);
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

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

class _DirectoryPickerSheet extends StatelessWidget {
  const _DirectoryPickerSheet({
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

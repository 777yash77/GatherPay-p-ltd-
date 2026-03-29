import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/app_models.dart';

class MockDataService {
  static final UserProfile profile = const UserProfile(
    name: 'Yaswanth Kumar',
    handle: '@yas.gathers',
    email: 'yaswanth@gatherpay.app',
    upiId: 'yaswanth@upi',
    city: 'Hyderabad',
    streakDays: 17,
    totalSaved: 128500,
    completedPools: 11,
  );

  static List<PoolModel> samplePools() {
    return [
      PoolModel(
        name: 'Goa Escape',
        description:
            'A sunny trip pool for stays, rides, and last-minute beach plans.',
        targetAmount: 20000,
        adminName: 'Rahul',
        style: PoolStyle.strict,
        settlementMode: PoolSettlementMode.splitwise,
        category: 'Travel',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        members: const [
          PoolMember(
            name: 'Rahul',
            phoneNumber: '+91 90000 11111',
            contributedAmount: 5000,
            approvalsGiven: 3,
            activityScore: 96,
          ),
          PoolMember(
            name: 'Arun',
            phoneNumber: '+91 90000 22222',
            contributedAmount: 4500,
            approvalsGiven: 4,
            activityScore: 90,
          ),
          PoolMember(
            name: 'Vikram',
            phoneNumber: '+91 90000 33333',
            contributedAmount: 3500,
            approvalsGiven: 2,
            activityScore: 84,
          ),
          PoolMember(
            name: 'Karthik',
            phoneNumber: '+91 90000 44444',
            contributedAmount: 3000,
            approvalsGiven: 3,
            activityScore: 88,
          ),
        ],
      ),
      PoolModel(
        name: 'Studio Upgrade',
        description:
            'Friends funding better lighting, mics, and a clean setup for shoots.',
        targetAmount: 60000,
        adminName: 'Meghana',
        style: PoolStyle.casual,
        settlementMode: PoolSettlementMode.adminControl,
        category: 'Creative',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        members: const [
          PoolMember(
            name: 'Meghana',
            phoneNumber: '+91 90100 77777',
            contributedAmount: 12000,
            approvalsGiven: 8,
            activityScore: 99,
          ),
          PoolMember(
            name: 'Dharani',
            phoneNumber: '+91 90100 88888',
            contributedAmount: 9000,
            approvalsGiven: 7,
            activityScore: 93,
          ),
          PoolMember(
            name: 'Rohit',
            phoneNumber: '+91 90100 99999',
            contributedAmount: 8500,
            approvalsGiven: 6,
            activityScore: 91,
          ),
          PoolMember(
            name: 'Nikhil',
            phoneNumber: '+91 90200 12345',
            contributedAmount: 7000,
            approvalsGiven: 5,
            activityScore: 82,
          ),
          PoolMember(
            name: 'Asha',
            phoneNumber: '+91 90300 12345',
            contributedAmount: 6500,
            approvalsGiven: 5,
            activityScore: 80,
          ),
        ],
      ),
    ];
  }

  static List<PaymentRecord> samplePayments() {
    return [
      PaymentRecord(
        title: 'Contribution Received',
        amount: 3500,
        status: 'Settled',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        poolName: 'Goa Escape',
      ),
      PaymentRecord(
        title: 'Checkout Request',
        amount: 12000,
        status: 'Awaiting approvals',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        poolName: 'Studio Upgrade',
      ),
      PaymentRecord(
        title: 'Refund Snapshot',
        amount: 2100,
        status: 'Ready for get back',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        poolName: 'Weekend Turf',
      ),
    ];
  }

  static final List<MemberDirectoryEntry> _dbDirectory = [
    const MemberDirectoryEntry(
      name: 'Priya Reddy',
      phoneNumber: '+91 98480 11111',
      source: MemberSource.appDatabase,
      avatarSeed: 'PR',
    ),
    const MemberDirectoryEntry(
      name: 'Teja Kumar',
      phoneNumber: '+91 98480 22222',
      source: MemberSource.appDatabase,
      avatarSeed: 'TK',
    ),
    const MemberDirectoryEntry(
      name: 'Nitya',
      phoneNumber: '+91 98480 33333',
      source: MemberSource.appDatabase,
      avatarSeed: 'NI',
    ),
    const MemberDirectoryEntry(
      name: 'Harsha',
      phoneNumber: '+91 90000 44444',
      source: MemberSource.appDatabase,
      avatarSeed: 'HA',
    ),
  ];

  static Future<List<MemberDirectoryEntry>> syncPhoneContacts() async {
    try {
      final hasPermission = await FlutterContacts.requestPermission(
        readonly: true,
      );

      if (!hasPermission) {
        return _fallbackPhoneContacts();
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );

      final mapped = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map(
            (contact) => MemberDirectoryEntry(
              name: contact.displayName.isEmpty
                  ? 'Unknown contact'
                  : contact.displayName,
              phoneNumber: contact.phones.first.number,
              source: MemberSource.phoneContact,
              avatarSeed: _avatarSeedFromName(contact.displayName),
              isRegistered: true,
            ),
          )
          .toList();

      return mapped.isEmpty ? _fallbackPhoneContacts() : mapped;
    } catch (_) {
      return _fallbackPhoneContacts();
    }
  }

  static List<MemberDirectoryEntry> searchDirectory({
    required String query,
    required List<MemberDirectoryEntry> phoneContacts,
  }) {
    final normalized = query.trim();
    final matches = phoneContacts
        .where((entry) => entry.matchesQuery(normalized))
        .toList();

    if (matches.isNotEmpty) {
      return matches;
    }

    final digitsOnly = normalized.replaceAll(RegExp(r'[^0-9+]'), '');
    final dbMatches = _dbDirectory
        .where(
          (entry) => entry.matchesQuery(
            digitsOnly.isEmpty ? normalized : digitsOnly,
          ),
        )
        .toList();

    return dbMatches;
  }

  static List<MemberDirectoryEntry> _fallbackPhoneContacts() {
    return const [
      MemberDirectoryEntry(
        name: 'Rahul',
        phoneNumber: '+91 90000 11111',
        source: MemberSource.phoneContact,
        avatarSeed: 'RA',
      ),
      MemberDirectoryEntry(
        name: 'Arun',
        phoneNumber: '+91 90000 22222',
        source: MemberSource.phoneContact,
        avatarSeed: 'AR',
      ),
      MemberDirectoryEntry(
        name: 'Vikram',
        phoneNumber: '+91 90000 33333',
        source: MemberSource.phoneContact,
        avatarSeed: 'VI',
      ),
      MemberDirectoryEntry(
        name: 'Karthik',
        phoneNumber: '+91 90000 44444',
        source: MemberSource.phoneContact,
        avatarSeed: 'KA',
      ),
    ];
  }

  static String _avatarSeedFromName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'GC';
    }

    return parts.map((part) => part.substring(0, 1).toUpperCase()).join();
  }
}

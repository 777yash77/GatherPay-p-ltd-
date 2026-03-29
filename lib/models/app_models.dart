enum MemberSource { phoneContact, appDatabase }

enum PoolStyle { strict, casual }

enum PoolSettlementMode { splitwise, adminControl, getBack }

class MemberDirectoryEntry {
  const MemberDirectoryEntry({
    required this.name,
    required this.phoneNumber,
    required this.source,
    this.avatarSeed = '',
    this.isRegistered = true,
  });

  final String name;
  final String phoneNumber;
  final MemberSource source;
  final String avatarSeed;
  final bool isRegistered;

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(normalized) ||
        phoneNumber.replaceAll(' ', '').contains(
              normalized.replaceAll(' ', ''),
            );
  }
}

class PoolMember {
  const PoolMember({
    required this.name,
    required this.phoneNumber,
    required this.contributedAmount,
    required this.approvalsGiven,
    required this.activityScore,
  });

  final String name;
  final String phoneNumber;
  final int contributedAmount;
  final int approvalsGiven;
  final int activityScore;
}

class PoolModel {
  const PoolModel({
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.adminName,
    required this.style,
    required this.settlementMode,
    required this.members,
    required this.createdAt,
    this.category = 'Shared Goal',
  });

  final String name;
  final String description;
  final int targetAmount;
  final String adminName;
  final PoolStyle style;
  final PoolSettlementMode settlementMode;
  final List<PoolMember> members;
  final DateTime createdAt;
  final String category;

  int get collectedAmount =>
      members.fold<int>(0, (sum, member) => sum + member.contributedAmount);

  double get progress =>
      targetAmount == 0 ? 0 : (collectedAmount / targetAmount).clamp(0, 1);

  int get approvalsNeeded {
    if (style == PoolStyle.strict) {
      return members.length;
    }

    return (members.length / 2).ceil();
  }

  int get casualReleaseAmount => collectedAmount ~/ 2;

  int get perMemberShare =>
      members.isEmpty ? 0 : (targetAmount / members.length).ceil();

  PoolMember? get nextAdminCandidate {
    if (members.isEmpty) {
      return null;
    }

    final sortedMembers = [...members]
      ..sort((a, b) => b.activityScore.compareTo(a.activityScore));
    return sortedMembers.first;
  }

  String get styleLabel => style == PoolStyle.strict ? 'Strict' : 'Casual';

  String get settlementLabel {
    switch (settlementMode) {
      case PoolSettlementMode.splitwise:
        return 'Splitwise';
      case PoolSettlementMode.adminControl:
        return 'Admin Control';
      case PoolSettlementMode.getBack:
        return 'Get Back';
    }
  }
}

class PaymentRecord {
  const PaymentRecord({
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.poolName,
  });

  final String title;
  final int amount;
  final String status;
  final DateTime createdAt;
  final String poolName;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.handle,
    required this.email,
    required this.upiId,
    required this.city,
    required this.streakDays,
    required this.totalSaved,
    required this.completedPools,
  });

  final String name;
  final String handle;
  final String email;
  final String upiId;
  final String city;
  final int streakDays;
  final int totalSaved;
  final int completedPools;
}

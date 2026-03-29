enum MemberSource { phoneContact, appDatabase }

enum PoolStyle { strict, casual }

enum PoolSettlementMode { splitwise, adminControl, getBack }

enum PoolMemberRole { admin, member }

String normalizePhoneNumber(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length > 10) {
    return digits.substring(digits.length - 10);
  }
  return digits;
}

class MemberDirectoryEntry {
  const MemberDirectoryEntry({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.source,
    this.email = '',
    this.avatarSeed = '',
    this.isRegistered = true,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final MemberSource source;
  final String email;
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

  factory MemberDirectoryEntry.fromUserJson(Map<String, dynamic> json) {
    return MemberDirectoryEntry(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      phoneNumber: normalizePhoneNumber(json['mobileNumber'] as String? ?? ''),
      email: json['email'] as String? ?? '',
      source: MemberSource.appDatabase,
      isRegistered: json['registered'] as bool? ?? true,
    );
  }
}

class PoolMember {
  const PoolMember({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.contributedAmount,
    required this.approvalsGiven,
    required this.activityScore,
    this.role = PoolMemberRole.member,
  });

  final String id;
  final String name;
  final String phoneNumber;
  final int contributedAmount;
  final int approvalsGiven;
  final int activityScore;
  final PoolMemberRole role;

  bool get isAdmin => role == PoolMemberRole.admin;

  String get roleLabel => isAdmin ? 'Admin' : 'Member';

  PoolMember copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    int? contributedAmount,
    int? approvalsGiven,
    int? activityScore,
    PoolMemberRole? role,
  }) {
    return PoolMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contributedAmount: contributedAmount ?? this.contributedAmount,
      approvalsGiven: approvalsGiven ?? this.approvalsGiven,
      activityScore: activityScore ?? this.activityScore,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': normalizePhoneNumber(phoneNumber),
      'contributedAmount': contributedAmount,
      'approvalsGiven': approvalsGiven,
      'activityScore': activityScore,
      'role': role.name.toUpperCase(),
    };
  }

  factory PoolMember.fromJson(Map<String, dynamic> json) {
    return PoolMember(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      phoneNumber: normalizePhoneNumber(json['phoneNumber'] as String? ?? ''),
      contributedAmount: (json['contributedAmount'] as num?)?.toInt() ?? 0,
      approvalsGiven: (json['approvalsGiven'] as num?)?.toInt() ?? 0,
      activityScore: (json['activityScore'] as num?)?.toInt() ?? 0,
      role: _roleFromApi(json['role'] as String?),
    );
  }
}

class PoolModel {
  const PoolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.adminName,
    required this.style,
    required this.settlementMode,
    required this.members,
    required this.createdAt,
    this.category = 'Shared Goal',
    this.payoutEligible = false,
    this.forcePayoutEligible = false,
    this.payoutCompleted = false,
    this.payoutType,
    this.payoutAmount,
    this.payoutTriggeredBy,
    this.payoutTriggeredAt,
  });

  final String id;
  final String name;
  final String description;
  final int targetAmount;
  final String adminName;
  final PoolStyle style;
  final PoolSettlementMode settlementMode;
  final List<PoolMember> members;
  final DateTime createdAt;
  final String category;
  final bool payoutEligible;
  final bool forcePayoutEligible;
  final bool payoutCompleted;
  final String? payoutType;
  final int? payoutAmount;
  final String? payoutTriggeredBy;
  final DateTime? payoutTriggeredAt;

  PoolModel copyWith({
    String? id,
    String? name,
    String? description,
    int? targetAmount,
    String? adminName,
    PoolStyle? style,
    PoolSettlementMode? settlementMode,
    List<PoolMember>? members,
    DateTime? createdAt,
    String? category,
    bool? payoutEligible,
    bool? forcePayoutEligible,
    bool? payoutCompleted,
    String? payoutType,
    int? payoutAmount,
    String? payoutTriggeredBy,
    DateTime? payoutTriggeredAt,
  }) {
    return PoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      adminName: adminName ?? this.adminName,
      style: style ?? this.style,
      settlementMode: settlementMode ?? this.settlementMode,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      payoutEligible: payoutEligible ?? this.payoutEligible,
      forcePayoutEligible: forcePayoutEligible ?? this.forcePayoutEligible,
      payoutCompleted: payoutCompleted ?? this.payoutCompleted,
      payoutType: payoutType ?? this.payoutType,
      payoutAmount: payoutAmount ?? this.payoutAmount,
      payoutTriggeredBy: payoutTriggeredBy ?? this.payoutTriggeredBy,
      payoutTriggeredAt: payoutTriggeredAt ?? this.payoutTriggeredAt,
    );
  }

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

  PoolMember? get adminMember {
    for (final member in members) {
      if (member.isAdmin) {
        return member;
      }
    }

    return members.isEmpty ? null : members.first;
  }

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

  int get liveShareAmount =>
      members.isEmpty ? 0 : (collectedAmount / members.length).floor();

  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'category': category,
      'style': style.name.toUpperCase(),
      'settlementMode': _settlementToApi(settlementMode),
      'members': members.map((member) => member.toJson()).toList(),
    };
  }

  factory PoolModel.fromJson(Map<String, dynamic> json) {
    final membersJson = (json['members'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return PoolModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toInt() ?? 0,
      adminName: json['adminName'] as String? ?? '',
      style: _styleFromApi(json['style'] as String?),
      settlementMode:
          _settlementFromApi(json['settlementMode'] as String?),
      members: membersJson.map(PoolMember.fromJson).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      category: json['category'] as String? ?? 'Shared Goal',
      payoutEligible: json['payoutEligible'] as bool? ?? false,
      forcePayoutEligible: json['forcePayoutEligible'] as bool? ?? false,
      payoutCompleted: json['payoutCompleted'] as bool? ?? false,
      payoutType: json['payoutType'] as String?,
      payoutAmount: (json['payoutAmount'] as num?)?.toInt(),
      payoutTriggeredBy: json['payoutTriggeredBy'] as String?,
      payoutTriggeredAt:
          DateTime.tryParse(json['payoutTriggeredAt'] as String? ?? ''),
    );
  }
}

class PoolChatMessage {
  const PoolChatMessage({
    required this.id,
    required this.senderName,
    required this.senderPhoneNumber,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String senderName;
  final String senderPhoneNumber;
  final String message;
  final DateTime createdAt;

  factory PoolChatMessage.fromJson(Map<String, dynamic> json) {
    return PoolChatMessage(
      id: (json['id'] ?? '').toString(),
      senderName: json['senderName'] as String? ?? '',
      senderPhoneNumber:
          normalizePhoneNumber(json['senderPhoneNumber'] as String? ?? ''),
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.upiId,
    required this.city,
    required this.createdAt,
    required this.profileCompleted,
  });

  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String upiId;
  final String city;
  final DateTime createdAt;
  final bool profileCompleted;

  String get handle {
    final normalized = name.trim().toLowerCase().replaceAll(' ', '.');
    return normalized.isEmpty ? '@gatherpay.user' : '@$normalized';
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? mobileNumber,
    String? upiId,
    String? city,
    DateTime? createdAt,
    bool? profileCompleted,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      upiId: upiId ?? this.upiId,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'mobileNumber': mobileNumber,
      'city': city,
      'upiId': upiId,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobileNumber: normalizePhoneNumber(json['mobileNumber'] as String? ?? ''),
      upiId: json['upiId'] as String? ?? '',
      city: json['city'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      profileCompleted: json['profileCompleted'] as bool? ?? false,
    );
  }
}

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? '').toString(),
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['read'] as bool? ?? json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.user,
  });

  final String token;
  final UserProfile user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['accessToken'] as String? ?? '',
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

PoolMemberRole _roleFromApi(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'ADMIN':
      return PoolMemberRole.admin;
    default:
      return PoolMemberRole.member;
  }
}

PoolStyle _styleFromApi(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'CASUAL':
      return PoolStyle.casual;
    default:
      return PoolStyle.strict;
  }
}

PoolSettlementMode _settlementFromApi(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'ADMIN_CONTROL':
      return PoolSettlementMode.adminControl;
    case 'GET_BACK':
      return PoolSettlementMode.getBack;
    default:
      return PoolSettlementMode.splitwise;
  }
}

String _settlementToApi(PoolSettlementMode mode) {
  switch (mode) {
    case PoolSettlementMode.adminControl:
      return 'ADMIN_CONTROL';
    case PoolSettlementMode.getBack:
      return 'GET_BACK';
    case PoolSettlementMode.splitwise:
      return 'SPLITWISE';
  }
}

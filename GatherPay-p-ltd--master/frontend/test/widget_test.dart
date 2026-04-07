import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gatherpay/main.dart';
import 'package:gatherpay/models/app_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots into login flow', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const GatherPayApp());
    await tester.pumpAndSettle();

    expect(find.text('GatherPay'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  test('pool getters reflect collected amount and admin role', () {
    final pool = PoolModel(
      id: 'pool-1',
      name: 'Test Pool',
      description: 'Pool description',
      targetAmount: 1000,
      adminName: 'Admin',
      style: PoolStyle.strict,
      settlementMode: PoolSettlementMode.splitwise,
      category: 'Custom',
      createdAt: DateTime(2026, 3, 29),
      members: [
        PoolMember(
          id: 'member-1',
          name: 'Admin',
          phoneNumber: '+91 1',
          contributedAmount: 100,
          approvalsGiven: 1,
          activityScore: 50,
          role: PoolMemberRole.admin,
        ),
        PoolMember(
          id: 'member-2',
          name: 'Member',
          phoneNumber: '+91 2',
          contributedAmount: 50,
          approvalsGiven: 1,
          activityScore: 40,
        ),
      ],
    );

    expect(pool.collectedAmount, 150);
    expect(pool.progress, 0.15);
    expect(pool.adminMember?.name, 'Admin');
    expect(pool.perMemberShare, 500);
  });
}

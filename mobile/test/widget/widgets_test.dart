import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kainatledger/presentation/widgets/empty_state.dart';
import 'package:kainatledger/presentation/widgets/money_text.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('MoneyText renders correct text and format', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoneyText(
              amount: 750000,
              style: MoneyStyle.income,
              showPrefix: true,
            ),
          ),
        ),
      );

      expect(find.text('+Rp 750.000'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget renders title, message, and responds to action button',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.receipt_long,
              title: 'Kosong',
              message: 'Tidak ada data sama sekali.',
              actionLabel: 'Tambah Data',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Kosong'), findsOneWidget);
      expect(find.text('Tidak ada data sama sekali.'), findsOneWidget);
      expect(find.text('Tambah Data'), findsOneWidget);

      await tester.tap(find.text('Tambah Data'));
      expect(actionTriggered, isTrue);
    });
  });
}

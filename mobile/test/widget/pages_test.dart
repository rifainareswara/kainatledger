import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kainatledger/presentation/pages/budget/budget_page.dart';
import 'package:kainatledger/presentation/pages/categories/categories_page.dart';
import 'package:kainatledger/presentation/pages/dashboard/dashboard_page.dart';
import 'package:kainatledger/presentation/pages/goals/goals_page.dart';
import 'package:kainatledger/presentation/pages/profile/profile_page.dart';
import 'package:kainatledger/presentation/pages/reports/reports_page.dart';
import 'package:kainatledger/presentation/pages/transactions/transaction_form_page.dart';
import 'package:kainatledger/presentation/pages/transactions/transactions_page.dart';
import 'package:kainatledger/presentation/pages/wallets/transfer_form_page.dart';
import 'package:kainatledger/presentation/pages/wallets/wallet_form_page.dart';
import 'package:kainatledger/presentation/pages/wallets/wallets_page.dart';

void main() {
  testWidgets('DashboardPage pumps on desktop without crashing or overflowing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('TransactionsPage pumps on desktop without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransactionsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TransactionsPage), findsOneWidget);
  });

  testWidgets('BudgetPage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BudgetPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(BudgetPage), findsOneWidget);
  });

  testWidgets('GoalsPage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GoalsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(GoalsPage), findsOneWidget);
  });

  testWidgets('ProfilePage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfilePage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('WalletsPage pumps on desktop without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WalletsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(WalletsPage), findsOneWidget);
  });

  testWidgets('TransactionFormPage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransactionFormPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TransactionFormPage), findsOneWidget);
  });

  testWidgets('WalletFormPage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WalletFormPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(WalletFormPage), findsOneWidget);
  });

  testWidgets('TransferFormPage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransferFormPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(TransferFormPage), findsOneWidget);
  });

  testWidgets('CategoriesPage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CategoriesPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(CategoriesPage), findsOneWidget);
  });

  testWidgets('ReportsPage pumps without crashing', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ReportsPage(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(ReportsPage), findsOneWidget);
  });
}

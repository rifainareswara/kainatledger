import '../../domain/entities/category_entity.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet_entity.dart';

/// Data dummy fallback untuk pengujian dan pratinjau antarmuka.
class DummyData {
  DummyData._();

  // 1. Wallets
  static final List<WalletEntity> wallets = [
    const WalletEntity(
      id: 'wallet-bca',
      name: 'Rekening BCA',
      type: 'bank',
      balance: 15000000.0,
      currency: 'IDR',
      color: '#2563EB',
      icon: 'account_balance',
      isActive: true,
    ),
    const WalletEntity(
      id: 'wallet-gopay',
      name: 'GoPay',
      type: 'e_wallet',
      balance: 655000.0,
      currency: 'IDR',
      color: '#0D9488',
      icon: 'account_balance_wallet',
      isActive: true,
    ),
    const WalletEntity(
      id: 'wallet-cash',
      name: 'Dompet Tunai',
      type: 'cash',
      balance: 1449000.0,
      currency: 'IDR',
      color: '#16A34A',
      icon: 'payments',
      isActive: true,
    ),
    const WalletEntity(
      id: 'wallet-invest',
      name: 'Bibit Reksadana',
      type: 'investment',
      balance: 8000000.0,
      currency: 'IDR',
      color: '#7C3AED',
      icon: 'trending_up',
      isActive: true,
    ),
  ];

  static WalletSummaryEntity get walletSummary {
    final activeWallets = wallets.where((w) => w.isActive).toList();
    final total = activeWallets.fold(0.0, (acc, w) => acc + w.balance);
    return WalletSummaryEntity(
      totalBalance: total,
      currency: 'IDR',
      walletCount: activeWallets.length,
      wallets: activeWallets,
    );
  }

  // 2. Categories
  static final List<CategoryEntity> categories = [
    const CategoryEntity(
      id: 'cat-makan',
      name: 'Makanan & Minuman',
      type: 'expense',
      icon: 'restaurant',
      color: '#DC2626',
      isDefault: true,
      transactionCount: 8,
    ),
    const CategoryEntity(
      id: 'cat-transport',
      name: 'Transportasi',
      type: 'expense',
      icon: 'directions_car',
      color: '#D97706',
      isDefault: true,
      transactionCount: 4,
    ),
    const CategoryEntity(
      id: 'cat-belanja',
      name: 'Belanja',
      type: 'expense',
      icon: 'shopping_bag',
      color: '#7C3AED',
      isDefault: true,
      transactionCount: 5,
    ),
    const CategoryEntity(
      id: 'cat-tagihan',
      name: 'Tagihan & Utilitas',
      type: 'expense',
      icon: 'receipt_long',
      color: '#2563EB',
      isDefault: true,
      transactionCount: 3,
    ),
    const CategoryEntity(
      id: 'cat-hiburan',
      name: 'Hiburan',
      type: 'expense',
      icon: 'movie',
      color: '#EC4899',
      isDefault: true,
      transactionCount: 2,
    ),
    const CategoryEntity(
      id: 'cat-gaji',
      name: 'Gaji',
      type: 'income',
      icon: 'payments',
      color: '#16A34A',
      isDefault: true,
      transactionCount: 1,
    ),
    const CategoryEntity(
      id: 'cat-bonus',
      name: 'Bonus & Hadiah',
      type: 'income',
      icon: 'card_giftcard',
      color: '#0D9488',
      isDefault: true,
      transactionCount: 2,
    ),
    const CategoryEntity(
      id: 'cat-invest',
      name: 'Investasi',
      type: 'income',
      icon: 'show_chart',
      color: '#2563EB',
      isDefault: true,
      transactionCount: 1,
    ),
  ];

  static List<CategoryEntity> getCategories(String? type) {
    if (type == null) return List.from(categories);
    return categories.where((c) => c.type == type).toList();
  }

  // 3. Transactions
  static final List<TransactionEntity> transactionsList = [
    TransactionEntity(
      id: 'tx-1',
      amount: 15000000.0,
      type: 'income',
      date: DateTime(2026, 11, 1),
      note: 'Gaji Bulanan PT Maju Bersama',
      paymentMethod: 'bank_transfer',
      category: const CategoryBriefEntity(
        id: 'cat-gaji',
        name: 'Gaji',
        icon: 'payments',
        color: '#16A34A',
      ),
      wallet: const WalletBriefEntity(
        id: 'wallet-bca',
        name: 'Rekening BCA',
        type: 'bank',
      ),
      createdAt: DateTime(2026, 11, 1, 9, 0),
    ),
    TransactionEntity(
      id: 'tx-2',
      amount: 45000.0,
      type: 'expense',
      date: DateTime(2026, 11, 23),
      note: 'Kopi & Roti Sarapan',
      paymentMethod: 'qris',
      category: const CategoryBriefEntity(
        id: 'cat-makan',
        name: 'Makanan & Minuman',
        icon: 'restaurant',
        color: '#DC2626',
      ),
      wallet: const WalletBriefEntity(
        id: 'wallet-gopay',
        name: 'GoPay',
        type: 'e_wallet',
      ),
      createdAt: DateTime(2026, 11, 23, 8, 30),
    ),
    TransactionEntity(
      id: 'tx-3',
      amount: 350000.0,
      type: 'expense',
      date: DateTime(2026, 11, 22),
      note: 'Belanja Mingguan Supermarket',
      paymentMethod: 'debit_card',
      category: const CategoryBriefEntity(
        id: 'cat-belanja',
        name: 'Belanja',
        icon: 'shopping_bag',
        color: '#7C3AED',
      ),
      wallet: const WalletBriefEntity(
        id: 'wallet-bca',
        name: 'Rekening BCA',
        type: 'bank',
      ),
      createdAt: DateTime(2026, 11, 22, 16, 15),
    ),
    TransactionEntity(
      id: 'tx-4',
      amount: 450000.0,
      type: 'expense',
      date: DateTime(2026, 11, 20),
      note: 'Tagihan Listrik PLN Bulanan',
      paymentMethod: 'bank_transfer',
      category: const CategoryBriefEntity(
        id: 'cat-tagihan',
        name: 'Tagihan & Utilitas',
        icon: 'receipt_long',
        color: '#2563EB',
      ),
      wallet: const WalletBriefEntity(
        id: 'wallet-bca',
        name: 'Rekening BCA',
        type: 'bank',
      ),
      createdAt: DateTime(2026, 11, 20, 10, 0),
    ),
    TransactionEntity(
      id: 'tx-5',
      amount: 100000.0,
      type: 'expense',
      date: DateTime(2026, 11, 19),
      note: 'Bensin Pertamax Mobil',
      paymentMethod: 'cash',
      category: const CategoryBriefEntity(
        id: 'cat-transport',
        name: 'Transportasi',
        icon: 'directions_car',
        color: '#D97706',
      ),
      wallet: const WalletBriefEntity(
        id: 'wallet-cash',
        name: 'Dompet Tunai',
        type: 'cash',
      ),
      createdAt: DateTime(2026, 11, 19, 14, 20),
    ),
    TransactionEntity(
      id: 'tx-6',
      amount: 2500000.0,
      type: 'income',
      date: DateTime(2026, 11, 15),
      note: 'Bonus Kinerja Project Q3',
      paymentMethod: 'bank_transfer',
      category: const CategoryBriefEntity(
        id: 'cat-bonus',
        name: 'Bonus & Hadiah',
        icon: 'card_giftcard',
        color: '#0D9488',
      ),
      wallet: const WalletBriefEntity(
        id: 'wallet-bca',
        name: 'Rekening BCA',
        type: 'bank',
      ),
      createdAt: DateTime(2026, 11, 15, 11, 0),
    ),
  ];

  static TransactionListEntity get recentTransactions => TransactionListEntity(
    items: transactionsList.take(5).toList(),
    total: transactionsList.length,
    page: 1,
    size: 5,
    pages: 1,
  );

  static TransactionListEntity get paginatedTransactions => TransactionListEntity(
    items: List.from(transactionsList),
    total: transactionsList.length,
    page: 1,
    size: 20,
    pages: 1,
  );

  static void addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required DateTime date,
    String? note,
    String? paymentMethod,
  }) {
    final cat = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => categories.first,
    );
    final wallet = wallets.firstWhere(
      (w) => w.id == walletId,
      orElse: () => wallets.first,
    );

    final isExpense = cat.type == 'expense';

    final wIndex = wallets.indexWhere((w) => w.id == wallet.id);
    if (wIndex != -1) {
      final current = wallets[wIndex];
      final newBalance = isExpense
          ? current.balance - amount
          : current.balance + amount;
      wallets[wIndex] = WalletEntity(
        id: current.id,
        name: current.name,
        type: current.type,
        balance: newBalance,
        currency: current.currency,
        color: current.color,
        icon: current.icon,
        isActive: current.isActive,
      );
    }

    final newTx = TransactionEntity(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: cat.type,
      date: date,
      note: note,
      paymentMethod: paymentMethod,
      category: CategoryBriefEntity(
        id: cat.id,
        name: cat.name,
        icon: cat.icon,
        color: cat.color,
      ),
      wallet: WalletBriefEntity(
        id: wallet.id,
        name: wallet.name,
        type: wallet.type,
      ),
      createdAt: DateTime.now(),
    );

    transactionsList.insert(0, newTx);
  }

  static void deleteTransaction(String id) {
    transactionsList.removeWhere((t) => t.id == id);
  }

  static void addWallet({
    required String name,
    required String type,
    required double initialBalance,
    String color = '#2563EB',
    String icon = 'account_balance_wallet',
  }) {
    final w = WalletEntity(
      id: 'wallet-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      balance: initialBalance,
      currency: 'IDR',
      color: color,
      icon: icon,
      isActive: true,
    );
    wallets.add(w);
  }

  static void performTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    String? note,
  }) {
    final fromIdx = wallets.indexWhere((w) => w.id == fromWalletId);
    final toIdx = wallets.indexWhere((w) => w.id == toWalletId);

    if (fromIdx != -1) {
      final w = wallets[fromIdx];
      wallets[fromIdx] = WalletEntity(
        id: w.id,
        name: w.name,
        type: w.type,
        balance: w.balance - (amount + fee),
        currency: w.currency,
        color: w.color,
        icon: w.icon,
        isActive: w.isActive,
      );
    }

    if (toIdx != -1) {
      final w = wallets[toIdx];
      wallets[toIdx] = WalletEntity(
        id: w.id,
        name: w.name,
        type: w.type,
        balance: w.balance + amount,
        currency: w.currency,
        color: w.color,
        icon: w.icon,
        isActive: w.isActive,
      );
    }
  }

  static void addCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) {
    final cat = CategoryEntity(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      icon: icon,
      color: color,
      isDefault: false,
      transactionCount: 0,
    );
    categories.add(cat);
  }

  static void deleteCategory(String id) {
    categories.removeWhere((c) => c.id == id);
  }

  // 4. Reports
  static const ReportSummaryEntity reportSummary = ReportSummaryEntity(
    year: 2026,
    month: 11,
    totalBalance: 25104000.0,
    income: 17500000.0,
    expense: 945000.0,
    net: 16555000.0,
  );

  static final List<MonthlyDataEntity> monthlyData = [
    const MonthlyDataEntity(month: 1, monthName: 'Jan', income: 15000000.0, expense: 4200000.0),
    const MonthlyDataEntity(month: 2, monthName: 'Feb', income: 15000000.0, expense: 3800000.0),
    const MonthlyDataEntity(month: 3, monthName: 'Mar', income: 16500000.0, expense: 5100000.0),
    const MonthlyDataEntity(month: 4, monthName: 'Apr', income: 15000000.0, expense: 4000000.0),
    const MonthlyDataEntity(month: 5, monthName: 'Mei', income: 18000000.0, expense: 4900000.0),
    const MonthlyDataEntity(month: 6, monthName: 'Jun', income: 15000000.0, expense: 4500000.0),
    const MonthlyDataEntity(month: 7, monthName: 'Jul', income: 15000000.0, expense: 3900000.0),
    const MonthlyDataEntity(month: 8, monthName: 'Agu', income: 15000000.0, expense: 4100000.0),
    const MonthlyDataEntity(month: 9, monthName: 'Sep', income: 15000000.0, expense: 4300000.0),
    const MonthlyDataEntity(month: 10, monthName: 'Okt', income: 15000000.0, expense: 4600000.0),
    const MonthlyDataEntity(month: 11, monthName: 'Nov', income: 17500000.0, expense: 945000.0),
    const MonthlyDataEntity(month: 12, monthName: 'Des', income: 0.0, expense: 0.0),
  ];

  static List<CategoryBreakdownEntity> getCategoryBreakdown(String type) {
    if (type == 'income') {
      return [
        const CategoryBreakdownEntity(
          categoryId: 'cat-gaji',
          categoryName: 'Gaji',
          icon: 'payments',
          color: '#16A34A',
          amount: 15000000.0,
          percentage: 85.7,
          transactionCount: 1,
        ),
        const CategoryBreakdownEntity(
          categoryId: 'cat-bonus',
          categoryName: 'Bonus & Hadiah',
          icon: 'card_giftcard',
          color: '#0D9488',
          amount: 2500000.0,
          percentage: 14.3,
          transactionCount: 1,
        ),
      ];
    }
    return [
      const CategoryBreakdownEntity(
        categoryId: 'cat-tagihan',
        categoryName: 'Tagihan & Utilitas',
        icon: 'receipt_long',
        color: '#2563EB',
        amount: 450000.0,
        percentage: 47.6,
        transactionCount: 1,
      ),
      const CategoryBreakdownEntity(
        categoryId: 'cat-belanja',
        categoryName: 'Belanja',
        icon: 'shopping_bag',
        color: '#7C3AED',
        amount: 350000.0,
        percentage: 37.0,
        transactionCount: 1,
      ),
      const CategoryBreakdownEntity(
        categoryId: 'cat-transport',
        categoryName: 'Transportasi',
        icon: 'directions_car',
        color: '#D97706',
        amount: 100000.0,
        percentage: 10.6,
        transactionCount: 1,
      ),
      const CategoryBreakdownEntity(
        categoryId: 'cat-makan',
        categoryName: 'Makanan & Minuman',
        icon: 'restaurant',
        color: '#DC2626',
        amount: 45000.0,
        percentage: 4.8,
        transactionCount: 1,
      ),
    ];
  }

  // 5. Goals (Target Keuangan)
  static final List<GoalItem> goals = [
    const GoalItem(
      id: 'g-1',
      title: 'Mobil Baru',
      targetAmount: 80000000.0,
      currentAmount: 42500000.0,
      icon: 'directions_car',
      color: '#4F46E5',
    ),
    const GoalItem(
      id: 'g-2',
      title: 'Liburan Akhir Tahun',
      targetAmount: 25000000.0,
      currentAmount: 17500000.0,
      icon: 'beach_access',
      color: '#0D9488',
    ),
    const GoalItem(
      id: 'g-3',
      title: 'Dana Darurat 6 Bulan',
      targetAmount: 100000000.0,
      currentAmount: 62000000.0,
      icon: 'security',
      color: '#2563EB',
    ),
  ];

  static void addGoal({
    required String title,
    required double targetAmount,
    required double currentAmount,
    String icon = 'star',
    String color = '#4F46E5',
  }) {
    goals.add(
      GoalItem(
        id: 'g-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        icon: icon,
        color: color,
      ),
    );
  }

  // 6. Budgets (Anggaran Bulanan)
  static double get totalBudget => 15000000.0;
  static double get spentBudget => 4200000.0;

  static final List<CategoryBudgetItem> budgets = [
    const CategoryBudgetItem(
      id: 'b-1',
      categoryName: 'Tempat Tinggal & Utilitas',
      allocatedAmount: 4500000.0,
      spentAmount: 3150000.0,
      icon: 'home',
      color: '#4F46E5',
    ),
    const CategoryBudgetItem(
      id: 'b-2',
      categoryName: 'Makanan & Kuliner',
      allocatedAmount: 3500000.0,
      spentAmount: 1850000.0,
      icon: 'restaurant',
      color: '#DC2626',
    ),
    const CategoryBudgetItem(
      id: 'b-3',
      categoryName: 'Transportasi',
      allocatedAmount: 1500000.0,
      spentAmount: 850000.0,
      icon: 'directions_car',
      color: '#D97706',
    ),
    const CategoryBudgetItem(
      id: 'b-4',
      categoryName: 'Belanja & Hiburan',
      allocatedAmount: 2500000.0,
      spentAmount: 2400000.0,
      icon: 'shopping_bag',
      color: '#7C3AED',
    ),
  ];
}

class GoalItem {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String icon;
  final String color;

  const GoalItem({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.icon,
    required this.color,
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  int get percentage => (progress * 100).toInt();
}

class CategoryBudgetItem {
  final String id;
  final String categoryName;
  final double allocatedAmount;
  final double spentAmount;
  final String icon;
  final String color;

  const CategoryBudgetItem({
    required this.id,
    required this.categoryName,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.icon,
    required this.color,
  });

  double get progress => (spentAmount / allocatedAmount).clamp(0.0, 1.0);
  int get percentage => (progress * 100).toInt();
}

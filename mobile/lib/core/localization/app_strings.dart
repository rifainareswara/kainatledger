enum AppLanguage { id, en }

class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  bool get isId => language == AppLanguage.id;

  // Navigation
  String get navHome => isId ? 'Beranda' : 'Home';
  String get navTransactions => isId ? 'Transaksi' : 'Transactions';
  String get navBudgets => isId ? 'Anggaran' : 'Budgets';
  String get navGoals => isId ? 'Target' : 'Goals';
  String get navProfile => isId ? 'Profil' : 'Profile';
  String get navReports => isId ? 'Laporan' : 'Reports';
  String get navWallets => isId ? 'Dompet' : 'Wallets';
  String get navCategories => isId ? 'Kategori' : 'Categories';

  // Dashboard
  String get greetingHi => isId ? 'Hi' : 'Hi';
  String get greetingTime => isId ? 'Selamat Pagi!' : 'Good morning!';
  String get totalBalance => isId ? 'Total Saldo' : 'Total Balance';
  String get vsLastMonth => isId ? '+12.5% vs bulan lalu' : '+12.5% vs last month';
  String get send => isId ? 'Kirim' : 'Send';
  String get receive => isId ? 'Terima' : 'Receive';
  String get more => isId ? 'Lainnya' : 'More';
  String get quickOverview => isId ? 'Ringkasan Cepat' : 'Quick Overview';
  String get thisMonth => isId ? 'Bulan Ini' : 'This Month';
  String get income => isId ? 'Pemasukan' : 'Income';
  String get expenses => isId ? 'Pengeluaran' : 'Expenses';
  String get savings => isId ? 'Tabungan' : 'Savings';
  String get investments => isId ? 'Investasi' : 'Investments';
  String get recentTransactions => isId ? 'Transaksi Terakhir' : 'Recent Transactions';
  String get viewAll => isId ? 'Lihat Semua' : 'View All';
  String get noTransactions => isId ? 'Belum Ada Transaksi' : 'No Transactions';
  String get noTransactionsDesc => isId ? 'Catat transaksi pertama Anda.' : 'Record your first transaction.';
  String get addTransaction => isId ? 'Tambah Transaksi' : 'Add Transaction';

  // Goals
  String get goalsTitle => isId ? 'Target Keuangan' : 'Financial Goals';
  String get myGoals => isId ? 'Target Saya' : 'My Goals';
  String get addGoal => isId ? '+ Tambah Target' : '+ Add Goal';
  String get targetOf => isId ? 'Target' : 'Target';
  String get remaining => isId ? 'Sisa' : 'Remaining';
  String get addGoalModalTitle => isId ? 'Tambah Target Tabungan' : 'Add Savings Goal';
  String get goalName => isId ? 'Nama Target' : 'Goal Name';
  String get goalNameHint => isId ? 'Contoh: Mobil Baru, Liburan Bali' : 'e.g. New Car, Vacation';
  String get targetAmount => isId ? 'Nominal Target (Rp)' : 'Target Amount (Rp)';
  String get currentAmount => isId ? 'Terkumpul Saat Ini (Rp)' : 'Current Amount (Rp)';
  String get selectGoalIcon => isId ? 'Pilih Ikon Target' : 'Select Goal Icon';
  String get saveGoal => isId ? 'Simpan Target' : 'Save Goal';

  // Budget
  String get budgetTitle => isId ? 'Anggaran' : 'Budget';
  String get overviewTab => isId ? 'Ringkasan' : 'Overview';
  String get categoryTab => isId ? 'Kategori' : 'Categories';
  String get monthlyBudget => isId ? 'Anggaran Bulanan' : 'Monthly Budget';
  String get spent => isId ? 'Terpakai' : 'Spent';
  String get left => isId ? 'Sisa' : 'Left';
  String get budgetByCategory => isId ? 'Anggaran per Kategori' : 'Budget by Category';
  String get adjust => isId ? 'Sesuaikan' : 'Adjust';
  String get limit => isId ? 'Batas' : 'Limit';
  String get viewHistory => isId ? 'Lihat Riwayat Transaksi' : 'View Transaction History';

  // Transactions Feed
  String get searchTransactions => isId ? 'Cari catatan transaksi...' : 'Search transactions...';
  String get all => isId ? 'Semua' : 'All';
  String get newTransaction => isId ? 'Transaksi Baru' : 'New Transaction';

  // Spending Overview (Reports)
  String get spendingOverview => isId ? 'Ringkasan Pengeluaran' : 'Spending Overview';
  String get totalExpenses => isId ? 'Total Pengeluaran' : 'Total Expenses';
  String get totalIncome => isId ? 'Total Pemasukan' : 'Total Income';
  String get total => isId ? 'Total' : 'Total';
  String get exportCsv => isId ? 'Ekspor CSV' : 'Export CSV';
  String get exportExcel => isId ? 'Ekspor Excel' : 'Export Excel';

  // Profile
  String get profileTitle => isId ? 'Profil Saya' : 'My Profile';
  String get memberBadge => isId ? 'KainatLedger Member' : 'KainatLedger Member';
  String get activeWallets => isId ? 'Dompet Aktif' : 'Active Wallets';
  String get currency => isId ? 'Mata Uang' : 'Currency';
  String get editUsername => isId ? 'Ubah Nama Pengguna' : 'Change Display Name';
  String get languageSetting => isId ? 'Bahasa / Language' : 'Language / Bahasa';
  String get currentLanguageName => isId ? 'Bahasa Indonesia' : 'English';
  String get manageWallets => isId ? 'Kelola Dompet & Rekening' : 'Manage Wallets & Accounts';
  String get manageCategories => isId ? 'Kategori Transaksi' : 'Transaction Categories';
  String get accountSecurity => isId ? 'Keamanan Akun' : 'Account Security';
  String get changePassword => isId ? 'Ubah Kata Sandi' : 'Change Password';
  String get securityPin => isId ? 'PIN Keamanan' : 'Security PIN';
  String get currentPassword => isId ? 'Kata Sandi Saat Ini' : 'Current Password';
  String get newPassword => isId ? 'Kata Sandi Baru' : 'New Password';
  String get confirmNewPassword => isId ? 'Konfirmasi Kata Sandi Baru' : 'Confirm New Password';
  String get enterPin => isId ? 'Masukkan PIN (6 Digit)' : 'Enter PIN (6 Digits)';
  String get confirmPin => isId ? 'Konfirmasi PIN (6 Digit)' : 'Confirm PIN (6 Digits)';
  String get logoutButton => isId ? 'Keluar / Ganti Akun Login' : 'Log Out / Switch Account';
  String get logoutConfirmTitle => isId ? 'Konfirmasi Keluar' : 'Confirm Logout';
  String get logoutConfirmMessage => isId ? 'Apakah Anda ingin keluar dan kembali ke halaman login?' : 'Are you sure you want to log out and return to login?';
  String get cancel => isId ? 'Batal' : 'Cancel';
  String get save => isId ? 'Simpan' : 'Save';

  // Bill Reminders / Pengingat Pembayaran
  String get billReminders => isId ? 'Pengingat Pembayaran' : 'Payment Reminders';
  String get billRemindersDesc => isId ? 'Notifikasi otomatis saat jatuh tempo & H-1' : 'Automatic notifications on due date & 1 day before';
  String get dueTodayAlert => isId ? 'Jatuh Tempo Hari Ini!' : 'Due Today!';
  String get dueTomorrowAlert => isId ? 'Jatuh Tempo Besok (H-1)' : 'Due Tomorrow (1 Day Before)';
  String get markPaid => isId ? 'Tandai Lunas' : 'Mark as Paid';
  String get paid => isId ? 'Lunas' : 'Paid';
  String get unpaid => isId ? 'Belum Dibayar' : 'Unpaid';
  String get addBillReminder => isId ? 'Tambah Pengingat Tagihan' : 'Add Bill Reminder';
  String get billTitleLabel => isId ? 'Nama Tagihan / Pembayaran' : 'Bill / Payment Name';
  String get billTitleHint => isId ? 'Contoh: Listrik PLN, WiFi, BPJS' : 'e.g. Electric PLN, WiFi, BPJS';
  String get billAmountLabel => isId ? 'Nominal Tagihan (Rp)' : 'Bill Amount (Rp)';
  String get billDueDateLabel => isId ? 'Tanggal Jatuh Tempo' : 'Due Date';
  String get billCategoryLabel => isId ? 'Kategori Tagihan' : 'Bill Category';
  String get noUpcomingBills => isId ? 'Tidak ada tagihan mendesak saat ini' : 'No urgent bills at the moment';
  String get enableNotifications => isId ? 'Aktifkan Notifikasi Perangkat' : 'Enable Device Notifications';
  String get notificationsActive => isId ? 'Notifikasi Perangkat Aktif' : 'Device Notifications Active';
}

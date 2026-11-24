class BillReminder {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String category;
  final bool isPaid;
  final int reminderDaysBefore; // default 1 = alert on H-1 (sehari sebelumnya) and H-0 (jatuh tempo)
  final String? notes;
  final DateTime? paidAt;

  const BillReminder({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.category = 'Tagihan',
    this.isPaid = false,
    this.reminderDaysBefore = 1,
    this.notes,
    this.paidAt,
  });

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  bool get isOverdue {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.isBefore(todayMidnight) && !isPaid;
  }

  int get daysUntilDue {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final dueMidnight = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueMidnight.difference(todayMidnight).inDays;
  }

  bool get shouldNotifyDevice {
    if (isPaid) return false;
    return isDueToday || isDueTomorrow || isOverdue;
  }

  String getStatusLabel({required bool isId}) {
    if (isPaid) {
      return isId ? 'Lunas' : 'Paid';
    }
    if (isDueToday) {
      return isId ? 'Jatuh Tempo Hari Ini!' : 'Due Today!';
    }
    if (isDueTomorrow) {
      return isId ? 'Jatuh Tempo Besok (H-1)' : 'Due Tomorrow';
    }
    if (isOverdue) {
      final days = -daysUntilDue;
      return isId ? 'Terlambat $days hari' : '$days days overdue';
    }
    return isId ? '$daysUntilDue hari lagi' : 'In $daysUntilDue days';
  }

  BillReminder copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    String? category,
    bool? isPaid,
    int? reminderDaysBefore,
    String? notes,
    DateTime? paidAt,
  }) {
    return BillReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isPaid: isPaid ?? this.isPaid,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      notes: notes ?? this.notes,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'category': category,
    'isPaid': isPaid,
    'reminderDaysBefore': reminderDaysBefore,
    'notes': notes,
    'paidAt': paidAt?.toIso8601String(),
  };

  factory BillReminder.fromJson(Map<String, dynamic> json) => BillReminder(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    dueDate: DateTime.parse(json['dueDate'] as String),
    category: json['category'] as String? ?? 'Tagihan',
    isPaid: json['isPaid'] as bool? ?? false,
    reminderDaysBefore: json['reminderDaysBefore'] as int? ?? 1,
    notes: json['notes'] as String?,
    paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
  );
}

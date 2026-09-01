part of 'total_balance_bloc.dart';

class TotalBalanceState extends Equatable {
  final BalanceStatus balanceStatus;
  final double total; // Overall Remaining Balance = AllTimeIncome - AllTimeExpense + Loan
  final double incomeTotal; // Filtered Income for active period
  final double expenseTotal; // Filtered Expense for active period
  final double loanTotal; // Overall Unpaid Loan
  final double allTimeIncome;
  final double allTimeExpense;
  final DateFilterType dateFilterType;
  final DateTimeRange? customRange;
  final List<IncomeModel> allIncomes;
  final List<ExpenseModel> allExpenses;

  const TotalBalanceState({
    this.balanceStatus = BalanceStatus.loading,
    this.total = 0,
    this.incomeTotal = 0,
    this.expenseTotal = 0,
    this.loanTotal = 0,
    this.allTimeIncome = 0,
    this.allTimeExpense = 0,
    this.dateFilterType = DateFilterType.thisMonth,
    this.customRange,
    this.allIncomes = const [],
    this.allExpenses = const [],
  });

  String get filterLabel {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    switch (dateFilterType) {
      case DateFilterType.thisMonth:
        return '${months[now.month - 1]} ${now.year}';
      case DateFilterType.customRange:
        if (customRange == null) return 'Custom';
        final s = customRange!.start;
        final e = customRange!.end;
        return '${s.day}/${s.month} - ${e.day}/${e.month}';
      case DateFilterType.allTime:
        return 'Overall';
    }
  }

  TotalBalanceState copyWith({
    BalanceStatus? balanceStatus,
    double? total,
    double? incomeTotal,
    double? expenseTotal,
    double? loanTotal,
    double? allTimeIncome,
    double? allTimeExpense,
    DateFilterType? dateFilterType,
    DateTimeRange? customRange,
    List<IncomeModel>? allIncomes,
    List<ExpenseModel>? allExpenses,
  }) {
    return TotalBalanceState(
      balanceStatus: balanceStatus ?? this.balanceStatus,
      total: total ?? this.total,
      incomeTotal: incomeTotal ?? this.incomeTotal,
      expenseTotal: expenseTotal ?? this.expenseTotal,
      loanTotal: loanTotal ?? this.loanTotal,
      allTimeIncome: allTimeIncome ?? this.allTimeIncome,
      allTimeExpense: allTimeExpense ?? this.allTimeExpense,
      dateFilterType: dateFilterType ?? this.dateFilterType,
      customRange: customRange ?? this.customRange,
      allIncomes: allIncomes ?? this.allIncomes,
      allExpenses: allExpenses ?? this.allExpenses,
    );
  }

  @override
  List<Object?> get props => [
        balanceStatus,
        total,
        incomeTotal,
        expenseTotal,
        loanTotal,
        allTimeIncome,
        allTimeExpense,
        dateFilterType,
        customRange,
        allIncomes,
        allExpenses,
      ];
}
part of 'total_balance_bloc.dart';

class TotalBalanceState extends Equatable {

  final BalanceStatus balanceStatus;
  double total;
  double incomeTotal;
  double expenseTotal;
  double loanTotal;

  TotalBalanceState({
    this.balanceStatus = BalanceStatus.loading,
    this.total = 0,
    this.incomeTotal = 0,
    this.expenseTotal = 0,
    this.loanTotal = 0
  });

  TotalBalanceState copyWith({BalanceStatus? balanceStatus, double? total, double? incomeTotal, double? expenseTotal, double? loanTotal}) {
    return TotalBalanceState(
      total: total ?? this.total,
      incomeTotal: incomeTotal ?? this.incomeTotal,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      expenseTotal: expenseTotal ?? this.expenseTotal,
      loanTotal: loanTotal ?? this.loanTotal,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [total, incomeTotal, balanceStatus, expenseTotal, loanTotal];

}
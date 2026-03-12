import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/repository/expense_repository/expense_repository.dart';
import 'package:spend_wise/repository/income_repository/income_repository.dart';
import 'package:spend_wise/repository/loan_repository/lone_repository.dart';

import '../../../config/enum/enum.dart';

part 'total_balance_event.dart';
part 'total_balance_state.dart';

class TotalBalanceBloc extends Bloc<TotalAmountEvent, TotalBalanceState> {

  final ExpenseRepository expenseRepository = ExpenseRepository();
  final IncomeRepository incomeRepository = IncomeRepository();
  final LoanRepository loanRepository = LoanRepository();

  TotalBalanceBloc() : super(TotalBalanceState()) {
    on<CalculateTotalAmount>(_calculateTotalAmount);

    add(CalculateTotalAmount());
  }

  Future<void> _calculateTotalAmount(CalculateTotalAmount event,
      Emitter<TotalBalanceState> emit) async {
    emit(state.copyWith(balanceStatus: BalanceStatus.loading));

    double income = 0;
    double expense = 0;
    double loan = 0;

    final incomeStream = incomeRepository.getTotalIncome();
    final expenseStream = expenseRepository.getTotalExpense();
    final loanStream = loanRepository.getTotalLoan();

    void recalculate() {
      emit(state.copyWith(
        balanceStatus: BalanceStatus.success,
        total: income - expense - loan,
        incomeTotal: income,
        expenseTotal: expense,
        loanTotal: loan,
      ));
    }

    await Future.wait([
      emit.forEach<double>(
        incomeStream,
        onData: (value) {
          income = value;
          recalculate();
          return state;
        },
      ),
      emit.forEach<double>(
        expenseStream,
        onData: (value) {
          expense = value;
          recalculate();
          return state;
        },
      ),
      emit.forEach<double>(
        loanStream,
        onData: (value) {
          loan = value;
          recalculate();
          return state;
        },
      ),
    ]);
  }
}
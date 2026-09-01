import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/model/expense/expense_model.dart';
import 'package:spend_wise/model/income/income_model.dart';
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

  TotalBalanceBloc() : super(const TotalBalanceState()) {
    on<CalculateTotalAmount>(_calculateTotalAmount);
    on<ChangeDateFilter>(_changeDateFilter);

    add(CalculateTotalAmount());
  }

  static bool _isWithinFilter(
    DateTime? date,
    DateFilterType filterType,
    DateTimeRange? customRange,
  ) {
    if (date == null) return false;
    final now = DateTime.now();

    switch (filterType) {
      case DateFilterType.thisMonth:
        return date.year == now.year && date.month == now.month;

      case DateFilterType.customRange:
        if (customRange == null) return true;
        final start = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
        );
        final end = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
          23,
          59,
          59,
          999,
        );
        return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
            (date.isBefore(end) || date.isAtSameMomentAs(end));

      case DateFilterType.allTime:
        return true;
    }
  }

  TotalBalanceState _recalculate({
    required List<IncomeModel> incomes,
    required List<ExpenseModel> expenses,
    required double loan,
    required DateFilterType filterType,
    DateTimeRange? customRange,
  }) {
    double allIncome = 0;
    for (final inc in incomes) {
      allIncome += inc.amount;
    }

    double allExpense = 0;
    for (final exp in expenses) {
      allExpense += exp.amount;
    }

    double filteredIncome = 0;
    for (final inc in incomes) {
      if (_isWithinFilter(inc.date_time, filterType, customRange)) {
        filteredIncome += inc.amount;
      }
    }

    double filteredExpense = 0;
    for (final exp in expenses) {
      if (_isWithinFilter(exp.date_time, filterType, customRange)) {
        filteredExpense += exp.amount;
      }
    }

    return state.copyWith(
      balanceStatus: BalanceStatus.success,
      total: allIncome - allExpense + loan, // Strictly all-time overall balance
      loanTotal: loan, // Overall unpaid loan
      allTimeIncome: allIncome,
      allTimeExpense: allExpense,
      incomeTotal: filteredIncome,
      expenseTotal: filteredExpense,
      allIncomes: incomes,
      allExpenses: expenses,
      dateFilterType: filterType,
      customRange: customRange,
    );
  }

  void _changeDateFilter(
    ChangeDateFilter event,
    Emitter<TotalBalanceState> emit,
  ) {
    emit(
      _recalculate(
        incomes: state.allIncomes,
        expenses: state.allExpenses,
        loan: state.loanTotal,
        filterType: event.filterType,
        customRange: event.customRange,
      ),
    );
  }

  Future<void> _calculateTotalAmount(
    CalculateTotalAmount event,
    Emitter<TotalBalanceState> emit,
  ) async {
    emit(state.copyWith(balanceStatus: BalanceStatus.loading));

    List<IncomeModel> currentIncomes = [];
    List<ExpenseModel> currentExpenses = [];
    double currentLoan = 0;

    final incomeStream = incomeRepository.getIncomeListStream();
    final expenseStream = expenseRepository.getExpenseListStream();
    final loanStream = loanRepository.getTotalLoan();

    await Future.wait([
      emit.forEach<List<IncomeModel>>(
        incomeStream,
        onData: (incomes) {
          currentIncomes = incomes;
          return _recalculate(
            incomes: currentIncomes,
            expenses: currentExpenses,
            loan: currentLoan,
            filterType: state.dateFilterType,
            customRange: state.customRange,
          );
        },
      ),
      emit.forEach<List<ExpenseModel>>(
        expenseStream,
        onData: (expenses) {
          currentExpenses = expenses;
          return _recalculate(
            incomes: currentIncomes,
            expenses: currentExpenses,
            loan: currentLoan,
            filterType: state.dateFilterType,
            customRange: state.customRange,
          );
        },
      ),
      emit.forEach<double>(
        loanStream,
        onData: (loan) {
          currentLoan = loan;
          return _recalculate(
            incomes: currentIncomes,
            expenses: currentExpenses,
            loan: currentLoan,
            filterType: state.dateFilterType,
            customRange: state.customRange,
          );
        },
      ),
    ]);
  }
}
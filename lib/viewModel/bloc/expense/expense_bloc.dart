import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/model/expense/expense_model.dart';
import 'package:spend_wise/view/views.dart';

import '../../../model/expense/expense_model.dart';
import '../../../repository/expense_repository/expense_repository.dart';
import '../../../repository/expense_repository/expense_repository.dart';

part 'expense_state.dart';
part 'expense_event.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {

  ExpenseRepository expenseRepository = ExpenseRepository();

  List<ExpenseModel> filteredExpenseModel = [];



  ExpenseBloc() : super(ExpenseState()) {
    on<GetExpense>(_getExpense);
    on<SearchItem>(_filterList);
    on<AddExpense>(_addExpense);
    on<DeleteExpense>(_deleteExpense);
    on<FilterByDate>(_filterByDate);
  }

  void _getExpense(GetExpense event, Emitter<ExpenseState> emit) async {
    await expenseRepository.fetchExpense().then((value) {
      emit(
        state.copyWith(
            newExpenseStatus: ExpenseStatus.success,
            newExpenseModel: value,
            newMessage: 'Successful'
        )
      );
    }).onError((error, stackTrace) {
      emit(
        state.copyWith(
            newExpenseStatus: ExpenseStatus.failure,
            newMessage: error.toString()
        )
      );
    });
  }

  Future<void> _filterList (SearchItem event, Emitter<ExpenseState> emit) async {

    if(event.searchKey.isEmpty) {
      emit(state.copyWith(newFilteredExpenseModel: [], newSearchMessage: ''));
    }

    else if(event.searchKey.isNotEmpty) {
      filteredExpenseModel = state.expenseModel.where(


        //Contains tells that if email contains any word of SearchKey
              (element) => element.type.name.toLowerCase().toString().contains(event.searchKey.toLowerCase().toString()))
          .toList();
      if(filteredExpenseModel.isEmpty) {   //If the search doesn't match
        emit(state.copyWith(newFilteredExpenseModel: [], newSearchMessage: 'No data found'));
      }
      else {
        emit(state.copyWith(newFilteredExpenseModel: filteredExpenseModel, newSearchMessage: ''));
      }
    }
  }

  void _addExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    expenseRepository.addExpense(event.expense);
     add(GetExpense());

  }

  void _deleteExpense (DeleteExpense event, Emitter<ExpenseState> emit) async {

    final updatedList = state.expenseModel.where((item) => item.id != event.id).toList();
    emit(state.copyWith(newExpenseModel: updatedList, newFilteredExpenseModel: []));

    expenseRepository.deleteExpense(event.id);
    emit(state.copyWith(newExpenseStatus: ExpenseStatus.success, newMessage: 'Deleted successfully!'));
  }

  void _filterByDate (FilterByDate event, Emitter<ExpenseState> emit) {
    final now = DateTime.now();

    DateTime? from;
    switch (event.filter) {
      case DateFilter.sevenDays:
        from = now.subtract(const Duration(days: 7));
        break;
      case DateFilter.oneMonth:
        from = DateTime(now.year, now.month - 1, now.day);
        break;
      case DateFilter.threeMonths:
        from = DateTime(now.year, now.month - 3, now.day);
        break;
      case DateFilter.oneYear:
        from = DateTime(now.year - 1, now.month, now.day);
        break;
      case DateFilter.all:
        from = null;
        break;
    }

    final filtered = from == null
        ? <ExpenseModel>[]
        : state.expenseModel
        .where((item) => item.date_time != null && item.date_time!.isAfter(from!))
        .toList();

    emit(state.copyWith(
      newFilteredExpenseModel: filtered,
      newFilter: event.filter,
      newSearchMessage: filtered.isEmpty && from != null ? 'No data found for this period' : '',
    ));
  }

}
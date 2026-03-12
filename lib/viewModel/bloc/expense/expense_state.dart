part of 'expense_bloc.dart';


class ExpenseState extends Equatable{

  final ExpenseStatus expenseStatus;
  final List<ExpenseModel> expenseModel;
  final List<ExpenseModel> filteredExpenseModel;
  final DateFilter selectedFilter;

  final String message;
  final String searchMessage;

  const ExpenseState ({
    this.expenseStatus = ExpenseStatus.loading,
    this.expenseModel = const <ExpenseModel>[],
    this.filteredExpenseModel = const <ExpenseModel>[],
    this.selectedFilter = DateFilter.all,
    this.message = '',
    this.searchMessage = ''
  });

  ExpenseState copyWith({ExpenseStatus? newExpenseStatus, List<ExpenseModel>? newExpenseModel, List<ExpenseModel>? newFilteredExpenseModel,DateFilter? newFilter, String? newMessage, String? newSearchMessage}) {
    return ExpenseState(
      expenseStatus: newExpenseStatus ?? this.expenseStatus,
      expenseModel: newExpenseModel ?? this.expenseModel,
      filteredExpenseModel: newFilteredExpenseModel ?? this.filteredExpenseModel,
      selectedFilter: newFilter ?? this.selectedFilter,
      message: newMessage ?? this.message,
      searchMessage: newSearchMessage ?? this.searchMessage,
    );
  }

  @override
  List<Object> get props => [expenseStatus, expenseModel, filteredExpenseModel, selectedFilter, message, searchMessage];

}
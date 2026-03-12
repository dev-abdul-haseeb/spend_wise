part of 'expense_bloc.dart';

class ExpenseEvent extends Equatable {

  ExpenseEvent();

  @override
  List<Object?> get props => [];

}

class GetExpense extends ExpenseEvent {}

class SearchItem extends ExpenseEvent {
  String searchKey;
  SearchItem(this.searchKey);

  @override
  List<Object?> get props => [searchKey];

}
class AddExpense extends ExpenseEvent {
  ExpenseModel expense;
  AddExpense({required this.expense});

  @override
  List<Object?> get props => [expense];

}

class DeleteExpense extends ExpenseEvent {
  String id;
  DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterByDate extends ExpenseEvent {
  final DateFilter filter;
  FilterByDate(this.filter);
  @override
  List<Object?> get props => [DateFilter];
}

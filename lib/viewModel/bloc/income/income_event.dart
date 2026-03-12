part of 'income_bloc.dart';

class IncomeEvent extends Equatable {

  IncomeEvent();

  @override
  List<Object?> get props => [];

}

class GetIncome extends IncomeEvent {}

class SearchItem extends IncomeEvent {
  String searchKey;
  SearchItem(this.searchKey);

  @override
  List<Object?> get props => [searchKey];

}
class AddIncome extends IncomeEvent {
  IncomeModel income;
  AddIncome({required this.income});

  @override
  List<Object?> get props => [income];

}

class DeleteIncome extends IncomeEvent {
  String id;
  DeleteIncome(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterByDate extends IncomeEvent {
  final DateFilter filter;
  FilterByDate(this.filter);
  @override
  List<Object?> get props => [DateFilter];
}

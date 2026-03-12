part of 'loan_bloc.dart';

class LoanEvent extends Equatable {

  LoanEvent();

  @override
  List<Object?> get props => [];

}

class GetLoan extends LoanEvent {}

class SearchItem extends LoanEvent {
  String searchKey;
  SearchItem(this.searchKey);

  @override
  List<Object?> get props => [searchKey];
}

class FilterbyStatus extends LoanEvent {
  LoanStatusFilter searchkey;
  FilterbyStatus(this.searchkey);

  @override
  // TODO: implement props
  List<Object?> get props => [searchkey];
}
class AddLoan extends LoanEvent {
  LoanModel loan;
  AddLoan({required this.loan});

  @override
  List<Object?> get props => [loan];

}

class PayLoan extends LoanEvent {
  String id;
  PayLoan(this.id);

  @override
  List<Object?> get props => [id];
}


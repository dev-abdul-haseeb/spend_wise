part of 'loan_bloc.dart';


class LoanState extends Equatable{

  final LoanStatus loanStatus;
  final List<LoanModel> loanModel;
  final List<LoanModel> filteredLoanModel;

  final LoanStatusFilter selectedFilter;

  final String message;
  final String searchMessage;

  const LoanState ({
    this.loanStatus = LoanStatus.loading,
    this.loanModel = const <LoanModel>[],
    this.filteredLoanModel = const <LoanModel>[],
    this.selectedFilter = LoanStatusFilter.all,
    this.message = '',
    this.searchMessage = ''
  });

  LoanState copyWith({LoanStatus? newLoanStatus, List<LoanModel>? newLoanModel, List<LoanModel>? newFilteredLoanModel, LoanStatusFilter? newSelectedFilter, String? newMessage, String? newSearchMessage}) {
    return LoanState(
      loanStatus: newLoanStatus ?? this.loanStatus,
      loanModel: newLoanModel ?? this.loanModel,
      filteredLoanModel: newFilteredLoanModel ?? this.filteredLoanModel,
      selectedFilter: newSelectedFilter ?? this.selectedFilter,
      message: newMessage ?? this.message,
      searchMessage: newSearchMessage ?? this.searchMessage,
    );
  }

  @override
  List<Object> get props => [loanStatus, loanModel, filteredLoanModel, selectedFilter, message, searchMessage];

}
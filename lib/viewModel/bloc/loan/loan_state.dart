part of 'loan_bloc.dart';


class LoanState extends Equatable {
  final LoanStatus loanStatus;
  final List<LoanModel> loanModel;
  final List<LoanModel> filteredLoanModel;
  final LoanStatusFilter selectedFilter;
  final String searchQuery;
  final String message;
  final String searchMessage;

  const LoanState({
    this.loanStatus = LoanStatus.loading,
    this.loanModel = const <LoanModel>[],
    this.filteredLoanModel = const <LoanModel>[],
    this.selectedFilter = LoanStatusFilter.all,
    this.searchQuery = '',
    this.message = '',
    this.searchMessage = '',
  });

  bool get isFilterActive =>
      searchQuery.trim().isNotEmpty || selectedFilter != LoanStatusFilter.all;

  List<LoanModel> get displayedLoans =>
      isFilterActive ? filteredLoanModel : loanModel;

  LoanState copyWith({
    LoanStatus? newLoanStatus,
    List<LoanModel>? newLoanModel,
    List<LoanModel>? newFilteredLoanModel,
    LoanStatusFilter? newSelectedFilter,
    String? newSearchQuery,
    String? newMessage,
    String? newSearchMessage,
  }) {
    return LoanState(
      loanStatus: newLoanStatus ?? loanStatus,
      loanModel: newLoanModel ?? loanModel,
      filteredLoanModel: newFilteredLoanModel ?? filteredLoanModel,
      selectedFilter: newSelectedFilter ?? selectedFilter,
      searchQuery: newSearchQuery ?? searchQuery,
      message: newMessage ?? message,
      searchMessage: newSearchMessage ?? searchMessage,
    );
  }

  @override
  List<Object> get props => [
        loanStatus,
        loanModel,
        filteredLoanModel,
        selectedFilter,
        searchQuery,
        message,
        searchMessage,
      ];
}
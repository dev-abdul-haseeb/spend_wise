part of 'income_bloc.dart';


class IncomeState extends Equatable{

  final IncomeStatus incomeStatus;
  final List<IncomeModel> incomeModel;
  final List<IncomeModel> filteredIncomeModel;
  final DateFilter selectedFilter;

  final String message;
  final String searchMessage;

  const IncomeState ({
    this.incomeStatus = IncomeStatus.loading,
    this.incomeModel = const <IncomeModel>[],
    this.filteredIncomeModel = const <IncomeModel>[],
    this.selectedFilter = DateFilter.all,
    this.message = '',
    this.searchMessage = ''
  });

  IncomeState copyWith({IncomeStatus? newIncomeStatus, List<IncomeModel>? newIncomeModel, List<IncomeModel>? newFilteredIncomeModel,DateFilter? newFilter, String? newMessage, String? newSearchMessage}) {
    return IncomeState(
      incomeStatus: newIncomeStatus ?? this.incomeStatus,
      incomeModel: newIncomeModel ?? this.incomeModel,
      filteredIncomeModel: newFilteredIncomeModel ?? this.filteredIncomeModel,
      selectedFilter: newFilter ?? this.selectedFilter,
      message: newMessage ?? this.message,
      searchMessage: newSearchMessage ?? this.searchMessage,
    );
  }

  @override
  List<Object> get props => [incomeStatus, incomeModel, filteredIncomeModel, selectedFilter, message, searchMessage];

}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/model/loan/loan_model.dart';
import 'package:spend_wise/view/views.dart';
import '../../../repository/loan_repository/lone_repository.dart';

part 'loan_state.dart';
part 'loan_event.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository loanRepository = LoanRepository();

  LoanBloc() : super(const LoanState()) {
    on<GetLoan>(_getLoan);
    on<SearchItem>(_filterList);
    on<AddLoan>(_addLoan);
    on<PayLoan>(_payLoan);
    on<FilterbyStatus>(_filterByStatus);
  }

  List<LoanModel> _computeFilteredList(
    List<LoanModel> loans,
    String query,
    LoanStatusFilter filter,
  ) {
    var result = loans;

    // Filter by status or direction if not All
    switch (filter) {
      case LoanStatusFilter.all:
        break;
      case LoanStatusFilter.paid:
        result = result.where((element) => element.status == loanStatus.Paid).toList();
        break;
      case LoanStatusFilter.unpaid:
        result = result.where((element) => element.status == loanStatus.Unpaid).toList();
        break;
      case LoanStatusFilter.toGive:
        result = result.where((element) => element.amount < 0).toList();
        break;
      case LoanStatusFilter.toTake:
        result = result.where((element) => element.amount > 0).toList();
        break;
    }

    // Filter by search query (person name or reason)
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isNotEmpty) {
      result = result.where((element) {
        final nameMatch = element.person_name.toLowerCase().contains(cleanQuery);
        final reasonMatch = element.reason.toLowerCase().contains(cleanQuery);
        return nameMatch || reasonMatch;
      }).toList();
    }

    return result;
  }

  void _getLoan(GetLoan event, Emitter<LoanState> emit) async {
    try {
      final value = await loanRepository.fetchLoan();
      final filtered = _computeFilteredList(value, state.searchQuery, state.selectedFilter);
      final isFilteredEmpty = filtered.isEmpty && (state.searchQuery.trim().isNotEmpty || state.selectedFilter != LoanStatusFilter.all);

      emit(state.copyWith(
        newLoanStatus: LoanStatus.success,
        newLoanModel: value,
        newFilteredLoanModel: filtered,
        newSearchMessage: isFilteredEmpty ? 'No matching loans found' : '',
        newMessage: 'Successful',
      ));
    } catch (error) {
      emit(state.copyWith(
        newLoanStatus: LoanStatus.failure,
        newMessage: error.toString(),
      ));
    }
  }

  Future<void> _filterList(SearchItem event, Emitter<LoanState> emit) async {
    final newQuery = event.searchKey;
    final filtered = _computeFilteredList(state.loanModel, newQuery, state.selectedFilter);
    final isFilteredEmpty = filtered.isEmpty && (newQuery.trim().isNotEmpty || state.selectedFilter != LoanStatusFilter.all);

    emit(state.copyWith(
      newSearchQuery: newQuery,
      newFilteredLoanModel: filtered,
      newSearchMessage: isFilteredEmpty ? 'No matching loans found' : '',
    ));
  }

  Future<void> _filterByStatus(FilterbyStatus event, Emitter<LoanState> emit) async {
    final newFilter = event.searchkey;
    final filtered = _computeFilteredList(state.loanModel, state.searchQuery, newFilter);
    final isFilteredEmpty = filtered.isEmpty && (state.searchQuery.trim().isNotEmpty || newFilter != LoanStatusFilter.all);

    emit(state.copyWith(
      newSelectedFilter: newFilter,
      newFilteredLoanModel: filtered,
      newSearchMessage: isFilteredEmpty ? 'No matching loans found' : '',
    ));
  }

  void _addLoan(AddLoan event, Emitter<LoanState> emit) async {
    await loanRepository.addLoan(event.loan);
    add(GetLoan());
  }

  void _payLoan(PayLoan event, Emitter<LoanState> emit) async {
    final updatedList = state.loanModel.map((item) {
      if (item.id == event.id) {
        return item.copyWith(newStatus: loanStatus.Paid);
      }
      return item;
    }).toList();

    await loanRepository.payLoan(event.id);

    final filtered = _computeFilteredList(updatedList, state.searchQuery, state.selectedFilter);
    final isFilteredEmpty = filtered.isEmpty && (state.searchQuery.trim().isNotEmpty || state.selectedFilter != LoanStatusFilter.all);

    emit(state.copyWith(
      newLoanModel: updatedList,
      newFilteredLoanModel: filtered,
      newSearchMessage: isFilteredEmpty ? 'No matching loans found' : '',
      newMessage: 'Loan marked as paid!',
    ));
  }
}
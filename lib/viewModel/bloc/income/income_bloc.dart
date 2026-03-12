import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/model/income/income_model.dart';
import 'package:spend_wise/view/views.dart';

import '../../../repository/income_repository/income_repository.dart';

part 'income_state.dart';
part 'income_event.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {

  IncomeRepository incomeRepository = IncomeRepository();

  List<IncomeModel> filteredIncomeModel = [];



  IncomeBloc() : super(IncomeState()) {
    on<GetIncome>(_getIncome);
    on<SearchItem>(_filterList);
    on<AddIncome>(_addIncome);
    on<DeleteIncome>(_deleteIncome);
    on<FilterByDate>(_filterByDate);
  }

  void _getIncome(GetIncome event, Emitter<IncomeState> emit) async {
    await incomeRepository.fetchIncome().then((value) {
      emit(
        state.copyWith(
            newIncomeStatus: IncomeStatus.success,
            newIncomeModel: value,
            newMessage: 'Successful'
        )
      );
    }).onError((error, stackTrace) {
      emit(
        state.copyWith(
            newIncomeStatus: IncomeStatus.failure,
            newMessage: error.toString()
        )
      );
    });
  }

  Future<void> _filterList (SearchItem event, Emitter<IncomeState> emit) async {

    if(event.searchKey.isEmpty) {
      emit(state.copyWith(newFilteredIncomeModel: [], newSearchMessage: ''));
    }

    else if(event.searchKey.isNotEmpty) {
      filteredIncomeModel = state.incomeModel.where(


        //Contains tells that if email contains any word of SearchKey
              (element) => element.source.toLowerCase().toString().contains(event.searchKey.toLowerCase().toString()))
          .toList();
      if(filteredIncomeModel.isEmpty) {   //If the search doesn't match
        emit(state.copyWith(newFilteredIncomeModel: [], newSearchMessage: 'No data found'));
      }
      else {
        emit(state.copyWith(newFilteredIncomeModel: filteredIncomeModel, newSearchMessage: ''));
      }
    }
  }

  void _addIncome(AddIncome event, Emitter<IncomeState> emit) async {
     incomeRepository.addIncome(event.income);
     add(GetIncome());

  }

  void _deleteIncome (DeleteIncome event, Emitter<IncomeState> emit) async {

    final updatedList = state.incomeModel.where((item) => item.id != event.id).toList();
    emit(state.copyWith(newIncomeModel: updatedList, newFilteredIncomeModel: []));

    incomeRepository.deleteIncome(event.id);
    emit(state.copyWith(newIncomeStatus: IncomeStatus.success, newMessage: 'Deleted successfully!'));
  }

  void _filterByDate (FilterByDate event, Emitter<IncomeState> emit) {
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
        ? <IncomeModel>[]
        : state.incomeModel
        .where((item) => item.date_time != null && item.date_time!.isAfter(from!))
        .toList();

    emit(state.copyWith(
      newFilteredIncomeModel: filtered,
      newFilter: event.filter,
      newSearchMessage: filtered.isEmpty && from != null ? 'No data found for this period' : '',
    ));
  }

}
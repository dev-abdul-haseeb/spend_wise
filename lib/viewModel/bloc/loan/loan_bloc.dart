import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/model/loan/loan_model.dart';
import 'package:spend_wise/view/views.dart';
import '../../../repository/loan_repository/lone_repository.dart';

part 'loan_state.dart';
part 'loan_event.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {

  LoanRepository loanRepository = LoanRepository();

  List<LoanModel> filteredLoanModel = [];



  LoanBloc() : super(LoanState()) {
    on<GetLoan>(_getLoan);
    on<SearchItem>(_filterList);
    on<AddLoan>(_addLoan);
    on<PayLoan>(_payLoan);
    on<FilterbyStatus>(_filterByStatus);
  }

  void _getLoan(GetLoan event, Emitter<LoanState> emit) async {
    await loanRepository.fetchLoan().then((value) {
      emit(
        state.copyWith(
            newLoanStatus: LoanStatus.success,
            newLoanModel: value,
            newMessage: 'Successful'
        )
      );
    }).onError((error, stackTrace) {
      emit(
        state.copyWith(
            newLoanStatus: LoanStatus.failure,
            newMessage: error.toString()
        )
      );
    });
  }

  Future<void> _filterList (SearchItem event, Emitter<LoanState> emit) async {

    if(event.searchKey.isEmpty) {
      emit(state.copyWith(newFilteredLoanModel: [], newSearchMessage: ''));
    }

    else if(event.searchKey.isNotEmpty) {
      filteredLoanModel = state.loanModel.where(


        //Contains tells that if email contains any word of SearchKey
              (element) => element.person_name.toLowerCase().toString().contains(event.searchKey.toLowerCase().toString()))
          .toList();
      if(filteredLoanModel.isEmpty) {   //If the search doesn't match
        emit(state.copyWith(newFilteredLoanModel: [], newSearchMessage: 'No data found'));
      }
      else {
        emit(state.copyWith(newFilteredLoanModel: filteredLoanModel, newSearchMessage: ''));
      }
    }
  }

  Future<void> _filterByStatus(FilterbyStatus event, Emitter<LoanState> emit) async {
    if (event.searchkey == LoanStatusFilter.all) {
      emit(state.copyWith(
        newFilteredLoanModel: [],
        newSearchMessage: '',
        newSelectedFilter: LoanStatusFilter.all,
      ));
      return;
    }

    // ✅ map LoanStatusFilter directly to loanStatus
    final targetStatus = event.searchkey == LoanStatusFilter.paid
        ? loanStatus.Paid
        : loanStatus.Unpaid;

    filteredLoanModel = state.loanModel
        .where((element) => element.status == targetStatus) // ✅ direct enum comparison
        .toList();

    if (filteredLoanModel.isEmpty) {
      emit(state.copyWith(
        newFilteredLoanModel: [],
        newSearchMessage: 'No data found',
        newSelectedFilter: event.searchkey,
      ));
    } else {
      emit(state.copyWith(
        newFilteredLoanModel: filteredLoanModel,
        newSearchMessage: '',
        newSelectedFilter: event.searchkey,
      ));
    }
  }

  void _addLoan(AddLoan event, Emitter<LoanState> emit) async {
    loanRepository.addLoan(event.loan);
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


    emit(state.copyWith(
      newLoanModel: updatedList,
      newFilteredLoanModel: [],
      newMessage: 'Loan marked as paid!',
    ));
  }
}
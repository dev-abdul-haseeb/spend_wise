part of 'total_balance_bloc.dart';

abstract class TotalAmountEvent extends Equatable {
  TotalAmountEvent();
  @override
  List<Object?> get props => [];
}

class CalculateTotalAmount extends TotalAmountEvent{}
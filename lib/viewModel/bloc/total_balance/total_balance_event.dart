part of 'total_balance_bloc.dart';

enum DateFilterType {
  thisMonth,
  customRange,
  allTime,
}

abstract class TotalAmountEvent extends Equatable {
  const TotalAmountEvent();
  @override
  List<Object?> get props => [];
}

class CalculateTotalAmount extends TotalAmountEvent {}

class ChangeDateFilter extends TotalAmountEvent {
  final DateFilterType filterType;
  final DateTimeRange? customRange;

  const ChangeDateFilter({
    required this.filterType,
    this.customRange,
  });

  @override
  List<Object?> get props => [filterType, customRange];
}
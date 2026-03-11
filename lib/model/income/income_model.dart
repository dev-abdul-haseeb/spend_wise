import 'package:equatable/equatable.dart';

class IncomeModel extends Equatable{
  final String id;
  final String person_id;
  final double amount;
  final DateTime? date_time;
  final String source;

  const IncomeModel({
    this.id = '',
    this.person_id = '',
    this.amount = 0.0,
    this.date_time,
    this.source = '',
  });

  IncomeModel copyWith({String? newId, String? newPersonId, double? newAmount, DateTime? newDateTime, String? newSource}) {
    return IncomeModel(
      id: newId ?? id,
      person_id: newPersonId ?? person_id,
      amount: newAmount ?? amount,
      date_time: newDateTime ?? date_time,
      source: newSource ?? source,
    );
  }

  @override
  List<Object?> get props => [id, person_id, amount, date_time, source];
}
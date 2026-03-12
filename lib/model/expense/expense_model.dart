import 'package:equatable/equatable.dart';

import '../../config/enum/enum.dart';


class ExpenseModel extends Equatable{

  final String id;
  final String person_id;
  final double amount;
  final String reason;
  final DateTime? date_time;
  final expenseType type;

  const ExpenseModel({
    this.id = '',
    this.person_id = '',
    this.amount = 0.0,
    this.reason = '',
    this.date_time,
    this.type = expenseType.Others,
  });

  ExpenseModel copyWith({String? newId, String? newPersonId, double? newAmount, String? newReason, DateTime? newDateTime, expenseType? newType}) {
    return ExpenseModel(
      id: newId ?? id,
      person_id: newPersonId ?? person_id,
      amount: newAmount ?? amount,
      reason: newReason ?? reason,
      date_time: newDateTime ?? date_time,
      type: newType ?? type,
    );
  }

  @override
  List<Object?> get props => [id, person_id, amount, reason, date_time, type];
}
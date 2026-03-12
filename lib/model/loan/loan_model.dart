import 'package:equatable/equatable.dart';

import '../../config/enum/enum.dart';

class LoanModel extends Equatable{
  final String id;
  final String person_id;
  final String person_name;
  final DateTime? date_time;
  final loanStatus status;
  final double amount;


  const LoanModel({
    this.id = '',
    this.person_id = '',
    this.person_name = '',
    this.date_time,
    this.status = loanStatus.Unpaid,
    this.amount = 0.0
  });

  LoanModel copyWith({String? newId, String? newPersonId,String? newPersonName, double? newAmount, DateTime? newDateTime, loanStatus? newStatus}) {
    return LoanModel(
      id: newId ?? id,
      person_id: newPersonId ?? person_id,
      person_name: newPersonName ?? person_name,
      date_time: newDateTime ?? date_time,
      status: newStatus ?? status,
      amount: newAmount ?? amount,
    );
  }

  @override
  List<Object?> get props => [id, person_id, person_name, date_time, status, amount];
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_wise/config/enum/enum.dart';
import '../../model/loan/loan_model.dart';

class LoanRepository {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LoanModel>> fetchLoan() async {
    try {
      final personId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _firestore
          .collection('loan')
          .where('person_id', isEqualTo: personId)
          .orderBy('date_time', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LoanModel(
          id: doc.id,
          person_id: data['person_id'] ?? '',
          amount: (data['amount'] as num).toDouble(),
          date_time: (data['date_time'] as Timestamp).toDate(),
          status: loanStatus.values.firstWhere( // ✅ parse enum from string
                (e) => e.name == data['status'],
            orElse: () => loanStatus.Unpaid,
          ),
          person_name: data['person_name'] ?? '',
        );
      }).toList();

    } catch (e) {
      throw Exception('Error getting data');
    }
  }

  Future<void> addLoan(LoanModel loan) async {
    try {
      String person_id = FirebaseAuth.instance.currentUser!.uid;
      await _firestore
          .collection('loan')
          .add({
        'person_id' : person_id,
        'amount':loan.amount,
        'date_time' :loan.date_time,
        'person_name': loan.person_name,
        'status' : loan.status.name
      });

    } catch (e) {
      throw Exception('Error getting data');
    }
  }

  Future<void> payLoan (String uid) async {
    await FirebaseFirestore.instance.collection('loan').doc(uid).update({
      'status': 'Paid',
    });
  }

  Stream<double> getTotalLoan() {
    final personId = FirebaseAuth.instance.currentUser!.uid;
    return _firestore
        .collection('loan')
        .where('person_id', isEqualTo: personId)
        .where('status', isEqualTo: 'Unpaid')
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] as num).toDouble();
      }
      return total;
    });
  }

}
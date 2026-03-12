import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/enum/enum.dart';
import '../../model/expense/expense_model.dart';

class ExpenseRepository {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ExpenseModel>> fetchExpense() async {
    try {
      final personId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _firestore
          .collection('expense')
          .where('person_id', isEqualTo: personId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseModel(
          id: doc.id,
          person_id: data['person_id'] ?? '',
          amount: (data['amount'] as num).toDouble(),
          date_time: (data['date_time'] as Timestamp).toDate(),
          type: expenseType.values.firstWhere( // ✅ parse enum from string
                (e) => e.name == data['type'],
            orElse: () => expenseType.Others,
          ),
          reason: (data['reason']),
        );
      }).toList();

    } catch (e) {
      throw Exception('Error getting data');
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      String person_id = FirebaseAuth.instance.currentUser!.uid;
      await _firestore
          .collection('expense')
          .add({
        'person_id' : person_id,
        'amount' : expense.amount,
        'reason' : expense.reason,
        'date_time' : expense.date_time,
        'type' : expense.type.name    //To store enum as string
      });

    } catch (e) {
      throw Exception('Error getting data');
    }
  }

  Future<void> deleteExpense (String uid) async {
    await FirebaseFirestore.instance.collection('expense').doc(uid).delete();
  }

  Stream<double> getTotalExpense() {
    final personId = FirebaseAuth.instance.currentUser!.uid;
    return _firestore
        .collection('expense')
        .where('person_id', isEqualTo: personId)
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
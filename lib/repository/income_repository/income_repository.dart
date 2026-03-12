import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/income/income_model.dart';

class IncomeRepository {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<IncomeModel>> fetchIncome() async {
    try {
      final personId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await _firestore
          .collection('income')
          .where('person_id', isEqualTo: personId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return IncomeModel(
          id: doc.id,
          person_id: data['person_id'] ?? '',
          amount: (data['amount'] as num).toDouble(),
          date_time: (data['date_time'] as Timestamp).toDate(),
          source: data['source'] ?? '',
        );
      }).toList();

    } catch (e) {
      throw Exception('Error getting data');
    }
  }

  Future<void> addIncome(IncomeModel income) async {
    try {
      String person_id = FirebaseAuth.instance.currentUser!.uid;
       await _firestore
          .collection('income')
           .add({
            'person_id' : person_id,
            'amount':income.amount,
            'date_time' :income.date_time,
            'source':income.source
       });

    } catch (e) {
      throw Exception('Error getting data');
    }
  }

  Future<void> deleteIncome (String uid) async {
    await FirebaseFirestore.instance.collection('income').doc(uid).delete();
  }

  Stream<double> getTotalIncome() {
    final personId = FirebaseAuth.instance.currentUser!.uid;
    return _firestore
        .collection('income')
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
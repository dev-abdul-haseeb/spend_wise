import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/user/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserInDb(String uid, String name, String occupation) async {
    final user = await _firestore.collection('user').doc(uid).set({
      'name': name,
      'occupation': occupation
    });
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('user').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return UserModel(
        uid: uid,
        name: data['name'],
        occupation: data['occupation'],
      );
    }
    return null;
  }
}
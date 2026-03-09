import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable{
  final String uid;
  final String email;
  final String name;
  final String password;
  final String occupation;


  const UserModel({
    this.uid = '',
    this.email = '',
    this.name = '',
    this.password = '',
    this.occupation = '',
  });

  UserModel copyWith ({String? newUid, String? newEmail, String? newName, String? newPassword, String? newOccupation}) {
    return UserModel(
      uid: newUid ?? this.uid,
      name: newName ?? this.name,
      email: newEmail ?? this.email,
      password: newPassword ?? this.password,
      occupation: newOccupation ?? this.occupation,
    );
  }

  @override
  List<Object?> get props => [uid, email, name, password, occupation];

}
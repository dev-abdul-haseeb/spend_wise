import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel extends Equatable{
  final String uid;
  final String email;
  final String name;
  final String password;

  const UserModel({
    this.uid = '',
    this.email = '',
    this.name = '',
    this.password = '',
  });

  UserModel copyWith ({String? newUid, String? newEmail, String? newName, String? newPassword}) {
    return UserModel(
      uid: newUid ?? this.uid,
      name: newName ?? this.name,
      email: newEmail ?? this.email,
      password: newPassword ?? this.password,
    );
  }

  @override
  List<Object?> get props => [uid, email, name, password];

}
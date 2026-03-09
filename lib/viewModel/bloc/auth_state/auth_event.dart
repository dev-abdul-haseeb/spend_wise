part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  AuthEvent();

  @override
  List<Object?> get props => [];

}

class AuthCheckRequested extends AuthEvent {}

class AuthLogOut extends AuthEvent {}

class AuthLogin extends AuthEvent {}

class AuthSignUp extends AuthEvent {}

class NameChanged extends AuthEvent {
  String name;
  NameChanged({required this.name});

  @override
  List<Object?> get props => [name];
}

class EmailChanged extends AuthEvent {
  String email;
  EmailChanged({required this.email});

  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends AuthEvent {
  String password;
  PasswordChanged({required this.password});

  @override
  List<Object?> get props => [password];
}
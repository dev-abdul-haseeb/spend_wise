part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  AuthEvent();

  @override
  List<Object?> get props => [];

}

class AuthCheckRequested extends AuthEvent {}

class AuthLoggedOut extends AuthEvent {}
part of 'auth_bloc.dart';
enum AuthStates {
  Loading,
  Initial,
  Authenticated,
  Unauthenticated,
  Error,
}
class AuthState extends Equatable {
  AuthStates currentState;
  UserModel userModel;
  String message;

  AuthState ({
    this.currentState = AuthStates.Initial,
    this.userModel = const UserModel(),
    this.message = '',
  });

  AuthState copyWith({AuthStates? newState, UserModel? newModel, String? newMessage}) {
    return AuthState(
      currentState: newState ?? this.currentState,
      userModel: newModel ?? this.userModel,
      message: newMessage?? this.message,
    );
  }

  @override
  List<Object?> get props => [currentState, userModel, message];

}

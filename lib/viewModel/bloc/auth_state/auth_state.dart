part of 'auth_bloc.dart';
enum AuthStates {
  Initial,
  Authenticated,
  Unauthenticated,
}
class AuthState extends Equatable {
  AuthStates currentState;    //These are states. Now there is only one

  AuthState({    //Constructor
    this.currentState = AuthStates.Initial   //By default zero
  });

  AuthState copyWith ({AuthStates? newState}) {      //Helps us to create a new instance of the class with some value i.e. count
    return AuthState(
      currentState: newState ?? this.currentState,
    );
  }

  @override
  List<Object?> get props => [currentState];


}

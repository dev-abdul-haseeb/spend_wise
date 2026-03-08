import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc(this._firebaseAuth) : super(AuthState()) {

    on<AuthCheckRequested>(_checkAuth);
    on<AuthLoggedOut>(_logOut);

    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        add(AuthCheckRequested());
      } else {
        add(AuthLoggedOut());
      }
    });

  }

  Future<void> _checkAuth (AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(state.copyWith(newState: AuthStates.Authenticated));
    } else {
      emit(state.copyWith(newState: AuthStates.Unauthenticated));
    }
  }

  void _logOut (AuthLoggedOut event, Emitter<AuthState> emit) async {
    await _firebaseAuth.signOut();
    emit(state.copyWith(newState: AuthStates.Unauthenticated));
  }
}
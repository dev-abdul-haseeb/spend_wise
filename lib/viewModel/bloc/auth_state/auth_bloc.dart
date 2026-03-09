import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/model/user/user_model.dart';
import 'package:spend_wise/repository/auth_repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthRepository authRepository = AuthRepository();


  AuthBloc() : super(AuthState()) {
    on<AuthCheckRequested>(_checkAuthRequest);
    on<AuthLogOut>(_logOutUser);
    on<AuthSignUp>(_signUpUser);

    on<NameChanged>(_nameChanged);
    on<EmailChanged>(_emailChanged);
    on<PasswordChanged>(_passwordChanged);


    add(AuthCheckRequested());
  }

  void _checkAuthRequest(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(newState: AuthStates.Loading));

    final (userModel, newState) = await authRepository.checkLogin();

    emit(state.copyWith(newState: newState, newMessage: '', newModel: userModel));
  }

  void _logOutUser (AuthLogOut event, Emitter<AuthState> emit) async {
    emit(state.copyWith(newState: AuthStates.Loading));
    await authRepository.logOutUser();
    emit(state.copyWith(newState: AuthStates.Unauthenticated, newModel: UserModel(), newMessage: ''));

  }

  void _signUpUser (AuthSignUp event, Emitter<AuthState> emit) async {

    emit(state.copyWith(newState: AuthStates.Loading));
    final (newModel, message, newState) = await authRepository.signUpUser(state.userModel.email, state.userModel.password);
    emit(state.copyWith(newModel: newModel, newMessage: message, newState: newState));

  }

  void _nameChanged(NameChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: state.userModel.copyWith(newName: event.name)));
  }

  void _emailChanged(EmailChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: state.userModel.copyWith(newEmail: event.email)));
  }

  void _passwordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: state.userModel.copyWith(newPassword: event.password)));
  }

}
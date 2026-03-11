import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:spend_wise/model/user/user_model.dart';
import 'package:spend_wise/repository/auth_repository/auth_repository.dart';
import 'package:spend_wise/repository/user_repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthRepository authRepository = AuthRepository();
  UserRepository userRepository = UserRepository();


  AuthBloc() : super(AuthState()) {
    on<AuthCheckRequested>(_checkAuthRequest);
    on<AuthLogOut>(_logOutUser);
    on<AuthSignUp>(_signUpUser);
    on<AuthLogin>(_loginUser);
    on<ResetPassword>(_resetPassword);

    on<NameChanged>(_nameChanged);
    on<OccupationChanged>(_occupationChanged);
    on<EmailChanged>(_emailChanged);
    on<PasswordChanged>(_passwordChanged);
    on<ClearAuthFields>(_clearFields);


    add(AuthCheckRequested());
  }

  void _checkAuthRequest(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(newState: AuthStates.Loading));

    final (userModel, newState) = await authRepository.checkLogin();

    if (newState == AuthStates.Authenticated) {
      final secondModel = await userRepository.getUserData(userModel!.uid);
      if (secondModel != null) {
        final updatedModel = userModel.copyWith(
          newName: secondModel.name,
          newOccupation: secondModel.occupation,
        );
        emit(state.copyWith(newState: newState, newMessage: '', newModel: updatedModel));
        return;
      }
    }

    emit(state.copyWith(newState: newState, newMessage: '', newModel: userModel));
  }

  void _logOutUser (AuthLogOut event, Emitter<AuthState> emit) async {
    emit(state.copyWith(newState: AuthStates.Loading, newMessage: 'Logging out'));
    await authRepository.logOutUser();
    emit(state.copyWith(newState: AuthStates.Unauthenticated, newModel: UserModel(), newMessage: ''));

  }

  void _signUpUser (AuthSignUp event, Emitter<AuthState> emit) async {

    emit(state.copyWith(newState: AuthStates.Loading, newMessage: 'Signing up...'));
    final (newModel, message, newState) = await authRepository.signUpUser(state.userModel.email, state.userModel.password);
    if(newModel == null) {
      emit(state.copyWith(newMessage: message, newState: newState));
    }
    else {
      final updatedModel = newModel.copyWith(
        newName: state.userModel.name,
        newOccupation: state.userModel.occupation,
        newPassword: state.userModel.password,
      );
      userRepository.createUserInDb(updatedModel.uid, updatedModel.name, updatedModel.occupation);
      emit(state.copyWith(newModel: updatedModel, newMessage: message, newState: newState));
    }
  }

  void _loginUser(AuthLogin event, Emitter<AuthState> emit) async {
    emit(state.copyWith(newState: AuthStates.Loading, newMessage: 'Logging in...'));
    final (newModel, message, newState) = await authRepository.loginUser(state.userModel.email, state.userModel.password);

    if (newState == AuthStates.Authenticated) {
      final secondModel = await userRepository.getUserData(newModel!.uid);
      if (secondModel != null) {
        final updatedModel = newModel.copyWith(
          newName: secondModel.name,
          newOccupation: secondModel.occupation,
        );
        emit(state.copyWith(newModel: updatedModel, newMessage: message, newState: newState));
        return;
      }
    }

    emit(state.copyWith(newModel: newModel, newMessage: message, newState: newState));
  }

  void _resetPassword(ResetPassword event, Emitter<AuthState> emit) async {
    emit(state.copyWith(newState: AuthStates.Loading, newMessage: ''));
    try {
      await authRepository.resetPassword(state.userModel.email);
      emit(state.copyWith(
        newState: AuthStates.Unauthenticated,
        newMessage: 'Password reset email sent!',
      ));
    } catch (e) {
      emit(state.copyWith(
        newState: AuthStates.Error,
        newMessage: 'Failed to send reset email. Check the address and try again.',
      ));
    }
    add(ClearAuthFields());
  }

  void _nameChanged(NameChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: state.userModel.copyWith(newName: event.name)));
  }

  void _occupationChanged(OccupationChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: state.userModel.copyWith(newOccupation: event.occupation)));
  }

  void _emailChanged(EmailChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: state.userModel.copyWith(newEmail: event.email)));
  }

  void _passwordChanged(PasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: state.userModel.copyWith(newPassword: event.password)));
  }

  void _clearFields(ClearAuthFields event, Emitter<AuthState> emit) {
    emit(state.copyWith(newModel: UserModel(), newMessage: ''));
  }

}
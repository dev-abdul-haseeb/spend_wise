import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_wise/model/user/user_model.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';

class AuthRepository {

  Future<(UserModel?, AuthStates)> checkLogin() async {
    try {
      final user = await FirebaseAuth.instance.currentUser;
      if(user == null) {
        return (null, AuthStates.Unauthenticated);
      }
      else {
        UserModel newModel = UserModel(
          uid: user.uid,
          name: user.displayName!,
          email: user.email!,
        );
        return (newModel, AuthStates.Authenticated);
      }
    }
    catch(e) {
      return (null, AuthStates.Error);
    }

  }

  Future<void> logOutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<(UserModel?, String?, AuthStates)> loginUser(String email, String password) async {
    try {
      final credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
      if(credentials.user != null) {
        UserModel user =UserModel(
          uid: credentials.user!.uid,
          name: credentials.user!.displayName!,
          email: credentials.user!.email!,
        );
        print('Success');
        return (user, 'Login Successful', AuthStates.Authenticated);
      }
      else {
        print('Not');
        return (null, 'No such user exists!', AuthStates.Unauthenticated);
      }
    }
    catch(e) {
      print('L');
      return (null, e.toString(), AuthStates.Unauthenticated);
    }
  }

  Future<(UserModel?, String?, AuthStates)> signUpUser(String email, String password) async {
    try {
      final credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);
      UserModel user = UserModel(
        uid: credentials.user!.uid,
        name: credentials.user!.displayName!,
        email: credentials.user!.email!,
      );
      return (user, 'SignUp Successful', AuthStates.Authenticated);

    }
    catch(e) {
      return (null, e.toString(), AuthStates.Unauthenticated);
    }
  }

}
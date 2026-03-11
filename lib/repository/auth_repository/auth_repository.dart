import 'package:firebase_auth/firebase_auth.dart';
import 'package:spend_wise/model/user/user_model.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';

class AuthRepository {

  String _loginError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  String _signUpError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }

  Future<(UserModel?, AuthStates)> checkLogin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return (null, AuthStates.Unauthenticated);
      }
      UserModel newModel = UserModel(
        uid: user.uid,
        email: user.email!,
      );
      return (newModel, AuthStates.Authenticated);
    } catch (e) {
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
      if (credentials.user != null) {
        final user = UserModel(
          uid: credentials.user!.uid,
          email: credentials.user!.email!,
        );
        return (user, 'Welcome back!', AuthStates.Authenticated);
      }
      return (null, 'No account found with these credentials.', AuthStates.Error);
    } on FirebaseAuthException catch (e) {
      return (null, _loginError(e.code), AuthStates.Error);
    } catch (e) {
      return (null, 'Something went wrong. Please try again.', AuthStates.Error);
    }
  }

  Future<(UserModel?, String?, AuthStates)> signUpUser(String email, String password) async {
    try {
      final credentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = UserModel(
        uid: credentials.user!.uid,
        email: credentials.user!.email!,
      );
      return (user, 'Account created successfully!', AuthStates.Authenticated);
    } on FirebaseAuthException catch (e) {
      return (null, _signUpError(e.code), AuthStates.Error); // ✅ clean message
    } catch (e) {
      return (null, 'Something went wrong. Please try again.', AuthStates.Error);
    }
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
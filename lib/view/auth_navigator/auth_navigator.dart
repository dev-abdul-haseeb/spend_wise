import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/view/authentication/login_screen.dart';
import 'package:spend_wise/view/home/home_screen.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';

class AuthNavigator extends StatelessWidget {
  const AuthNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.currentState == AuthStates.Authenticated) {
          return HomeScreen();
        } else if (state.currentState == AuthStates.Unauthenticated) {
          return LoginScreen();
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../viewModel/bloc/auth_state/auth_bloc.dart';
import '../../../viewModel/bloc/obscure_text/obscure_text_bloc.dart';

class SignupTab extends StatefulWidget {
  const SignupTab({super.key});

  @override
  State<SignupTab> createState() => _SignupTabState();
}

class _SignupTabState extends State<SignupTab> {

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return TextFormField(
                  keyboardType: TextInputType.text,
                  focusNode: _nameFocusNode,
                  decoration: InputDecoration(
                    hint: Text('Name'),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    context.read<AuthBloc>().add(NameChanged(name: newValue));
                  },
                  onFieldSubmitted: (value) {},
                );
              }
          ),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return TextFormField(
                keyboardType: TextInputType.emailAddress,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  hint: Text('Email'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (newValue) {
                  context.read<AuthBloc>().add(EmailChanged(email: newValue));
                },
                onFieldSubmitted: (value) {},
              );
            }
          ),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return BlocBuilder<ObscureTextBloc,ObscureTextState>(
                builder: (context, state2) {
                  return TextFormField(
                    keyboardType: TextInputType.text,
                    focusNode: _passwordFocusNode,
                    obscureText: state2.obscureText,
                    decoration: InputDecoration(
                      hint: Text('Password'),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          state2.obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          context.read<ObscureTextBloc>().add(ToggleObscure());
                        },
                      ),
                    ),
                    onChanged: (newValue) {
                      context.read<AuthBloc>().add(PasswordChanged(password: newValue));
                    },
                    onFieldSubmitted: (value) {},
                  );
                }
              );
            }
          ),

          BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return ElevatedButton(onPressed: () async {
                  print(state.userModel.name);
                  print('Name' + state.userModel.email);
                  print(state.userModel.password);
                }, child: Text('Check'));
              }
          ),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return ElevatedButton(onPressed: () async {
                context.read<AuthBloc>().add(AuthSignUp());
              }, child: Text('Sign Up'));
            }
          ),

          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) => previous.message != current.message,
              builder: (context, state) {
                return Text(state.message.toString());
              }
          ),

        ],
      ),
    );
  }
}

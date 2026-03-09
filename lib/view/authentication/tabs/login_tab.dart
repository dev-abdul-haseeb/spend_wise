import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/flash_bar/flash_bar.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';
import 'package:spend_wise/viewModel/bloc/obscure_text/obscure_text_bloc.dart';

class LoginTab extends StatefulWidget {
  LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final FocusNode _emailFocusNode = FocusNode();

  final FocusNode _passwordFocusNode = FocusNode();

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
                keyboardType: TextInputType.emailAddress,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  hint: Text('Email'),
                  border: OutlineInputBorder(),
                ),
                onChanged: (newValue) {
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

              }, child: Text('Hello'));
            }
          ),

        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/textwidgets.dart';

import '../../config/components/button.dart';
import '../../config/flash_bar/flash_bar.dart';
import '../../viewModel/bloc/auth_state/auth_bloc.dart';
import '../../viewModel/bloc/theme/theme_bloc.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  bool _resetAttempted = false;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailNode = FocusNode();

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Please enter a valid email address.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(
            title: AppText('Reset password', color: themeState.theme[appColors.textPrimaryColor]!, type: TextType.appName),
            centerTitle: true,
            backgroundColor: themeState.theme[appColors.primaryColor],
          ),
          body: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
            _resetAttempted &&
                previous.currentState == AuthStates.Loading &&
                current.currentState != AuthStates.Loading,
            listener: (context, state) {
              _resetAttempted = false;
              final isSuccess = state.currentState != AuthStates.Error;
              final message = (state.message?.isNotEmpty ?? false)
                  ? state.message!
                  : (isSuccess ? 'Password reset email sent!' : 'Failed to send reset email.');
              showFlashbar(context, message, isSuccess);
            },
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailNode,
                      textCapitalization: TextCapitalization.none,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        hintText: 'Enter your Email',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        context.read<AuthBloc>().add(EmailChanged(email: value));
                      },
                    ),
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                      previous.currentState != current.currentState,
                      builder: (context, state) {
                        final isLoading = state.currentState == AuthStates.Loading;

                        return AppButton(
                          'Send password-reset link',
                          color: themeState.theme[appColors.textSecondaryColor]!,
                          bgcolor: themeState.theme[appColors.accentColor]!,
                          isLoading: isLoading,type: ButtonType.primary,
                          size: ButtonSize.small,
                          onPressed: isLoading
                              ? null
                              : () {
                            if (!_formKey.currentState!.validate()) return;
                            _resetAttempted = true;
                            context.read<AuthBloc>().add(ResetPassword());
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../../config/color/colors.dart';
import '../../../config/components/button.dart';
import '../../../config/components/icons.dart';
import '../../../config/flash_bar/flash_bar.dart';
import '../../../viewModel/bloc/auth_state/auth_bloc.dart';
import '../../../viewModel/bloc/obscure_text/obscure_text_bloc.dart';

class SignupTab extends StatefulWidget {
  const SignupTab({super.key});

  @override
  State<SignupTab> createState() => _SignupTabState();
}

class _SignupTabState extends State<SignupTab> {

  final _formKey = GlobalKey<FormState>();

  final List<FocusNode> nodes = [
    FocusNode(), // Name: 0
    FocusNode(), // Occupation: 1
    FocusNode(), // Email: 2
    FocusNode(), // Password: 3
  ];

  final List<TextInputType> inputTypes = [
    TextInputType.text,
    TextInputType.text,
    TextInputType.emailAddress,
    TextInputType.text,
  ];

  final List<TextCapitalization> capitalizations = [
    TextCapitalization.words,
    TextCapitalization.words,
    TextCapitalization.none,
    TextCapitalization.none,
  ];

  final List<String> labels = [
    'Name',
    'Occupation',
    'Email',
    'Password',
  ];

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? _validatorForIndex(int index, String? value) {
    switch (index) {
      case 2: return _validateEmail(value);
      case 3: return _validatePassword(value);
      default: return null;
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(nodes[0]);
    });
  }

  @override
  void dispose() {
    for (final node in nodes) node.dispose();
    super.dispose();
  }

  AuthEvent _eventForIndex(int index, String value) {
    switch (index) {
      case 0: return NameChanged(name: value);
      case 1: return OccupationChanged(occupation: value);
      case 2: return EmailChanged(email: value);
      case 3: return PasswordChanged(password: value);
      default: throw RangeError('Index $index out of range');
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<ThemeBloc,ThemeState>(
      builder: (context, themeState) {
        return BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
          previous.currentState == AuthStates.Loading &&
              current.currentState != AuthStates.Loading,
          listener: (context, state) {
            final isSuccess = state.currentState == AuthStates.Authenticated;
            final message =
            (state.message?.isNotEmpty ?? false) ? state.message! : (isSuccess ? 'Sign up successful!' : 'Sign up failed.');
            showFlashbar(context, message, isSuccess);
          },
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: nodes.length,
                    itemBuilder: (context, index) {
                      final isPassword = labels[index] == 'Password';
                      return BlocBuilder<ObscureTextBloc, ObscureTextState>(
                        buildWhen: (previous, current) =>
                        isPassword && previous.obscureText != current.obscureText,
                        builder: (context, obscureState) {
                          return TextFormField(
                            keyboardType: inputTypes[index],
                            focusNode: nodes[index],
                            textCapitalization: capitalizations[index],
                            obscureText: isPassword ? obscureState.obscureText : false,
                            // Validate on user interaction
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value) => _validatorForIndex(index, value),
                            style: TextStyle(
                                color: themeState.isDark ? themeState.theme[appColors.accentColor] : themeState.theme[appColors.textPrimaryColor]
                            ),
                            decoration: InputDecoration(
                              hintText: labels[index],
                              border: const OutlineInputBorder(),
                              suffixIcon: isPassword
                                  ? IconButton(
                                icon: Icon(
                                  obscureState.obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => context
                                    .read<ObscureTextBloc>()
                                    .add(ToggleObscure()),
                              )
                                  : null,
                              prefixIcon: AppIcons.appIcon[labels[index]],
                              prefixIconColor: themeState.theme[appColors.primaryColor]
                            ),
                            onChanged: (newValue) => context
                                .read<AuthBloc>()
                                .add(_eventForIndex(index, newValue)),
                            onFieldSubmitted: (_) {
                              if (index == nodes.length - 1) {
                                FocusScope.of(context).unfocus();
                              } else {
                                FocusScope.of(context).requestFocus(nodes[index + 1]);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),

                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (previous, current) =>
                    previous.currentState != current.currentState,
                    builder: (context, state) {
                      final isLoading = state.currentState == AuthStates.Loading;
                      return AppButton(
                        'Sign Up',
                        color: themeState.theme[appColors.textSecondaryColor]!,
                        bgcolor: themeState.theme[appColors.accentColor]!,
                        isLoading: isLoading,type: ButtonType.primary,
                        onPressed: isLoading
                            ? null
                            : () {
                          if (!_formKey.currentState!.validate()) return;
                          context.read<AuthBloc>().add(AuthSignUp());
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );

  }
}
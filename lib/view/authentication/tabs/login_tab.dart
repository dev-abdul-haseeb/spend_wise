import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/config/components/icons.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/config/flash_bar/flash_bar.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';
import 'package:spend_wise/viewModel/bloc/obscure_text/obscure_text_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../../config/routes/route_names.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {

  bool _loginAttempted = false;

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    _loginAttempted = true;
    context.read<AuthBloc>().add(AuthLogin());
  }

  final _formKey = GlobalKey<FormState>();

  final List<FocusNode> nodes = [
    FocusNode(),    //Email: 2
    FocusNode(),    //Password: 3
  ];

  final List<TextInputType> inputTypes = [
    TextInputType.emailAddress,
    TextInputType.text,
  ];

  final List<TextCapitalization> capitalizations = [
    TextCapitalization.none,
    TextCapitalization.none,
  ];

  final List<String> labels = [
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
      case 0: return _validateEmail(value);
      case 1: return _validatePassword(value);
      default: return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final node in nodes) {
      node.dispose();
    }
    super.dispose();
  }

  AuthEvent _eventForIndex(int index, String value) {
    switch (index) {
      case 0: return EmailChanged(email: value);
      case 1: return PasswordChanged(password: value);
      default: throw RangeError('Index $index out of range');
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocListener<AuthBloc, AuthState>(
          // Only react when a login attempt finishes (leaves Loading)
          listenWhen: (previous, current) =>
              _loginAttempted &&
              previous.currentState == AuthStates.Loading &&
              current.currentState != AuthStates.Loading,
          listener: (context, state) {
            _loginAttempted = false;
            final isSuccess = state.currentState == AuthStates.Authenticated;
            final message = state.message.isNotEmpty
                ? state.message
                : (isSuccess ? 'Login successful!' : 'Login failed.');
            showFlashbar(context, message, isSuccess);
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth > 600 ? 400 : screenWidth * 0.06,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    ...List.generate(nodes.length, (index) {
                      final isPassword = labels[index] == 'Password';
                      return BlocBuilder<ObscureTextBloc, ObscureTextState>(
                        buildWhen: (previous, current) =>
                            isPassword && previous.obscureText != current.obscureText,
                        builder: (context, obscureState) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: themeState.isDark ? 0.25 : 0.06,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                keyboardType: inputTypes[index],
                                focusNode: nodes[index],
                                textCapitalization: capitalizations[index],
                                obscureText: isPassword ? obscureState.obscureText : false,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (value) => _validatorForIndex(index, value),
                                scrollPadding: const EdgeInsets.only(bottom: 100),
                                style: TextStyle(
                                  color: themeState.theme[appColors.textPrimaryColor],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: themeState.theme[appColors.cardColor],
                                  hintText: labels[index],
                                  hintStyle: TextStyle(
                                    color: themeState.theme[appColors.textSecondaryColor],
                                    fontSize: 14,
                                  ),
                                  suffixIcon: isPassword
                                      ? IconButton(
                                          icon: Icon(
                                            obscureState.obscureText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: themeState.theme[appColors.textSecondaryColor],
                                          ),
                                          onPressed: () => context
                                              .read<ObscureTextBloc>()
                                              .add(ToggleObscure()),
                                        )
                                      : null,
                                  prefixIcon: AppIcons.appIcon[labels[index]],
                                  prefixIconColor: themeState.theme[appColors.primaryColor],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                      color: themeState.isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : Colors.grey.withValues(alpha: 0.25),
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                      color: themeState.theme[appColors.primaryColor]!,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                      color: themeState.theme[appColors.expenseColor]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                      color: themeState.theme[appColors.expenseColor]!,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                textInputAction: index == nodes.length - 1
                                    ? TextInputAction.done
                                    : TextInputAction.next,
                                onChanged: (newValue) => context
                                    .read<AuthBloc>()
                                    .add(_eventForIndex(index, newValue)),
                                onFieldSubmitted: (_) {
                                  if (index == nodes.length - 1) {
                                    FocusScope.of(context).unfocus();
                                    _submitForm();
                                  } else {
                                    FocusScope.of(context).requestFocus(nodes[index + 1]);
                                  }
                                },
                              ),
                              ),
                            );
                          },
                        );
                      }),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.resetPasswordScreen);
                          },
                          child: BlocBuilder<ThemeBloc, ThemeState>(
                            builder: (context, state) {
                              return AppText(
                                'Forgot Password?',
                                color: state.theme[appColors.primaryColor]!,
                                type: TextType.buttons,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      BlocBuilder<AuthBloc, AuthState>(
                        buildWhen: (previous, current) =>
                            previous.currentState != current.currentState,
                        builder: (context, state) {
                          final isLoading = state.currentState == AuthStates.Loading;
                          return AppButton(
                            'Login',
                            color: Colors.white,
                            bgcolor: themeState.theme[appColors.primaryColor]!,
                            isLoading: isLoading,
                            type: ButtonType.primary,
                            onPressed: isLoading ? null : _submitForm,
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.04),
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
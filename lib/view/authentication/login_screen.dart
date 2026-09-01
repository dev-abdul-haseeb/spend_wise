import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/view/authentication/tabs/login_tab.dart';
import 'package:spend_wise/view/authentication/tabs/signup_tab.dart';
import 'package:spend_wise/viewModel/bloc/obscure_text/obscure_text_bloc.dart';

import '../../config/color/colors.dart';
import '../../config/components/textwidgets.dart';
import '../../viewModel/bloc/auth_state/auth_bloc.dart';
import '../../viewModel/bloc/theme/theme_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late ObscureTextBloc _obscureTextBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _obscureTextBloc = ObscureTextBloc();

    // Clear fields when switching header
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<AuthBloc>().add(ClearAuthFields());
        _obscureTextBloc.add(ClearObscureFiled());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _obscureTextBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    var isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocProvider(
      create: (context) => _obscureTextBloc,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return Scaffold(
            backgroundColor: themeState.theme[appColors.appBGColor],
            appBar: AppBar(
              backgroundColor: themeState.theme[appColors.primaryColor],
              centerTitle: true,
              title: AppText(
                'SpendWise',
                type: TextType.appName,
                color: themeState.theme[appColors.textPrimaryColor]!,
              ),
              shadowColor: themeState.theme[appColors.accentColor],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: themeState.theme[appColors.accentColor],
                labelColor: themeState.theme[appColors.accentColor],
                unselectedLabelColor: themeState.theme[appColors.textPrimaryColor],
                tabs: const [
                  Tab(text: 'Login'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeState.theme[appColors.primaryColor]!,
                    themeState.theme[appColors.appBGColor]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: isKeyboardOpen
                        ? 0
                        : (screenWidth > 600
                            ? screenWidth * 0.2 + 40
                            : screenHeight * 0.2),
                    child: isKeyboardOpen
                        ? const SizedBox.shrink()
                        : Center(
                            child: Container(
                              width: screenWidth > 600
                                  ? screenWidth * 0.2
                                  : screenHeight * 0.16,
                              height: screenWidth > 600
                                  ? screenWidth * 0.2
                                  : screenHeight * 0.16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF0F2F8),
                                boxShadow: [
                                  const BoxShadow(
                                    color: Color(0xFFF0F2F8),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                    offset: Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    spreadRadius: -2,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    'Assets/Logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        LoginTab(),
                        SignupTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

  }
}
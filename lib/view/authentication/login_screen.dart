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
                tabs: [
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
                  screenWidth > 600
                    ? SizedBox(
                        height: screenWidth*0.2 + 40,
                        child: Center(
                          child: Container(
                            width: screenWidth*0.2,
                            height: screenWidth*0.2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF0F2F8),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFF0F2F8),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'Assets/Logo.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: screenWidth,
                        height: screenHeight*0.4,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F2F8),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFF0F2F8),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: -2,
                              offset: const Offset(0, -4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 2,
                          ),
                        ),
                        child: Image.asset('Assets/Logo.png'),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
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
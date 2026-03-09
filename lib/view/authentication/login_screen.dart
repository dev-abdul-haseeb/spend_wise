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

    // Clear fields when switching tabs
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
    return BlocProvider(
      create: (context) => _obscureTextBloc,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: state.theme[appColors.appBGColor],
            appBar: AppBar(
              backgroundColor: state.theme[appColors.primaryColor],
              centerTitle: true,
              title: AppText(
                'SpendWise',
                type: TextType.appName,
                color: state.theme[appColors.textPrimaryColor]!,
              ),
              shadowColor: state.theme[appColors.accentColor],
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: state.theme[appColors.accentColor],
                labelColor: state.theme[appColors.accentColor],
                unselectedLabelColor: state.theme[appColors.textPrimaryColor],
                tabs: [
                  Tab(text: 'Login'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                LoginTab(),
                SignupTab(),
              ],
            ),
          );
        },
      ),
    );

  }
}
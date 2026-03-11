import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc,ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          backgroundColor: themeState.theme[appColors.appBGColor],
        );
      }
    );
  }
}

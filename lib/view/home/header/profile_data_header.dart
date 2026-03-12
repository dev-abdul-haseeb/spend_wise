import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../../viewModel/bloc/total_balance/total_balance_bloc.dart';

class ProfileDataHeader extends StatefulWidget {
  const ProfileDataHeader({super.key});

  @override
  State<ProfileDataHeader> createState() => _ProfileDataHeaderState();
}

class _ProfileDataHeaderState extends State<ProfileDataHeader> {


  @override
  void initState() {
     super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<TotalBalanceBloc, TotalBalanceState>(
            builder: (context, balanceState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50,),
                  Text(
                    balanceState.total.toString()
                  ),
                  Text(
                      balanceState.loanTotal.toString()
                  ),
                  Text(
                      balanceState.expenseTotal.toString()
                  ),
                  Text(
                      balanceState.incomeTotal.toString()
                  ),
                ],
              );
            }
          );
        }
    );
  }
}

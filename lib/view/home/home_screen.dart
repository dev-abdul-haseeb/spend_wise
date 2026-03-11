import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/viewModel/bloc/navigation/navigation_bloc.dart';

import 'package:spend_wise/view/views.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late NavigationBloc _navigationBloc;

  final List<BottomNavigationBarItem> barItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.arrow_circle_up),
      label: 'Income',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.arrow_circle_down),
      label: 'Expenses',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.handshake_outlined),
      label: 'Loan',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigationBloc = NavigationBloc();
  }

  @override
  void dispose() {
    _navigationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _navigationBloc,
      child: BlocBuilder<ThemeBloc,ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<NavigationBloc,NavigationState>(
            builder: (context, navigationState) {
              return Scaffold(
                backgroundColor: themeState.theme[appColors.appBGColor],
                  body: Column(
                    children: [
                      if (navigationState.selectedIndex != 3)
                        const ProfileDataHeader(),
                      Expanded(
                        child: IndexedStack(
                          index: navigationState.selectedIndex,
                          children: [
                            IncomeScreen(),
                            ExpenseScreen(),
                            LoanScreen(),
                            ProfileScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: navigationState.selectedIndex,
                    backgroundColor: themeState.theme[appColors.primaryColor],
                    unselectedItemColor: themeState.theme[appColors.accentColor],
                    selectedItemColor: themeState.theme[appColors.cardColor],
                    onTap: (index) {
                      context.read<NavigationBloc>().add(ChangeIndex(index: index));
                    },
                    items: barItems,
                  )
              );
            }
          );
        }

      ),
    );
  }
}

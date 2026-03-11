import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';

import '../../config/color/colors.dart';
import '../../viewModel/bloc/theme/theme_bloc.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  List<String> labels = [
    'Name',
    'Occupation',
    'Email'
  ];

  List<Icon> icons = [
    Icon(Icons.person),
    Icon(Icons.work_outline),
    Icon(Icons.mail_outline),
  ];


  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return BlocBuilder<ThemeBloc,ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          backgroundColor: themeState.theme[appColors.appBGColor],
          appBar: AppBar(
            backgroundColor: themeState.theme[appColors.primaryColor],
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: themeState.theme[appColors.cardColor],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    themeState.isDark ? Icons.light_mode : Icons.dark_mode,
                    color: themeState.theme[appColors.primaryColor],
                  ),
                  onPressed: () {
                    context.read<ThemeBloc>().add(ToggleTheme());
                  },
                ),
              ),
            ],
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
            child: BlocBuilder<AuthBloc,AuthState>(
              builder: (context, authState) {
                final Map<String, String> values = {
                  'Name': authState.userModel.name,
                  'Occupation': authState.userModel.occupation,
                  'Email': authState.userModel.email,
                };
                return Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      SizedBox(
                        height: screenWidth>600 ? 100 : screenWidth * 0.2,
                        width: screenWidth>600 ? 100 : screenWidth * 0.2,
                        child: CircleAvatar(
                          backgroundColor: themeState.theme[appColors.primaryColor],
                          child: AppText(
                            authState.userModel.name
                                .split(' ')
                                .map((word) => word.isNotEmpty ? word[0].toUpperCase() : ' ')
                                .join(),
                            color: themeState.theme[appColors.accentColor]!,
                            type: TextType.appName,

                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight*0.02,),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AppText(
                          'Your information:',
                          color: themeState.theme[appColors.textPrimaryColor]!,
                          type: TextType.screenTitles,
                        ),
                      ),
                      SizedBox(height: screenHeight*0.01,),
                      Card(
                        color: themeState.theme[appColors.cardColor],
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: labels.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              splashColor: themeState.theme[appColors.accentColor],
                              onTap: () {},
                              leading: icons[index],
                              title: AppText(
                                labels[index],
                                color: themeState.theme[appColors.primaryColor]!,
                                type: TextType.transactionDescription,
                                align: TextAlign.left,
                              ),
                              subtitle: AppText(
                                values[labels[index]] ?? ' ',
                                color: themeState.theme[appColors.textSecondaryColor]!,
                                type: TextType.transactionAmount,
                                align: TextAlign.left,
                              ),
                            );
                          }
                        ),
                      ),

                      Spacer(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AppButton(
                          'LogOut',
                          color: themeState.theme[appColors.cardColor]!,
                          bgcolor: themeState.theme[appColors.expenseColor]!,
                          type: ButtonType.primary,
                          size: ButtonSize.medium,
                          leadingIcon: Icons.logout,
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogOut());
                          },
                        ),
                      ),
                      SizedBox(height: screenHeight*0.02,),
                    ],
                  ),
                );
              }
            ),
          ),
        );
      }
    );
  }
}

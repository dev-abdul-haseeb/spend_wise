import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/viewModel/bloc/navigation/navigation_bloc.dart';
import 'package:spend_wise/view/views.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';
import '../../services/app_update_service.dart';
import '../../viewModel/bloc/total_balance/total_balance_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NavigationBloc _navigationBloc;
  late TotalBalanceBloc _totalBalanceBloc;

  @override
  void initState() {
    super.initState();
    _navigationBloc = NavigationBloc();
    _totalBalanceBloc = TotalBalanceBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdate(context, showNoUpdateDialog: false);
    });
  }

  @override
  void dispose() {
    _navigationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _navigationBloc),
        BlocProvider(create: (context) => _totalBalanceBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final primaryColor = themeState.theme[appColors.primaryColor]!;
          final textSecondary = themeState.theme[appColors.textSecondaryColor]!;
          final isDark = themeState.isDark;

          return BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, navigationState) {
              return Scaffold(
                backgroundColor: themeState.theme[appColors.appBGColor],
                body: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      if (navigationState.selectedIndex != 3)
                        const ProfileDataHeader(),
                      Expanded(
                        child: IndexedStack(
                          index: navigationState.selectedIndex,
                          children: const [
                            IncomeScreen(),
                            ExpenseScreen(),
                            LoanScreen(),
                            ProfileScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131B2E).withValues(alpha: 0.88)
                        : Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.06),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.4)
                            : primaryColor.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildNavItem(
                              context: context,
                              index: 0,
                              selectedIndex: navigationState.selectedIndex,
                              icon: Icons.arrow_downward_rounded,
                              label: 'Income',
                              activeColor: const Color(0xFF10B981),
                              primaryColor: primaryColor,
                              textSecondary: textSecondary,
                            ),
                            _buildNavItem(
                              context: context,
                              index: 1,
                              selectedIndex: navigationState.selectedIndex,
                              icon: Icons.arrow_upward_rounded,
                              label: 'Expenses',
                              activeColor: const Color(0xFFF43F5E),
                              primaryColor: primaryColor,
                              textSecondary: textSecondary,
                            ),
                            _buildNavItem(
                              context: context,
                              index: 2,
                              selectedIndex: navigationState.selectedIndex,
                              icon: Icons.handshake_outlined,
                              label: 'Loans',
                              activeColor: const Color(0xFFF59E0B),
                              primaryColor: primaryColor,
                              textSecondary: textSecondary,
                            ),
                            _buildNavItem(
                              context: context,
                              index: 3,
                              selectedIndex: navigationState.selectedIndex,
                              icon: Icons.person_outline_rounded,
                              label: 'Profile',
                              activeColor: primaryColor,
                              primaryColor: primaryColor,
                              textSecondary: textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required IconData icon,
    required String label,
    required Color activeColor,
    required Color primaryColor,
    required Color textSecondary,
  }) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        context.read<NavigationBloc>().add(ChangeIndex(index: index));
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: activeColor.withValues(alpha: 0.35),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: activeColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

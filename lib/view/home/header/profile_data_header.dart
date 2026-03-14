import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';
import '../../../viewModel/bloc/total_balance/total_balance_bloc.dart';

class ProfileDataHeader extends StatefulWidget {
  const ProfileDataHeader({super.key});

  @override
  State<ProfileDataHeader> createState() => _ProfileDataHeaderState();
}

class _ProfileDataHeaderState extends State<ProfileDataHeader> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600; // Windows/tablet breakpoint

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<TotalBalanceBloc, TotalBalanceState>(
          builder: (context, balanceState) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 30,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 36 : 20,
                vertical: isWide ? 28 : 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeState.theme[appColors.accentColor]!,
                    themeState.theme[appColors.primaryColor]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: themeState.theme[appColors.primaryColor]!,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Total Balance',
                    color: Colors.white.withOpacity(0.75),
                    type: TextType.balanceAmount,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      'Rs. ${balanceState.total}',
                      color: Colors.white,
                      type: TextType.balanceAmount,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: themeState.theme[appColors.cardColor]!, thickness: 1),
                  const SizedBox(height: 16),

                  isWide
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatTile(
                        label: 'Income',
                        value: 'Rs. ${balanceState.incomeTotal}',
                        icon: Icons.arrow_downward_rounded,
                        iconColor: Colors.greenAccent,
                        labelColor: themeState.theme[appColors.incomeColor]!,
                        valueColor: themeState.theme[appColors.cardColor]!,
                      ),
                      _VerticalDivider(themeState: themeState,),
                      _StatTile(
                        label: 'Expenses',
                        value: 'Rs. ${balanceState.expenseTotal}',
                        icon: Icons.arrow_upward_rounded,
                        iconColor: Colors.redAccent,
                        labelColor: themeState.theme[appColors.expenseColor]!,
                        valueColor: themeState.theme[appColors.cardColor]!,
                      ),
                      _VerticalDivider(themeState: themeState,),
                      _StatTile(
                        label: 'Loans',
                        value: 'Rs. ${balanceState.loanTotal}',
                        icon: Icons.account_balance_rounded,
                        iconColor: Colors.amberAccent,
                        labelColor: themeState.theme[appColors.accentColor]!,
                        valueColor: themeState.theme[appColors.cardColor]!,
                      ),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatTile(
                        label: 'Income',
                        value: 'Rs. ${balanceState.incomeTotal}',
                        icon: Icons.arrow_downward_rounded,
                        iconColor: Colors.greenAccent,
                        labelColor: themeState.theme[appColors.incomeColor]!,
                        valueColor: themeState.theme[appColors.cardColor]!,
                      ),
                      _StatTile(
                        label: 'Expenses',
                        value: 'Rs. ${balanceState.expenseTotal}',
                        icon: Icons.arrow_upward_rounded,
                        iconColor: Colors.redAccent,
                        labelColor: themeState.theme[appColors.expenseColor]!,
                        valueColor: themeState.theme[appColors.cardColor]!,
                      ),
                      _StatTile(
                        label: 'Loans',
                        value: 'Rs. ${balanceState.loanTotal}',
                        icon: Icons.account_balance_rounded,
                        iconColor: Colors.amberAccent,
                        labelColor: themeState.theme[appColors.accentColor]!,
                        valueColor: themeState.theme[appColors.cardColor]!,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Stat Tile ────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 6),
            AppText(
              label,
              color: labelColor,
              type: TextType.transactionDescription,
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppText(
          value,
          color: valueColor,
          type: TextType.transactionAmount,
        ),
      ],
    );
  }
}

// ── Vertical Divider ─────────────────────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {

  ThemeState themeState;
  _VerticalDivider({
    required this.themeState
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: themeState.theme[appColors.cardColor],
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/services/profile_photo_service.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';
import '../../../viewModel/bloc/total_balance/total_balance_bloc.dart';

class ProfileDataHeader extends StatelessWidget {
  const ProfileDataHeader({super.key});

  Future<void> _pickCustomRange(
    BuildContext context,
    TotalBalanceBloc totalBalanceBloc,
    TotalBalanceState state,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: state.customRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      totalBalanceBloc.add(
        ChangeDateFilter(
          filterType: DateFilterType.customRange,
          customRange: picked,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final primaryColor = themeState.theme[appColors.primaryColor]!;
        final accentColor = themeState.theme[appColors.accentColor]!;

        return BlocBuilder<TotalBalanceBloc, TotalBalanceState>(
          builder: (context, balanceState) {
            final totalBalanceBloc = context.read<TotalBalanceBloc>();

            return Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(
                isWide ? 32 : 16,
                14,
                isWide ? 32 : 16,
                12,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 28 : 20,
                vertical: isWide ? 24 : 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    Color.lerp(primaryColor, const Color(0xFF7C3AED), 0.6) ?? primaryColor,
                    Color.lerp(primaryColor, accentColor, 0.25) ?? primaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.38),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: User Avatar & Filter Selector
                  Row(
                    children: [
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final name = authState.userModel.name;
                          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

                          return ValueListenableBuilder<String?>(
                            valueListenable: ProfilePhotoService.photoNotifier,
                            builder: (context, photoPath, _) {
                              final hasPhoto = photoPath != null &&
                                  photoPath.isNotEmpty &&
                                  File(photoPath).existsSync();

                              return Container(
                                padding: const EdgeInsets.all(2.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  backgroundImage:
                                      hasPhoto ? FileImage(File(photoPath)) : null,
                                  child: !hasPhoto
                                      ? Text(
                                          initial,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Balance (Overall)',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Rs. ${balanceState.total.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              balanceState.filterLabel,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Filter Buttons (This Month, Custom Range, All Time)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _DateFilterChip(
                          label: 'This Month',
                          icon: Icons.calendar_month_rounded,
                          isSelected: balanceState.dateFilterType == DateFilterType.thisMonth,
                          onTap: () {
                            totalBalanceBloc.add(
                              const ChangeDateFilter(
                                filterType: DateFilterType.thisMonth,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: balanceState.dateFilterType == DateFilterType.customRange &&
                                  balanceState.customRange != null
                              ? '${balanceState.customRange!.start.day}/${balanceState.customRange!.start.month} - ${balanceState.customRange!.end.day}/${balanceState.customRange!.end.month}'
                              : 'Custom Range',
                          icon: Icons.date_range_rounded,
                          isSelected: balanceState.dateFilterType == DateFilterType.customRange,
                          onTap: () => _pickCustomRange(
                            context,
                            totalBalanceBloc,
                            balanceState,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DateFilterChip(
                          label: 'All Time',
                          icon: Icons.all_inclusive_rounded,
                          isSelected: balanceState.dateFilterType == DateFilterType.allTime,
                          onTap: () {
                            totalBalanceBloc.add(
                              const ChangeDateFilter(
                                filterType: DateFilterType.allTime,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                  const SizedBox(height: 14),

                  // Three Stat Tiles: Income (filtered), Expenses (filtered), Loans (overall)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Income',
                          value: 'Rs. ${balanceState.incomeTotal.toStringAsFixed(0)}',
                          icon: Icons.arrow_downward_rounded,
                          iconColor: const Color(0xFF34D399),
                        ),
                      ),
                      Container(
                        height: 34,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      Expanded(
                        child: _StatTile(
                          label: 'Expenses',
                          value: 'Rs. ${balanceState.expenseTotal.toStringAsFixed(0)}',
                          icon: Icons.arrow_upward_rounded,
                          iconColor: const Color(0xFFFB7185),
                        ),
                      ),
                      Container(
                        height: 34,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      Expanded(
                        child: _StatTile(
                          label: 'Loans',
                          value: 'Rs. ${balanceState.loanTotal.abs().toStringAsFixed(0)}',
                          icon: Icons.handshake_outlined,
                          iconColor: const Color(0xFFFBBF24),
                        ),
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

class _DateFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.28),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
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
                color: iconColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 12),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
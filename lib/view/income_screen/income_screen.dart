import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/viewModel/bloc/income/income_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../config/enum/enum.dart';
import '../home/header/profile_data_header.dart';
import 'dialog/add_income_dialog.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late IncomeBloc _incomeBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _incomeBloc = IncomeBloc();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _incomeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => _incomeBloc..add(GetIncome()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final incomeColor = themeState.theme[appColors.incomeColor]!;
          final cardColor = themeState.theme[appColors.cardColor]!;
          final textPrimary = themeState.theme[appColors.textPrimaryColor]!;
          final textSecondary = themeState.theme[appColors.textSecondaryColor]!;
          final isDark = themeState.isDark;

          return Scaffold(
            backgroundColor: themeState.theme[appColors.appBGColor],
            body: Stack(
              children: [
                BlocBuilder<IncomeBloc, IncomeState>(
                  builder: (context, incomestate) {
                    if (incomestate.incomeStatus == IncomeStatus.loading) {
                      return Center(
                        child: CircularProgressIndicator(color: incomeColor),
                      );
                    }
                    if (incomestate.incomeStatus == IncomeStatus.failure) {
                      return Center(
                        child: Text(
                          incomestate.message.toString(),
                          style: TextStyle(color: textPrimary),
                        ),
                      );
                    }

                    final items = incomestate.filteredIncomeModel.isEmpty
                        ? incomestate.incomeModel
                        : incomestate.filteredIncomeModel;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Top Balance & Savings Card
                        const SliverToBoxAdapter(
                          child: ProfileDataHeader(),
                        ),

                        // Search Bar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.25)
                                        : Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              child: TextFormField(
                                controller: _searchController,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search by source...',
                                  hintStyle: TextStyle(
                                    color: textSecondary.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: incomeColor,
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            context.read<IncomeBloc>().add(SearchItem(''));
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  fillColor: Colors.transparent,
                                ),
                                onChanged: (filterKey) {
                                  setState(() {});
                                  context.read<IncomeBloc>().add(SearchItem(filterKey));
                                },
                              ),
                            ),
                          ),
                        ),

                        // Date Filter Chips
                        SliverToBoxAdapter(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Row(
                              children: [
                                _filterChip(themeState, context, 'All', DateFilter.all, incomestate),
                                _filterChip(themeState, context, '7 Days', DateFilter.sevenDays, incomestate),
                                _filterChip(themeState, context, '1 Month', DateFilter.oneMonth, incomestate),
                                _filterChip(themeState, context, '3 Months', DateFilter.threeMonths, incomestate),
                                _filterChip(themeState, context, '1 Year', DateFilter.oneYear, incomestate),
                              ],
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 6),
                        ),

                        // Empty State or List items
                        if (incomestate.incomeModel.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      size: 64,
                                      color: textSecondary.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 12),
                                    AppText(
                                      'No income records found!',
                                      color: textSecondary,
                                      type: TextType.screenTitles,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (incomestate.searchMessage.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Center(
                                child: Text(
                                  incomestate.searchMessage,
                                  style: TextStyle(color: textSecondary),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 6,
                              bottom: screenHeight * 0.12,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = items[index];
                                  final hour = item.date_time!.hour.toString().padLeft(2, '0');
                                  final minute = item.date_time!.minute.toString().padLeft(2, '0');
                                  final day = item.date_time!.day.toString().padLeft(2, '0');
                                  final month = item.date_time!.month.toString().padLeft(2, '0');
                                  final year = item.date_time!.year;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                                    child: Dismissible(
                                      key: Key(item.id),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        context.read<IncomeBloc>().add(DeleteIncome(item.id));
                                      },
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Colors.transparent, Color(0xFFEF4444)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.delete_sweep_rounded,
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.black.withValues(alpha: 0.25)
                                                  : Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withValues(alpha: 0.08)
                                                : Colors.black.withValues(alpha: 0.04),
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          leading: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: incomeColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              Icons.arrow_downward_rounded,
                                              color: incomeColor,
                                              size: 22,
                                            ),
                                          ),
                                          title: Text(
                                            item.source,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: textPrimary,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 13,
                                                color: textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$day/$month/$year • $hour:$minute',
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: Text(
                                            '+Rs. ${item.amount}',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: incomeColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: items.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                // Floating Glassmorphism Add Income Button
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GlassActionButton(
                      text: 'Add Income',
                      icon: Icons.add_rounded,
                      accentColor: incomeColor,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AddIncomeDialog(
                              themeState: themeState,
                              incomeBloc: context.read<IncomeBloc>(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(
    ThemeState themeState,
    BuildContext context,
    String label,
    DateFilter filter,
    IncomeState state,
  ) {
    final isSelected = state.selectedFilter == filter;
    final incomeColor = themeState.theme[appColors.incomeColor]!;
    final cardColor = themeState.theme[appColors.cardColor]!;
    final textSecondary = themeState.theme[appColors.textSecondaryColor]!;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<IncomeBloc>().add(FilterByDate(filter));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? incomeColor : cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? incomeColor
                    : themeState.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: incomeColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

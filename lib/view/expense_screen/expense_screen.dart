import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/viewModel/bloc/expense/expense_bloc.dart';

import '../../config/color/colors.dart';
import '../../config/components/button.dart';
import '../../config/components/textwidgets.dart';
import '../../config/enum/enum.dart';
import '../../viewModel/bloc/theme/theme_bloc.dart';
import '../home/header/profile_data_header.dart';
import 'dialog/add_expense_dialog.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late ExpenseBloc _expenseBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _expenseBloc = ExpenseBloc();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _expenseBloc.close();
    super.dispose();
  }

  IconData _getExpenseIcon(expenseType type) {
    switch (type) {
      case expenseType.Food:
        return Icons.restaurant_rounded;
      case expenseType.Stationery:
        return Icons.edit_note_rounded;
      case expenseType.Petrol:
        return Icons.local_gas_station_rounded;
      case expenseType.Grocery:
        return Icons.shopping_basket_rounded;
      case expenseType.Vegetables:
        return Icons.eco_rounded;
      case expenseType.Vehicle:
        return Icons.directions_car_rounded;
      case expenseType.Others:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => _expenseBloc..add(GetExpense()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final expenseColor = themeState.theme[appColors.expenseColor]!;
          final cardColor = themeState.theme[appColors.cardColor]!;
          final textPrimary = themeState.theme[appColors.textPrimaryColor]!;
          final textSecondary = themeState.theme[appColors.textSecondaryColor]!;
          final isDark = themeState.isDark;

          return Scaffold(
            backgroundColor: themeState.theme[appColors.appBGColor],
            body: Stack(
              children: [
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, expensestate) {
                    if (expensestate.expenseStatus == ExpenseStatus.loading) {
                      return Center(
                        child: CircularProgressIndicator(color: expenseColor),
                      );
                    }
                    if (expensestate.expenseStatus == ExpenseStatus.failure) {
                      return Center(
                        child: Text(
                          expensestate.message.toString(),
                          style: TextStyle(color: textPrimary),
                        ),
                      );
                    }

                    final items = expensestate.filteredExpenseModel.isEmpty
                        ? expensestate.expenseModel
                        : expensestate.filteredExpenseModel;

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
                                  hintText: 'Search expenses...',
                                  hintStyle: TextStyle(
                                    color: textSecondary.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: expenseColor,
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            context.read<ExpenseBloc>().add(SearchItem(''));
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
                                  context.read<ExpenseBloc>().add(SearchItem(filterKey));
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
                                _filterChip(themeState, context, 'All', DateFilter.all, expensestate),
                                _filterChip(themeState, context, '7 Days', DateFilter.sevenDays, expensestate),
                                _filterChip(themeState, context, '1 Month', DateFilter.oneMonth, expensestate),
                                _filterChip(themeState, context, '3 Months', DateFilter.threeMonths, expensestate),
                                _filterChip(themeState, context, '1 Year', DateFilter.oneYear, expensestate),
                              ],
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 6),
                        ),

                        // Empty State or List items
                        if (expensestate.expenseModel.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: textSecondary.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 12),
                                    AppText(
                                      'No expenses recorded yet!',
                                      color: textSecondary,
                                      type: TextType.screenTitles,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (expensestate.searchMessage.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Center(
                                child: Text(
                                  expensestate.searchMessage,
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
                                        context.read<ExpenseBloc>().add(DeleteExpense(item.id));
                                      },
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.delete_outline_rounded, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withValues(alpha: 0.08)
                                                : Colors.black.withValues(alpha: 0.04),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDark
                                                  ? Colors.black.withValues(alpha: 0.25)
                                                  : Colors.black.withValues(alpha: 0.03),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
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
                                              color: expenseColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              _getExpenseIcon(item.type),
                                              color: expenseColor,
                                              size: 22,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  item.reason.isNotEmpty ? item.reason : item.type.name,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: textPrimary,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: expenseColor.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  item.type.name,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: expenseColor,
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time_rounded,
                                                  size: 12,
                                                  color: textSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$day/$month/$year • $hour:$minute',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: textSecondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          trailing: Text(
                                            '-Rs. ${item.amount}',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: expenseColor,
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

                // Floating Glassmorphism Add Expense Button
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GlassActionButton(
                      text: 'Add Expense',
                      icon: Icons.add_rounded,
                      accentColor: expenseColor,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AddExpenseDialog(
                              themeState: themeState,
                              expenseBloc: context.read<ExpenseBloc>(),
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
    ExpenseState state,
  ) {
    final isSelected = state.selectedFilter == filter;
    final expenseColor = themeState.theme[appColors.expenseColor]!;
    final cardColor = themeState.theme[appColors.cardColor]!;
    final textSecondary = themeState.theme[appColors.textSecondaryColor]!;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<ExpenseBloc>().add(FilterByDate(filter));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? expenseColor : cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? expenseColor
                    : themeState.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: expenseColor.withValues(alpha: 0.35),
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

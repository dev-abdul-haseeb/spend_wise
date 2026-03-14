import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/viewModel/bloc/expense/expense_bloc.dart';

import '../../config/color/colors.dart';
import '../../config/components/button.dart';
import '../../config/components/textwidgets.dart';
import '../../config/enum/enum.dart';
import '../../config/list_tile/list_tile.dart';
import '../../viewModel/bloc/theme/theme_bloc.dart';
import 'dialog/add_expense_dialog.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late ExpenseBloc _expenseBloc;

  @override
  void initState() {
    super.initState();
    _expenseBloc = ExpenseBloc();
  }

  @override
  void dispose() {
    _expenseBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) {
        return _expenseBloc..add(GetExpense());
      },
      child: BlocBuilder<ThemeBloc,ThemeState>(
          builder: (context, themeState) {
            return Scaffold(
              backgroundColor: themeState.theme[appColors.appBGColor],
              body: Center(
                child: Stack(
                  children: [
                    BlocBuilder<ExpenseBloc, ExpenseState>(
                        builder: (context, expensestate) {
                          switch(expensestate.expenseStatus) {
                            case(ExpenseStatus.loading):
                              return CircularProgressIndicator();
                            case(ExpenseStatus.failure):
                              return Center(child: Text(expensestate.message.toString()));
                            case(ExpenseStatus.success):
                              return expensestate.expenseModel.length == 0
                                  ? Center(
                                child: AppText(
                                  'No expenses found!',
                                  color: themeState.theme[appColors.textPrimaryColor]!,
                                  type: TextType.screenTitles,
                                ),
                              )
                                  : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      style: TextStyle (
                                          color: themeState.theme[appColors.accentColor]
                                      ),
                                      decoration: InputDecoration(
                                        hint: Text('Search by type'),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)
                                          ),
                                        ),
                                      ),
                                      onChanged: (filterKey) {
                                        context.read<ExpenseBloc>().add(SearchItem(filterKey));
                                      },
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

                                  Expanded(
                                    child: expensestate.searchMessage.isNotEmpty
                                        ? Center(child: Text(expensestate.searchMessage))
                                        : ListView.builder(
                                        padding: EdgeInsets.only(bottom: screenHeight * 0.09),
                                        itemCount: expensestate.filteredExpenseModel.isEmpty ? expensestate.expenseModel.length  : expensestate.filteredExpenseModel.length,
                                        itemBuilder: (context, index) {
                                          final item = expensestate.filteredExpenseModel.isEmpty ? expensestate.expenseModel[index] : expensestate.filteredExpenseModel[index];
                                          final hour = item.date_time!.hour;
                                          final minute = item.date_time!.minute;
                                          final second = item.date_time!.second;
                                          final day = item.date_time!.day;
                                          final month = item.date_time!.month;
                                          final year = item.date_time!.year;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
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
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Icon(Icons.delete, color: Colors.white),
                                              ),
                                              child: ListTile(

                                                onTap: () {},
                                                splashColor: themeState.theme[appColors.accentColor],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                tileColor: themeState.theme[appColors.cardColor],
                                                leading: CircleAvatar(
                                                  backgroundColor: listTileColors[index % listTileColors.length].withOpacity(0.5),
                                                  child: AppText(
                                                    (index+1).toString(),
                                                    color: themeState.theme[appColors.textPrimaryColor]!,
                                                    type: TextType.transactionAmount,
                                                  ),
                                                ),
                                                title: AppText(
                                                  'Rs. ${item.amount}',
                                                  color: themeState.theme[appColors.textPrimaryColor]!,
                                                  align: TextAlign.left,
                                                  type: TextType.balanceAmount,
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Expense type badge
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: themeState.theme[appColors.accentColor]!.withOpacity(0.15),
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(
                                                          color: themeState.theme[appColors.accentColor]!.withOpacity(0.4),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: AppText(
                                                        item.type.name,  // enum name as string
                                                        color: themeState.theme[appColors.accentColor]!,
                                                        type: TextType.transactionDescription,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    // Reason
                                                    AppText(
                                                      item.reason.toString(),
                                                      color: themeState.theme[appColors.textSecondaryColor]!,
                                                      align: TextAlign.left,
                                                      type: TextType.transactionDescription,
                                                    ),
                                                  ],
                                                ),
                                                trailing: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '$hour:$minute:$second',
                                                      style: GoogleFonts.inter(
                                                          fontWeight: FontWeight.bold,
                                                          color: themeState.theme[appColors.textPrimaryColor]!
                                                      ),
                                                    ),
                                                    AppText(
                                                      '$day/$month/$year',
                                                      color: themeState.theme[appColors.textPrimaryColor]!,
                                                      type: TextType.transactionDescription,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                    ),
                                  ),
                                ],
                              );
                          }
                        }
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: screenHeight*0.02),
                        child: AppButton(
                          'Add expense',
                          bgcolor: themeState.theme[appColors.expenseColor]!,
                          color: themeState.theme[appColors.textPrimaryColor]!,
                          size: ButtonSize.large,
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
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  Widget _filterChip(ThemeState themeState, BuildContext context, String label, DateFilter filter, ExpenseState state) {
    final isSelected = state.selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: AppText(
          label,
          color: themeState.theme[appColors.primaryColor]!,
          type: TextType.buttons,
        ),
        selected: isSelected,
        onSelected: (_) {
          context.read<ExpenseBloc>().add(FilterByDate(filter));
        },
        selectedColor: themeState.theme[appColors.accentColor],
      ),
    );
  }
}

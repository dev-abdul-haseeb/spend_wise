import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/config/list_tile/list_tile.dart';
import 'package:spend_wise/viewModel/bloc/auth_state/auth_bloc.dart';
import 'package:spend_wise/viewModel/bloc/income/income_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../config/enum/enum.dart';
import 'dialog/add_income_dialog.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {

  late IncomeBloc _incomeBloc;

  @override
  void initState() {
    super.initState();
    _incomeBloc = IncomeBloc();
  }

  @override
  void dispose() {
    _incomeBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) {
        return _incomeBloc..add(GetIncome());
      },
      child: BlocBuilder<ThemeBloc,ThemeState>(
        builder: (context, themeState) {
          return Scaffold(
            backgroundColor: themeState.theme[appColors.appBGColor],
            body: Center(
              child: Stack(
                children: [
                  BlocBuilder<IncomeBloc, IncomeState>(
                      builder: (context, incomestate) {
                        switch(incomestate.incomeStatus) {
                          case(IncomeStatus.loading):
                            return Center(child: CircularProgressIndicator());
                          case(IncomeStatus.failure):
                            return Center(child: Text(incomestate.message.toString()));
                          case(IncomeStatus.success):
                            return incomestate.incomeModel.length == 0
                            ? Center(
                              child: AppText(
                                'No data found!',
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
                                      hint: Text('Search by source'),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)
                                        ),
                                      ),
                                    ),
                                    onChanged: (filterKey) {
                                      context.read<IncomeBloc>().add(SearchItem(filterKey));
                                    },
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

                                Expanded(
                                  child: incomestate.searchMessage.isNotEmpty
                                    ? Center(child: Text(incomestate.searchMessage))
                                    : ListView.builder(
                                      padding: EdgeInsets.only(bottom: screenHeight * 0.09),
                                      itemCount: incomestate.filteredIncomeModel.isEmpty ? incomestate.incomeModel.length : incomestate.filteredIncomeModel.length,
                                      itemBuilder: (context, index) {
                                        final item = incomestate.filteredIncomeModel.isEmpty ? incomestate.incomeModel[index] : incomestate.filteredIncomeModel[index];
                                        final hour = item.date_time!.hour.toString().padLeft(2, '0');
                                        final minute = item.date_time!.minute.toString().padLeft(2, '0');
                                        final second = item.date_time!.second.toString().padLeft(2, '0');
                                        final day = item.date_time!.day;
                                        final month = item.date_time!.month;
                                        final year = item.date_time!.year;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
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
                                              subtitle: AppText(
                                                item.source.toString(),
                                                color: themeState.theme[appColors.textSecondaryColor]!,
                                                align: TextAlign.left,
                                                type: TextType.transactionDescription,
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
                        'Add income',
                        bgcolor: themeState.theme[appColors.incomeColor]!,
                        color: themeState.theme[appColors.textPrimaryColor]!,
                        size: ButtonSize.large,
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
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _filterChip(ThemeState themeState,BuildContext context, String label, DateFilter filter, IncomeState state) {
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
          context.read<IncomeBloc>().add(FilterByDate(filter));
        },
        selectedColor: themeState.theme[appColors.accentColor],
      ),
    );
  }
}

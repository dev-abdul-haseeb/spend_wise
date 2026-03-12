import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/config/list_tile/list_tile.dart';
import 'package:spend_wise/viewModel/bloc/loan/loan_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../config/enum/enum.dart';
import 'dialog/add_loan_dialog.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {

  late LoanBloc _loanBloc;

  @override
  void initState() {
    super.initState();
    _loanBloc = LoanBloc();
  }

  @override
  void dispose() {
    _loanBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) {
        return _loanBloc..add(GetLoan());
      },
      child: BlocBuilder<ThemeBloc,ThemeState>(
          builder: (context, themeState) {
            return Scaffold(
              backgroundColor: themeState.theme[appColors.appBGColor],
              body: Center(
                child: Stack(
                  children: [
                    BlocBuilder<LoanBloc, LoanState>(
                        builder: (context, loanstate) {
                          switch(loanstate.loanStatus) {
                            case(LoanStatus.loading):
                              return CircularProgressIndicator();
                            case(LoanStatus.failure):
                              return Center(child: Text(loanstate.message.toString()));
                            case(LoanStatus.success):
                              return loanstate.loanModel.length == 0
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
                                        hint: Text('Search by person'),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (filterKey) {
                                        context.read<LoanBloc>().add(SearchItem(filterKey));
                                      },
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Row(
                                      children: [
                                        _filterChip(context, 'All', LoanStatusFilter.all, loanstate, themeState),
                                        _filterChip(context, 'Paid', LoanStatusFilter.paid, loanstate, themeState),
                                        _filterChip(context, 'Unpaid', LoanStatusFilter.unpaid, loanstate, themeState),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: loanstate.searchMessage.isNotEmpty
                                        ? Center(child: Text(loanstate.searchMessage))
                                        : ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: loanstate.filteredLoanModel.isEmpty ? loanstate.loanModel.length : loanstate.filteredLoanModel.length,
                                        itemBuilder: (context, index) {
                                          final item = loanstate.filteredLoanModel.isEmpty ? loanstate.loanModel[index] : loanstate.filteredLoanModel[index];
                                          final hour = item.date_time!.hour;
                                          final minute = item.date_time!.minute;
                                          final second = item.date_time!.second;
                                          final day = item.date_time!.day;
                                          final month = item.date_time!.month;
                                          final year = item.date_time!.year;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                            child: ListTile(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              tileColor: item.status == loanStatus.Paid
                                                  ? Colors.green.withOpacity(0.15)
                                                  : themeState.theme[appColors.cardColor],
                                              onTap: () {},
                                              splashColor: themeState.theme[appColors.accentColor],
                                              enabled: item.status == loanStatus.Paid ? false : true ,
                                              onLongPress: item.status == loanStatus.Paid
                                                  ? null
                                                  : () {
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) => AlertDialog(
                                                    title: const Text('Mark as Paid'),
                                                    content: Text('Mark loan for ${item.person_name} as paid?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(dialogContext).pop(),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          context.read<LoanBloc>().add(PayLoan(item.id));
                                                          Navigator.of(dialogContext).pop();
                                                        },
                                                        child: const Text(
                                                          'Confirm',
                                                          style: TextStyle(color: Colors.green),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },

                                              leading: CircleAvatar(
                                                backgroundColor: listTileColors[index].withOpacity(0.5),
                                                child: AppText(
                                                  (index+1).toString(),
                                                  color: themeState.theme[appColors.textPrimaryColor]!,
                                                  type: TextType.transactionAmount,
                                                ),
                                              ),
                                              subtitle: AppText(
                                                item.person_name.toString(),
                                                color: themeState.theme[appColors.textSecondaryColor]!,
                                                align: TextAlign.left,
                                                type: TextType.transactionDescription,
                                              ),
                                              title: AppText(
                                                'Rs. ${item.amount}',
                                                color: themeState.theme[appColors.textPrimaryColor]!,
                                                align: TextAlign.left,
                                                type: TextType.balanceAmount,
                                              ),
                                              trailing: Column(
                                                children: [
                                                  AppText(
                                                    '$hour:$minute:$second',
                                                    color: themeState.theme[appColors.textPrimaryColor]!,
                                                    type: TextType.transactionDescription,
                                                  ),
                                                  AppText(
                                                    '$day/$month/$year',
                                                    color: themeState.theme[appColors.textPrimaryColor]!,
                                                    type: TextType.transactionDescription,
                                                  ),
                                                ],
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: screenWidth*0.4,
                              child: AppButton(
                                'Give Loan',
                                bgcolor: themeState.theme[appColors.accentColor]!,
                                color: themeState.theme[appColors.textPrimaryColor]!,
                                size: ButtonSize.small,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AddLoanDialog(
                                        themeState: themeState,
                                        loanBloc: context.read<LoanBloc>(),
                                        title: 'Give loan',
                                        take: false
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: screenWidth*0.1,),
                            SizedBox(
                              width: screenWidth*0.4,
                              child: AppButton(
                                'Take loan',
                                bgcolor: themeState.theme[appColors.accentColor]!,
                                color: themeState.theme[appColors.textPrimaryColor]!,
                                size: ButtonSize.small,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AddLoanDialog(
                                        themeState: themeState,
                                        loanBloc: context.read<LoanBloc>(),
                                        title: 'Take loan',
                                        take: true
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
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
  Widget _filterChip(BuildContext context, String label, LoanStatusFilter filter, LoanState state, ThemeState themeState) {
    final isSelected = state.selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? themeState.theme[appColors.textPrimaryColor]
                : themeState.theme[appColors.textSecondaryColor],
          ),
        ),
        selected: isSelected,
        onSelected: (_) => context.read<LoanBloc>().add(FilterbyStatus(filter)),
        selectedColor: themeState.theme[appColors.accentColor]!.withOpacity(0.4),
        backgroundColor: themeState.theme[appColors.cardColor],
      ),
    );
  }
}

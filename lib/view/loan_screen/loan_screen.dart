import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loanBloc = LoanBloc();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loanBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider.value(
      value: _loanBloc..add(GetLoan()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final primary = themeState.theme[appColors.primaryColor]!;
          final cardColor = themeState.theme[appColors.cardColor]!;
          final textPrimary = themeState.theme[appColors.textPrimaryColor]!;
          final textSecondary = themeState.theme[appColors.textSecondaryColor]!;
          final accent = themeState.theme[appColors.accentColor]!;

          return Scaffold(
            backgroundColor: themeState.theme[appColors.appBGColor],
            body: Center(
              child: Stack(
                children: [
                  BlocBuilder<LoanBloc, LoanState>(
                    builder: (context, loanstate) {
                      switch (loanstate.loanStatus) {
                        case LoanStatus.loading:
                          return const Center(child: CircularProgressIndicator());
                        case LoanStatus.failure:
                          return Center(child: Text(loanstate.message));
                        case LoanStatus.success:
                          if (loanstate.loanModel.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.handshake_outlined, size: 64, color: textSecondary.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  AppText(
                                    'No loans recorded yet!',
                                    color: textPrimary,
                                    type: TextType.screenTitles,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Use Give Loan or Take Loan below to add one',
                                    style: TextStyle(color: textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }

                          final loansToDisplay = loanstate.displayedLoans;

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(color: textPrimary, fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: 'Search by person or reason...',
                                      hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                                      prefixIcon: Icon(Icons.search_rounded, color: primary),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear_rounded, size: 18),
                                              onPressed: () {
                                                _searchController.clear();
                                                context.read<LoanBloc>().add(SearchItem(''));
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    ),
                                    onChanged: (filterKey) {
                                      context.read<LoanBloc>().add(SearchItem(filterKey));
                                    },
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                                child: Row(
                                  children: [
                                    _filterChip(context, 'All', LoanStatusFilter.all, loanstate, themeState),
                                    _filterChip(context, 'Paid', LoanStatusFilter.paid, loanstate, themeState),
                                    _filterChip(context, 'Unpaid', LoanStatusFilter.unpaid, loanstate, themeState),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: loanstate.searchMessage.isNotEmpty || loansToDisplay.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.search_off_rounded, size: 48, color: textSecondary),
                                            const SizedBox(height: 8),
                                            Text(
                                              loanstate.searchMessage.isNotEmpty
                                                  ? loanstate.searchMessage
                                                  : 'No matching loans found',
                                              style: TextStyle(color: textSecondary, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.fromLTRB(12, 6, 12, screenHeight * 0.12),
                                        itemCount: loansToDisplay.length,
                                        itemBuilder: (context, index) {
                                          final item = loansToDisplay[index];
                                          final dateTime = item.date_time ?? DateTime.now();
                                          final isPaid = item.status == loanStatus.Paid;
                                          final isToGive = item.amount > 0;

                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            color: cardColor,
                                            elevation: 2,
                                            shadowColor: Colors.black.withValues(alpha: 0.05),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              side: BorderSide(
                                                color: isPaid
                                                    ? Colors.green.withValues(alpha: 0.3)
                                                    : primary.withValues(alpha: 0.1),
                                              ),
                                            ),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(16),
                                              onLongPress: isPaid
                                                  ? null
                                                  : () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (dialogContext) => AlertDialog(
                                                          backgroundColor: cardColor,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(18),
                                                          ),
                                                          title: const Text('Mark as Paid'),
                                                          content: Text('Mark loan for "${item.person_name}" as paid?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(dialogContext).pop(),
                                                              child: Text('Cancel', style: TextStyle(color: textSecondary)),
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.green,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                              ),
                                                              onPressed: () {
                                                                _loanBloc.add(PayLoan(item.id));
                                                                Navigator.of(dialogContext).pop();
                                                              },
                                                              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                              child: Padding(
                                                padding: const EdgeInsets.all(14.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 44,
                                                      height: 44,
                                                      decoration: BoxDecoration(
                                                        color: (isPaid ? Colors.green : (isToGive ? accent : primary))
                                                            .withValues(alpha: 0.15),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        isPaid
                                                            ? Icons.check_circle_rounded
                                                            : (isToGive ? Icons.call_made_rounded : Icons.call_received_rounded),
                                                        color: isPaid ? Colors.green : (isToGive ? accent : primary),
                                                        size: 22,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  item.person_name,
                                                                  style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: textPrimary,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                decoration: BoxDecoration(
                                                                  color: (isPaid ? Colors.green : (isToGive ? Colors.blue : Colors.orange))
                                                                      .withValues(alpha: 0.15),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Text(
                                                                  isPaid ? 'PAID' : (isToGive ? 'TO GIVE' : 'TO TAKE'),
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: isPaid ? Colors.green : (isToGive ? Colors.blue : Colors.orange),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (item.reason.trim().isNotEmpty) ...[
                                                            const SizedBox(height: 3),
                                                            Text(
                                                              item.reason,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: textSecondary,
                                                                fontStyle: FontStyle.italic,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            '${dateTime.day}/${dateTime.month}/${dateTime.year} • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: textSecondary.withValues(alpha: 0.8),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      'Rs. ${item.amount.abs().toStringAsFixed(0)}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: isPaid ? Colors.green : (isToGive ? accent : primary),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, screenHeight * 0.02),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            themeState.theme[appColors.appBGColor]!.withValues(alpha: 0.0),
                            themeState.theme[appColors.appBGColor]!,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              'Give Loan',
                              bgcolor: accent,
                              color: themeState.theme[appColors.textSecondaryColor]!,
                              type: ButtonType.primary,
                              size: ButtonSize.medium,
                              leadingIcon: Icons.arrow_upward_rounded,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AddLoanDialog(
                                      themeState: themeState,
                                      loanBloc: _loanBloc,
                                      title: 'Give Loan',
                                      take: false,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              'Take Loan',
                              bgcolor: primary,
                              color: themeState.theme[appColors.textSecondaryColor]!,
                              type: ButtonType.primary,
                              size: ButtonSize.medium,
                              leadingIcon: Icons.arrow_downward_rounded,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AddLoanDialog(
                                      themeState: themeState,
                                      loanBloc: _loanBloc,
                                      title: 'Take Loan',
                                      take: true,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    LoanStatusFilter filter,
    LoanState state,
    ThemeState themeState,
  ) {
    final isSelected = state.selectedFilter == filter;
    final primary = themeState.theme[appColors.primaryColor]!;
    final cardColor = themeState.theme[appColors.cardColor]!;
    final textSecondary = themeState.theme[appColors.textSecondaryColor]!;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : textSecondary,
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => context.read<LoanBloc>().add(FilterbyStatus(filter)),
        selectedColor: primary,
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? primary : textSecondary.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

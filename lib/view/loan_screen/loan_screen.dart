import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/button.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/viewModel/bloc/loan/loan_bloc.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../config/enum/enum.dart';
import '../home/header/profile_data_header.dart';
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
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider.value(
      value: _loanBloc..add(GetLoan()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final primary = themeState.theme[appColors.primaryColor]!;
          final cardColor = themeState.theme[appColors.cardColor]!;
          final textPrimary = themeState.theme[appColors.textPrimaryColor]!;
          final textSecondary = themeState.theme[appColors.textSecondaryColor]!;
          final accent = themeState.theme[appColors.accentColor]!;
          final isDark = themeState.isDark;

          return Scaffold(
            backgroundColor: themeState.theme[appColors.appBGColor],
            body: Stack(
              children: [
                BlocBuilder<LoanBloc, LoanState>(
                  builder: (context, loanstate) {
                    if (loanstate.loanStatus == LoanStatus.loading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: primary,
                        ),
                      );
                    }
                    if (loanstate.loanStatus == LoanStatus.failure) {
                      return Center(
                        child: Text(
                          loanstate.message,
                          style: TextStyle(color: textPrimary),
                        ),
                      );
                    }

                    final loansToDisplay = loanstate.displayedLoans;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Top Balance & Savings Header
                        const SliverToBoxAdapter(
                          child: ProfileDataHeader(),
                        ),

                        // Search bar
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
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search by person or reason...',
                                  hintStyle: TextStyle(
                                    color: textSecondary.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: primary,
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            context.read<LoanBloc>().add(SearchItem(''));
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
                                  context.read<LoanBloc>().add(SearchItem(filterKey));
                                },
                              ),
                            ),
                          ),
                        ),

                        // Filter Chips: All, Paid, Unpaid, To Give, To Take
                        SliverToBoxAdapter(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                            child: Row(
                              children: [
                                _filterChip(context, 'All', LoanStatusFilter.all, loanstate, themeState),
                                _filterChip(context, 'Paid', LoanStatusFilter.paid, loanstate, themeState),
                                _filterChip(context, 'Unpaid', LoanStatusFilter.unpaid, loanstate, themeState),
                                _filterChip(context, 'To Give', LoanStatusFilter.toGive, loanstate, themeState),
                                _filterChip(context, 'To Take', LoanStatusFilter.toTake, loanstate, themeState),
                              ],
                            ),
                          ),
                        ),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 6),
                        ),

                        // Empty State or List
                        if (loanstate.loanModel.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.handshake_outlined,
                                      size: 64,
                                      color: textSecondary.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 12),
                                    AppText(
                                      'No loans recorded yet!',
                                      color: textPrimary,
                                      type: TextType.screenTitles,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Use Give Loan or Take Loan below to add one',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (loanstate.searchMessage.isNotEmpty || loansToDisplay.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 54,
                                      color: textSecondary.withValues(alpha: 0.4),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      loanstate.searchMessage.isNotEmpty
                                          ? loanstate.searchMessage
                                          : 'No matching loans found',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: textSecondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(16, 6, 16, screenHeight * 0.12),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = loansToDisplay[index];
                                  final dateTime = item.date_time ?? DateTime.now();
                                  final isPaid = item.status == loanStatus.Paid;
                                  final isToGive = item.amount < 0;
                                  final itemColor = isPaid
                                      ? const Color(0xFF10B981)
                                      : (isToGive ? accent : primary);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isPaid
                                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                            : isDark
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
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onLongPress: isPaid
                                          ? null
                                          : () {
                                              showDialog(
                                                context: context,
                                                builder: (dialogContext) => AlertDialog(
                                                  backgroundColor: cardColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  title: Text(
                                                    'Mark as Paid',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Mark loan for "${item.person_name}" as settled and paid?',
                                                    style: GoogleFonts.plusJakartaSans(),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(color: textSecondary),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: const Color(0xFF10B981),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        _loanBloc.add(PayLoan(item.id));
                                                        Navigator.of(dialogContext).pop();
                                                      },
                                                      child: const Text(
                                                        'Confirm',
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
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
                                                color: itemColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Icon(
                                                isPaid
                                                    ? Icons.check_circle_rounded
                                                    : (isToGive
                                                        ? Icons.call_made_rounded
                                                        : Icons.call_received_rounded),
                                                color: itemColor,
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
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w700,
                                                            color: textPrimary,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: itemColor.withValues(alpha: 0.15),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Text(
                                                          isPaid
                                                              ? 'PAID'
                                                              : (isToGive ? 'TO GIVE' : 'TO TAKE'),
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w800,
                                                            color: itemColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (item.reason.isNotEmpty) ...[
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      item.reason,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12.5,
                                                        color: textSecondary,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time_rounded,
                                                        size: 12,
                                                        color: textSecondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}',
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 11.5,
                                                          color: textSecondary,
                                                        ),
                                                      ),
                                                      if (!isPaid) ...[
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '• Long-press to mark paid',
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 11,
                                                            color: textSecondary.withValues(alpha: 0.7),
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Rs. ${item.amount.abs().toStringAsFixed(0)}',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: itemColor,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: loansToDisplay.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                // Floating Dual Glassmorphism Buttons: Give Loan & Take Loan
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassActionButton(
                          text: 'Give Loan',
                          icon: Icons.arrow_outward_rounded,
                          accentColor: accent,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return AddLoanDialog(
                                  loanBloc: _loanBloc,
                                  themeState: themeState,
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
                        child: GlassActionButton(
                          text: 'Take Loan',
                          icon: Icons.arrow_downward_rounded,
                          accentColor: primary,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return AddLoanDialog(
                                  loanBloc: _loanBloc,
                                  themeState: themeState,
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
              ],
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<LoanBloc>().add(FilterbyStatus(filter));
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? primary : cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? primary
                    : themeState.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.35),
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

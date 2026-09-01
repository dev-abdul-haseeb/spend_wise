import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../../model/loan/loan_model.dart';
import '../../../viewModel/bloc/loan/loan_bloc.dart';

class AddLoanDialog extends StatefulWidget {
  final LoanBloc loanBloc;
  final ThemeState themeState;
  final String title;
  final bool take;

  const AddLoanDialog({
    super.key,
    required this.loanBloc,
    required this.themeState,
    required this.title,
    required this.take,
  });

  @override
  State<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<AddLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    _selectedDate = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedDate?.hour ?? now.hour,
            _selectedDate?.minute ?? now.minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_amountController.text.trim());
      final newLoan = LoanModel(
        amount: widget.take ? amount : (-1 * amount),
        person_name: _sourceController.text.trim(),
        reason: _reasonController.text.trim(),
        date_time: _selectedDate,
      );
      widget.loanBloc.add(AddLoan(loan: newLoan));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.themeState.theme[appColors.cardColor]!;
    final primaryColor = widget.themeState.theme[appColors.primaryColor]!;
    final accentColor = widget.themeState.theme[appColors.accentColor]!;
    final textPrimary = widget.themeState.theme[appColors.textPrimaryColor]!;
    final textSecondary = widget.themeState.theme[appColors.textSecondaryColor]!;
    final isDark = widget.themeState.isDark;
    final loanAccent = widget.take ? primaryColor : accentColor;

    final hour = (_selectedDate ?? DateTime.now()).hour.toString().padLeft(2, '0');
    final minute = (_selectedDate ?? DateTime.now()).minute.toString().padLeft(2, '0');
    final day = (_selectedDate ?? DateTime.now()).day.toString().padLeft(2, '0');
    final month = (_selectedDate ?? DateTime.now()).month.toString().padLeft(2, '0');
    final year = (_selectedDate ?? DateTime.now()).year;

    return Dialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: loanAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        widget.take ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: loanAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            widget.take ? 'Record money borrowed' : 'Record money lent',
                            style: GoogleFonts.plusJakartaSans(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: textSecondary),
                    prefixText: 'Rs. ${widget.take ? '+' : '-'} ',
                    prefixStyle: TextStyle(
                      color: loanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    prefixIcon: Icon(Icons.attach_money_rounded, color: loanAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter an amount';
                    if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Person name field
                TextFormField(
                  controller: _sourceController,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Person Name',
                    labelStyle: TextStyle(color: textSecondary),
                    prefixIcon: Icon(Icons.person_outline_rounded, color: loanAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter person name';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Reason / Note field
                TextFormField(
                  controller: _reasonController,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Reason / Note (Optional)',
                    labelStyle: TextStyle(color: textSecondary),
                    hintText: 'e.g. Dinner bill, Emergency, etc.',
                    prefixIcon: Icon(Icons.note_alt_outlined, color: loanAccent),
                  ),
                ),

                const SizedBox(height: 14),

                // Date Time Selector Tile
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: loanAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$day/$month/$year  at  $hour:$minute',
                            style: GoogleFonts.plusJakartaSans(
                              color: textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.edit_calendar_rounded, size: 16, color: textSecondary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.plusJakartaSans(
                            color: textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: loanAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: loanAccent.withValues(alpha: 0.4),
                        ),
                        onPressed: _submit,
                        child: Text(
                          widget.title,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

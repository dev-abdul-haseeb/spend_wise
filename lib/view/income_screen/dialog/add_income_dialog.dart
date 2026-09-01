import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../../model/income/income_model.dart';
import '../../../viewModel/bloc/income/income_bloc.dart';

class AddIncomeDialog extends StatefulWidget {
  final IncomeBloc incomeBloc;
  final ThemeState themeState;

  const AddIncomeDialog({
    super.key,
    required this.incomeBloc,
    required this.themeState,
  });

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
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
      final newIncome = IncomeModel(
        amount: double.parse(_amountController.text.trim()),
        source: _sourceController.text.trim(),
        date_time: _selectedDate,
      );
      widget.incomeBloc.add(AddIncome(income: newIncome));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.themeState.theme[appColors.cardColor]!;
    final incomeColor = widget.themeState.theme[appColors.incomeColor]!;
    final textPrimary = widget.themeState.theme[appColors.textPrimaryColor]!;
    final textSecondary = widget.themeState.theme[appColors.textSecondaryColor]!;
    final isDark = widget.themeState.isDark;

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
                      color: incomeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      color: incomeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Income',
                          style: GoogleFonts.plusJakartaSans(
                            color: textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Log your incoming revenue',
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
                  prefixText: 'Rs. ',
                  prefixStyle: TextStyle(
                    color: incomeColor,
                    fontWeight: FontWeight.bold,
                  ),
                  prefixIcon: Icon(Icons.attach_money_rounded, color: incomeColor),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter an amount';
                  if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Source field
              TextFormField(
                controller: _sourceController,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Source (e.g. Salary, Freelance)',
                  labelStyle: TextStyle(color: textSecondary),
                  prefixIcon: Icon(Icons.business_center_outlined, color: incomeColor),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter a source';
                  return null;
                },
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
                      Icon(Icons.calendar_today_rounded, size: 18, color: incomeColor),
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
                        backgroundColor: incomeColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: incomeColor.withValues(alpha: 0.4),
                      ),
                      onPressed: _submit,
                      child: Text(
                        'Add Income',
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
    );
  }
}

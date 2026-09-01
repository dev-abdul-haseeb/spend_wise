import 'package:flutter/material.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../../model/loan/loan_model.dart';
import '../../../viewModel/bloc/loan/loan_bloc.dart';

class AddLoanDialog extends StatefulWidget {
  final LoanBloc loanBloc;
  final ThemeState themeState;
  final String title;
  final bool take;

  const AddLoanDialog({required this.loanBloc, required this.themeState, required this.title, required this.take});

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

    return AlertDialog(
      backgroundColor: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: AppText(
        widget.title,
        color: primaryColor,
        type: TextType.screenTitles,
      ),
      content: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: widget.themeState.isDark ? accentColor : textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: accentColor),
                  prefixText: 'Rs. ${widget.take ? '+' : '-'} ',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter an amount';
                  if (double.tryParse(value.trim()) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _sourceController,
                style: TextStyle(
                  color: widget.themeState.isDark ? accentColor : textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Person Name',
                  labelStyle: TextStyle(color: accentColor),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter person name';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _reasonController,
                style: TextStyle(
                  color: widget.themeState.isDark ? accentColor : textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: 'Reason / Note (Optional)',
                  labelStyle: TextStyle(color: accentColor),
                  hintText: 'e.g. Dinner bill, Emergency, etc.',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      final now = DateTime.now();
                      _selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        now.hour,
                        now.minute,
                        now.second,
                      );
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.edit_calendar_rounded, size: 16, color: accentColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: widget.themeState.theme[appColors.textSecondaryColor])),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.themeState.theme[appColors.accentColor]!,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _submit,
          child: const Text('Add Loan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

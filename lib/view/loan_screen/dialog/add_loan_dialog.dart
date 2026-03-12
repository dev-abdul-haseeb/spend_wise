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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final double amount = double.parse(_amountController.text.trim());
      final newLoan = LoanModel(
        amount: widget.take ? (-1 * amount) : amount,
        person_name: _sourceController.text.trim(),
        date_time: _selectedDate,
      );
      widget.loanBloc.add(AddLoan(loan: newLoan));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.themeState.theme[appColors.cardColor],
      title: AppText(
        widget.title,
        color: widget.themeState.theme[appColors.primaryColor]!,
        type: TextType.screenTitles,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                  color: widget.themeState.isDark ? widget.themeState.theme[appColors.accentColor] : widget.themeState.theme[appColors.textPrimaryColor]
              ),
              decoration: InputDecoration(
                label: AppText(
                    'Amount',
                    color: widget.themeState.theme[appColors.accentColor]!
                ),
                prefixText: 'Rs. ' + (widget.take ? '-' : '+'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter an amount';
                if (double.tryParse(value) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _sourceController,
              style: TextStyle(
                  color: widget.themeState.isDark ? widget.themeState.theme[appColors.accentColor] : widget.themeState.theme[appColors.textPrimaryColor]
              ),
              decoration: InputDecoration(
                label: AppText(
                    'Person',
                    color: widget.themeState.theme[appColors.accentColor]!
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                AppText(
                  'Time: ',
                  color: widget.themeState.theme[appColors.primaryColor]!,
                  type: TextType.transactionDescription,
                ),
                AppText(
                  '${_selectedDate!.hour}:${_selectedDate!.minute}:${_selectedDate!.second}',
                  color: widget.themeState.theme[appColors.textPrimaryColor]!,
                  type: TextType.transactionDescription,
                ),
              ],
            ),
            Row(
              children: [
                AppText(
                  'Date: ',
                  color: widget.themeState.theme[appColors.primaryColor]!,
                  type: TextType.transactionDescription,
                ),
                AppText(
                  '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  color: widget.themeState.theme[appColors.textPrimaryColor]!,
                  type: TextType.transactionDescription,
                ),
              ],
            )
          ],
        ),
      ),
      actions: [

        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(
              widget.themeState.theme[appColors.incomeColor]!,
            ),
          ),
          onPressed: () => _submit(),
          child: Text('Add', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}

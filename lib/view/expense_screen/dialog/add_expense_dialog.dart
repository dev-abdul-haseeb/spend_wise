import 'package:flutter/material.dart';
import 'package:spend_wise/config/color/colors.dart';
import 'package:spend_wise/config/components/textwidgets.dart';
import 'package:spend_wise/viewModel/bloc/theme/theme_bloc.dart';

import '../../../config/enum/enum.dart';
import '../../../model/expense/expense_model.dart';
import '../../../model/expense/expense_model.dart';
import '../../../viewModel/bloc/expense/expense_bloc.dart';
import '../../../viewModel/bloc/expense/expense_bloc.dart';

class AddExpenseDialog extends StatefulWidget {
  final ExpenseBloc expenseBloc;
  final ThemeState themeState;

  const AddExpenseDialog({required this.expenseBloc, required this.themeState});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  DateTime? _selectedDate;
  expenseType _selectedType = expenseType.Others;

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
      final newExpense = ExpenseModel(
        amount: double.parse(_amountController.text.trim()),
        reason: _sourceController.text.trim(),
        date_time: _selectedDate,
        type: _selectedType,
      );
      widget.expenseBloc.add(AddExpense(expense: newExpense));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.themeState.theme[appColors.cardColor],
      title: AppText(
        'Add Expense',
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
                prefixText: 'Rs. ',
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
                    'Reason',
                    color: widget.themeState.theme[appColors.accentColor]!
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<expenseType>(
              value: _selectedType,
              dropdownColor: widget.themeState.theme[appColors.cardColor],
              decoration: InputDecoration(
                label: AppText('Type', color: widget.themeState.theme[appColors.accentColor]!),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              items: expenseType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: AppText(
                    type.name,
                    color: widget.themeState.theme[appColors.textPrimaryColor]!,
                    type: TextType.transactionDescription,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
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
              widget.themeState.theme[appColors.expenseColor]!,
            ),
          ),
          onPressed: () => _submit(),
          child: Text('Add', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}

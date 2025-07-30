import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class AddExpenseDialog extends StatefulWidget {
  final Function(String title, String description, double amount, ExpenseType type, String category, DateTime date) onSave;

  const AddExpenseDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  ExpenseType _selectedType = ExpenseType.expense;
  String _selectedCategory = 'Food'; // Default category
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Food', 'Transport', 'Housing', 'Entertainment', 'Salary', 'Investments', 'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Transaction'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description (Optional)'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Expense'),
                    leading: Radio<ExpenseType>(
                      value: ExpenseType.expense,
                      groupValue: _selectedType,
                      onChanged: (ExpenseType? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Income'),
                    leading: Radio<ExpenseType>(
                      value: ExpenseType.income,
                      groupValue: _selectedType,
                      onChanged: (ExpenseType? value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'Category'),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final title = _titleController.text;
            final description = _descriptionController.text;
            final amount = double.tryParse(_amountController.text) ?? 0.0;

            if (title.isNotEmpty && amount > 0) {
              widget.onSave(title, description, amount, _selectedType, _selectedCategory, _selectedDate);
            } else {
              Get.snackbar('Error', 'Please enter a valid title and amount',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
                colorText: Get.theme.colorScheme.onError,
              );
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double remainingBudget;
  final Budget? budget;
  final VoidCallback onSetBudget;

  const BudgetSummaryCard({
    Key? key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.remainingBudget,
    this.budget,
    required this.onSetBudget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      color: Colors.pink.shade800,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            _buildInfoRow('Total Income:', totalIncome, Colors.greenAccent),
            _buildInfoRow('Total Expenses:', totalExpenses, Colors.redAccent),
            Divider(color: Colors.white54, height: 25),
            _buildInfoRow('Remaining Budget:', remainingBudget, remainingBudget >= 0 ? Colors.lightGreenAccent : Colors.orangeAccent),
            SizedBox(height: 20),
            if (budget != null) ...[
              Text(
                'Current Budget: ${budget!.name} (${budget!.period.toString().split('.').last.capitalizeFirst!})',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                'Amount: \$${budget!.amount.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                'Period: ${DateFormat('MMM dd, yyyy').format(budget!.startDate)} - ${DateFormat('MMM dd, yyyy').format(budget!.endDate)}',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 15),
            ],
            Center(
              child: ElevatedButton(
                onPressed: onSetBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(budget == null ? 'Set Budget' : 'Change Budget', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white,
                fontSize: 18),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
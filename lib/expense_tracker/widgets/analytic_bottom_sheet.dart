
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/expense_controller.dart';

class ExpenseAnalyticsSheet extends StatelessWidget {
  final List<CategorySpending> categoryAnalytics;
  final double totalExpenses;
  final double totalIncome;
  final List<BudgetInsight> budgetInsights;

  const ExpenseAnalyticsSheet({
    Key? key,
    required this.categoryAnalytics,
    required this.totalExpenses,
    required this.totalIncome,
    required this.budgetInsights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple.shade700, size: 28),
                SizedBox(width: 12),
                Text(
                  'Expense Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard('Total Income', totalIncome, Colors.green, Icons.trending_up)),
                      SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard('Total Expenses', totalExpenses, Colors.red, Icons.trending_down)),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Category Breakdown
                  if (categoryAnalytics.isNotEmpty) ...[
                    Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Pie Chart
                    Container(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: _generatePieChartSections(),
                          centerSpaceRadius: 60,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Category List
                    ...categoryAnalytics.map((category) => _buildCategoryItem(category)),
                  ],
                  
                  SizedBox(height: 24),
                  
                  // Budget Insights
                  if (budgetInsights.isNotEmpty) ...[
                    Text(
                      'Smart Insights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...budgetInsights.map((insight) => _buildInsightCard(insight)),
                  ],
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              Spacer(),
              Text(
                amount.toStringAsFixed(2),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    List<Color> colors = [
      Colors.purple, Colors.pink, Colors.orange, Colors.blue,
      Colors.green, Colors.red, Colors.yellow, Colors.teal,
    ];
    
    return categoryAnalytics.take(8).map((category) {
      int index = categoryAnalytics.indexOf(category);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: category.amount,
        title: '${category.percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryItem(CategorySpending category) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.purple.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              category.category,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '\${category.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${category.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BudgetInsight insight) {
    Color cardColor;
    IconData iconData;
    
    switch (insight.type) {
      case InsightType.warning:
        cardColor = Colors.orange;
        iconData = Icons.warning_amber;
        break;
      case InsightType.tip:
        cardColor = Colors.blue;
        iconData = Icons.lightbulb;
        break;
      case InsightType.success:
        cardColor = Colors.green;
        iconData = Icons.check_circle;
        break;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: cardColor, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            insight.description,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (insight.actionSuggestion.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.tips_and_updates, color: cardColor, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.actionSuggestion,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// Enhanced Add Expense Dialog with Smart Features - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../controllers/expense_controller.dart';

class EnhancedAddExpenseDialog extends StatefulWidget {
  final Function(String title, String description, double amount, ExpenseType type, String category, DateTime date) onSave;
  final Future<String> Function(String title, String description) onGetSmartCategory;
  final List<String> suggestedCategories;
  final ExpenseData? prefilledData;

  const EnhancedAddExpenseDialog({
    Key? key,
    required this.onSave,
    required this.onGetSmartCategory,
    required this.suggestedCategories,
    this.prefilledData,
  }) : super(key: key);

  @override
  _EnhancedAddExpenseDialogState createState() => _EnhancedAddExpenseDialogState();
}

class _EnhancedAddExpenseDialogState extends State<EnhancedAddExpenseDialog>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  ExpenseType _selectedType = ExpenseType.expense;
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  bool _isGettingSmartCategory = false;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeData() {
    if (widget.prefilledData != null) {
      _titleController.text = widget.prefilledData!.title;
      _descriptionController.text = widget.prefilledData!.description;
      _amountController.text = widget.prefilledData!.amount.toString();
      _selectedCategory = widget.prefilledData!.category;
      _selectedDate = widget.prefilledData!.date;
    }
    
    if (_selectedCategory.isEmpty && widget.suggestedCategories.isNotEmpty) {
      _selectedCategory = widget.suggestedCategories.first;
    }
  }

  Future<void> _getSmartCategory() async {
    if (_titleController.text.isEmpty) return;
    
    setState(() => _isGettingSmartCategory = true);
    
    try {
      final smartCategory = await widget.onGetSmartCategory(
        _titleController.text,
        _descriptionController.text,
      );
      
      setState(() {
        _selectedCategory = smartCategory;
        _isGettingSmartCategory = false;
      });
      
      Get.snackbar(
        'Smart Category Suggested!',
        'We suggest "$smartCategory" for this expense',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => _isGettingSmartCategory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: maxWidth,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.add, color: Colors.pink.shade800, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add New Expense',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Form Fields
                  _buildTextField(
                    controller: _titleController,
                    label: 'Title',
                    icon: Icons.title,
                    required: true,
                  ),
                  SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description (Optional)',
                    icon: Icons.description,
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _amountController,
                    label: 'Amount',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                  SizedBox(height: 20),
                  
                  _buildExpenseTypeSelector(),
                  SizedBox(height: 20),
                  
                  _buildCategorySelector(),
                  SizedBox(height: 20),
                  
                  _buildDateSelector(),
                  SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text('Cancel'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _saveExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Save Expense'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        prefixIcon: Icon(icon, color: Colors.pink.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink.shade800, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildExpenseTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile<ExpenseType>(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_circle_down, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Flexible(child: Text('Expense', style: TextStyle(fontSize: 14))),
                    ],
                  ),
                  value: ExpenseType.expense,
                  groupValue: _selectedType,
                  onChanged: (ExpenseType? value) {
                    setState(() => _selectedType = value!);
                  },
                  activeColor: Colors.pink.shade800,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
              Expanded(
                child: RadioListTile<ExpenseType>(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_circle_up, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Flexible(child: Text('Income', style: TextStyle(fontSize: 14))),
                    ],
                  ),
                  value: ExpenseType.income,
                  groupValue: _selectedType,
                  onChanged: (ExpenseType? value) {
                    setState(() => _selectedType = value!);
                  },
                  activeColor: Colors.pink.shade800,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory.isEmpty ? null : _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.category, color: Colors.pink.shade800),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: widget.suggestedCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category, style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _selectedCategory = newValue ?? '');
                },
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _isGettingSmartCategory ? null : _getSmartCategory,
                icon: _isGettingSmartCategory
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.pink.shade800),
                        ),
                      )
                    : Icon(Icons.auto_awesome, color: Colors.pink.shade800),
                tooltip: 'Get Smart Category',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.pink.shade800),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.pink.shade800),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveExpense() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (title.isEmpty || amount <= 0 || _selectedCategory.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please fill in all required fields with valid data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    widget.onSave(title, description, amount, _selectedType, _selectedCategory, _selectedDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

// Smart Budget Summary Card with Animations - FIXED VERSION
class SmartBudgetSummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double remainingBudget;
  final Budget? budget;
  final double budgetUsagePercentage;
  final bool shouldShowWarning;
  final List<BudgetInsight> insights;
  final VoidCallback onSetBudget;
  final VoidCallback onViewAnalytics;
  final AnimationController animationController;
  final double screenWidth;

  const SmartBudgetSummaryCard({
    Key? key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.remainingBudget,
    this.budget,
    required this.budgetUsagePercentage,
    required this.shouldShowWarning,
    required this.insights,
    required this.onSetBudget,
    required this.onViewAnalytics,
    required this.animationController,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.all(16),
          child: Card(
            elevation: 12,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: shouldShowWarning
                      ? [Colors.orange.shade600, Colors.red.shade500]
                      : [Colors.pink.shade800, Colors.pink.shade600],
                ),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 16),
                  _buildBudgetProgress(),
                  SizedBox(height: 16),
                  _buildFinancialSummary(),
                  if (budget != null) ...[
                    SizedBox(height: 16),
                    _buildBudgetInfo(),
                  ],
                  if (insights.isNotEmpty) ...[
                    SizedBox(height: 16),
                    _buildInsights(),
                  ],
                  SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 24,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 600 ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (shouldShowWarning)
                Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.yellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Budget Alert!',
                      style: TextStyle(color: Colors.yellow, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onViewAnalytics,
          icon: Icon(Icons.analytics, color: Colors.white, size: 20),
          tooltip: 'Analytics',
        ),
      ],
    );
  }

  Widget _buildBudgetProgress() {
    if (budget == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Usage',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              '${budgetUsagePercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: (budgetUsagePercentage / 100) * animationController.value,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                budgetUsagePercentage > 90
                    ? Colors.red
                    : budgetUsagePercentage > 70
                        ? Colors.orange
                        : Colors.green,
              ),
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
    return Column(
      children: [
        _buildInfoRow('Total Income', totalIncome, Colors.greenAccent, Icons.trending_up),
        SizedBox(height: 8),
        _buildInfoRow('Total Expenses', totalExpenses, Colors.redAccent, Icons.trending_down),
        SizedBox(height: 8),
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.3),
        ),
        SizedBox(height: 8),
        _buildInfoRow(
          'Remaining Budget',
          remainingBudget,
          remainingBudget >= 0 ? Colors.lightGreenAccent : Colors.orangeAccent,
          remainingBudget >= 0 ? Icons.savings : Icons.warning,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, double amount, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        Text(
          '\${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInfo() {
    if (budget == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            budget!.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timeline, color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text(
                    budget!.period.toString().split('.').last.capitalizeFirst!,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_money, color: Colors.white70, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '\${budget!.amount.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '${DateFormat('MMM dd').format(budget!.startDate)} - ${DateFormat('MMM dd').format(budget!.endDate)}',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow, size: 16),
              SizedBox(width: 8),
              Text(
                'Smart Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...insights.take(2).map((insight) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      insight.type == InsightType.warning
                          ? Icons.warning_amber
                          : Icons.tips_and_updates,
                      color: insight.type == InsightType.warning
                          ? Colors.orange
                          : Colors.lightBlue,
                      size: 14,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.title,
                        style: TextStyle(color: Colors.white, fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return screenWidth < 400 
        ? Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSetBudget,
                  icon: Icon(Icons.edit, size: 18),
                  label: Text(budget == null ? 'Set Budget' : 'Edit Budget'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pink.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onViewAnalytics,
                  icon: Icon(Icons.bar_chart, size: 18),
                  label: Text('Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onSetBudget,
                  icon: Icon(Icons.edit, size: 18),
                  label: Text(budget == null ? 'Set Budget' : 'Edit Budget'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pink.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onViewAnalytics,
                  icon: Icon(Icons.bar_chart, size: 18),
                  label: Text('Analytics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          );
    }
  }
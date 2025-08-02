import 'package:farahs_hub/expense_tracker/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FloatingActionMenu extends StatefulWidget {
  final VoidCallback onAddExpense;
  final VoidCallback onScanReceipt;
  final RxBool isProcessing;
  final AnimationController animationController;

  const FloatingActionMenu({
    Key? key,
    required this.onAddExpense,
    required this.onScanReceipt,
    required this.isProcessing,
    required this.animationController,
  }) : super(key: key);

  @override
  _FloatingActionMenuState createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with TickerProviderStateMixin {
  bool _isMenuOpen = false;
  late AnimationController _menuController;
  late Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _menuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay
        if (_isMenuOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: AnimatedBuilder(
                animation: _menuAnimation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(0.3 * _menuAnimation.value),
                  );
                },
              ),
            ),
          ),

        // Menu items
        AnimatedBuilder(
          animation: _menuAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scan Receipt Button
                Transform.translate(
                  offset: Offset(0, -80 * _menuAnimation.value),
                  child: Transform.scale(
                    scale: _menuAnimation.value,
                    child: FloatingActionButton(
                      heroTag: "scan",
                      onPressed: _isMenuOpen ? () {
                        _toggleMenu();
                        widget.onScanReceipt();
                      } : null,
                      backgroundColor: Colors.orange.shade600,
                      child: Obx(() => widget.isProcessing.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.camera_alt, color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Add Expense Button
                Transform.translate(
                  offset: Offset(0, -40 * _menuAnimation.value),
                  child: Transform.scale(
                    scale: _menuAnimation.value,
                    child: FloatingActionButton(
                      heroTag: "add",
                      onPressed: _isMenuOpen ? () {
                        _toggleMenu();
                        widget.onAddExpense();
                      } : null,
                      backgroundColor: Colors.green.shade600,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Main FAB
                FloatingActionButton(
                  heroTag: "main",
                  onPressed: _toggleMenu,
                  backgroundColor: Colors.purple.shade700,
                  child: AnimatedRotation(
                    turns: _isMenuOpen ? 0.125 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ],
            );
          },
        ),

        // Labels for menu items
        if (_isMenuOpen)
          AnimatedBuilder(
            animation: _menuAnimation,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Scan Receipt Label
                  Transform.translate(
                    offset: Offset(-80, -80 * _menuAnimation.value),
                    child: Transform.scale(
                      scale: _menuAnimation.value,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Scan Receipt',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Add Expense Label
                  Transform.translate(
                    offset: Offset(-80, -40 * _menuAnimation.value),
                    child: Transform.scale(
                      scale: _menuAnimation.value,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Add Expense',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 72), // Account for main FAB
                ],
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }
}

// Smart Filters Bar
class SmartFiltersBar extends StatelessWidget {
  final String selectedTimeFilter;
  final String selectedCategoryFilter;
  final List<String> availableCategories;
  final Function(String) onTimeFilterChanged;
  final Function(String) onCategoryFilterChanged;

  const SmartFiltersBar({
    Key? key,
    required this.selectedTimeFilter,
    required this.selectedCategoryFilter,
    required this.availableCategories,
    required this.onTimeFilterChanged,
    required this.onCategoryFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              'Time',
              selectedTimeFilter,
              ['All', 'Today', 'This Week', 'This Month', 'Last 3 Months'],
              onTimeFilterChanged,
              Icons.access_time,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              'Category',
              selectedCategoryFilter,
              ['All', ...availableCategories],
              onCategoryFilterChanged,
              Icons.category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          icon: Icon(Icons.arrow_drop_down, color: Colors.purple.shade700),
          style: TextStyle(color: Colors.purple.shade700, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) onChanged(newValue);
          },
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: Colors.purple.shade700),
                  SizedBox(width: 8),
                  Text(value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Animated Expense List Item
class AnimatedExpenseListItem extends StatefulWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final Duration animationDelay;

  const AnimatedExpenseListItem({
    Key? key,
    required this.expense,
    required this.onDelete,
    required this.onTap,
    required this.animationDelay,
  }) : super(key: key);

  @override
  _AnimatedExpenseListItemState createState() => _AnimatedExpenseListItemState();
}

class _AnimatedExpenseListItemState extends State<AnimatedExpenseListItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation after delay
    Future.delayed(widget.animationDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.expense.type == ExpenseType.income
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.expense.type == ExpenseType.income
                          ? Icons.arrow_circle_up
                          : Icons.arrow_circle_down,
                      color: widget.expense.type == ExpenseType.income
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    widget.expense.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.expense.description.isNotEmpty)
                        Text(
                          widget.expense.description,
                          style: TextStyle(color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.expense.category,
                              style: TextStyle(
                                color: Colors.purple.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd').format(widget.expense.date),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\${widget.expense.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: widget.expense.type == ExpenseType.income
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
                        onPressed: widget.onDelete,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
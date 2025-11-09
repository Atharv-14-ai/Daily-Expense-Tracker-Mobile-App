import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class BudgetScreen extends StatefulWidget {
  final Map<String, double> budgets;
  final Map<String, double> categoryTotals;
  final Function(Map<String, double>) onUpdateBudgets;

  const BudgetScreen({
    super.key,
    required this.budgets,
    required this.categoryTotals,
    required this.onUpdateBudgets,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final List<String> _categories = [
    'Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Health', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    for (final category in _categories) {
      _controllers[category] = TextEditingController(
        text: widget.budgets[category]?.toStringAsFixed(2) ?? '',
      );
    }
  }

  void _saveBudgets() {
    final newBudgets = <String, double>{};
    for (final category in _categories) {
      final value = double.tryParse(_controllers[category]!.text) ?? 0;
      if (value > 0) {
        newBudgets[category] = value;
      }
    }
    widget.onUpdateBudgets(newBudgets);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budgets updated successfully')),
    );
  }

  Widget _buildBudgetItem(String category) {
    final spent = widget.categoryTotals[category] ?? 0;
    final budget = widget.budgets[category] ?? 0;
    final percentage = budget > 0 ? (spent / budget) * 100 : 0;
    final isOverBudget = spent > budget;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(
                  _getCategoryIcon(category),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controllers[category],
              decoration: const InputDecoration(
                labelText: 'Budget Limit',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage > 1 ? 1 : percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent: \$${spent.toStringAsFixed(2)}'),
                Text('Limit: \$${budget.toStringAsFixed(2)}'),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isOverBudget ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isOverBudget)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Budget exceeded by \$${(spent - budget).toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set monthly budgets for each category to track your spending',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ..._categories.map((category) => _buildBudgetItem(category)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _saveBudgets,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Save All Budgets'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Shopping': return Icons.shopping_bag;
      case 'Entertainment': return Icons.movie;
      case 'Bills': return Icons.receipt;
      case 'Health': return Icons.local_hospital;
      default: return Icons.money;
    }
  }
}
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/storage_service.dart';
import 'add_expense_screen.dart';
import 'budget_screen.dart';
import 'reports_screen.dart';
import 'search_screen.dart';

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  List<Expense> expenses = [];
  Map<String, double> budgets = {};
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedExpenses = await StorageService.loadExpenses();
    final loadedBudgets = await StorageService.loadBudgets();
    setState(() {
      expenses = loadedExpenses;
      budgets = loadedBudgets;
    });
  }

  double get totalExpenses {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Budget> get budgetStatus {
    return budgets.entries.map((entry) {
      final spent = categoryTotals[entry.key] ?? 0;
      return Budget(
        category: entry.key,
        limit: entry.value,
        spent: spent,
      );
    }).toList();
  }

  void _addExpense(Expense expense) {
    setState(() {
      expenses.add(expense);
    });
    StorageService.saveExpenses(expenses);
  }

  void _deleteExpense(String id) {
    setState(() {
      expenses.removeWhere((expense) => expense.id == id);
    });
    StorageService.saveExpenses(expenses);
  }

  void _updateBudgets(Map<String, double> newBudgets) {
    setState(() {
      budgets = newBudgets;
    });
    StorageService.saveBudgets(budgets);
  }

  void _showAddExpenseScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddExpenseScreen(onAddExpense: _addExpense),
      ),
    ).then((_) {
      // Refresh data when returning from add expense screen
      _loadData();
    });
  }

  List<Expense> get _recentExpenses {
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses.take(5).toList();
  }

  List<Expense> get _todayExpenses {
    final today = DateTime.now();
    return expenses.where((expense) =>
    expense.date.year == today.year &&
        expense.date.month == today.month &&
        expense.date.day == today.day
    ).toList();
  }

  double get _todayTotal {
    return _todayExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Welcome Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello! 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your expenses easily',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Quick Stats
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Spent',
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.blue.shade400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Today',
                  '\$${_todayTotal.toStringAsFixed(2)}',
                  Icons.today,
                  Colors.green.shade400,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Transactions',
                  expenses.length.toString(),
                  Icons.receipt,
                  Colors.orange.shade400,
                ),
              ),
            ],
          ),
        ),

        // Budget Warnings
        if (budgetStatus.any((budget) => budget.isExceeded))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget Alert',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Some categories have exceeded their budget',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 2; // Navigate to Budget tab
                        });
                      },
                      icon: Icon(Icons.arrow_forward, color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Quick Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Add Expense',
                      Icons.add,
                      Colors.blue.shade400,
                      _showAddExpenseScreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      'View Reports',
                      Icons.analytics,
                      Colors.purple.shade400,
                          () => setState(() => _currentIndex = 3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Recent Expenses
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Expenses',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 1; // Navigate to Expenses tab
                        });
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _recentExpenses.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                    itemCount: _recentExpenses.length,
                    itemBuilder: (ctx, index) {
                      final expense = _recentExpenses[index];
                      return _buildExpenseItem(expense);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesTab() {
    return Column(
      children: [
        // Header with total
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Expenses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                backgroundColor: Theme.of(context).colorScheme.primary,
                label: Text(
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Expenses List
        Expanded(
          child: expenses.isEmpty
              ? _buildEmptyExpensesState()
              : ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (ctx, index) {
              final expense = expenses[index];
              return _buildExpenseItem(expense);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Dismissible(
      key: ValueKey(expense.id),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(expense);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getCategoryColor(expense.category).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category),
            ),
          ),
          title: Text(
            expense.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${expense.category} • ${_formatDate(expense.date)}'),
              if (expense.description != null && expense.description!.isNotEmpty)
                Text(
                  expense.description!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTime(expense.date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          onTap: () {
            // TODO: Implement expense editing
            _showExpenseDetails(expense);
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first expense to get started',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddExpenseScreen,
            icon: const Icon(Icons.add),
            label: const Text('Add First Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExpensesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No Expenses',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your expense list is empty',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddExpenseScreen,
            icon: const Icon(Icons.add),
            label: const Text('Add New Expense'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(Expense expense) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
              ),
              title: Text(
                expense.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(expense.category),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('Amount', '\$${expense.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Date', _formatFullDate(expense.date)),
            _buildDetailRow('Time', _formatTime(expense.date)),
            if (expense.description != null && expense.description!.isNotEmpty)
              _buildDetailRow('Description', expense.description!),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // TODO: Implement edit functionality
                    },
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_currentIndex == 1) // Only show search on expenses tab
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(expenses: expenses),
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportData();
                  break;
                case 'clear':
                  _showClearConfirmation();
                  break;
                case 'refresh':
                  _loadData();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh Data')),
              const PopupMenuItem(value: 'export', child: Text('Export Data')),
              const PopupMenuItem(value: 'clear', child: Text('Clear All Data')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildExpensesTab(),
          BudgetScreen(
            budgets: budgets,
            categoryTotals: categoryTotals,
            onUpdateBudgets: _updateBudgets,
          ),
          ReportsScreen(expenses: expenses),
        ],
      ),
      floatingActionButton: _currentIndex == 1 ? FloatingActionButton(
        onPressed: _showAddExpenseScreen,
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to delete all expenses and budgets? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                expenses.clear();
                budgets.clear();
              });
              StorageService.saveExpenses(expenses);
              StorageService.saveBudgets(budgets);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared successfully')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportData() async {
    try {
      final file = await StorageService.exportToFile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.amber.shade400,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
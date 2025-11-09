import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class SearchScreen extends StatefulWidget {
  final List<Expense> expenses;

  const SearchScreen({super.key, required this.expenses});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Expense> _filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    _filteredExpenses = widget.expenses;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExpenses = widget.expenses.where((expense) {
        return expense.title.toLowerCase().contains(query) ||
            expense.category.toLowerCase().contains(query) ||
            (expense.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search expenses...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ],
      ),
      body: _filteredExpenses.isEmpty
          ? const Center(child: Text('No expenses found'))
          : ListView.builder(
        itemCount: _filteredExpenses.length,
        itemBuilder: (ctx, index) {
          final expense = _filteredExpenses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: Icon(_getCategoryIcon(expense.category)),
              title: Text(expense.title),
              subtitle: Text('${expense.category} • \$${expense.amount.toStringAsFixed(2)}'),
              trailing: Text(_formatDate(expense.date)),
            ),
          );
        },
      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
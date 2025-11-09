import 'package:shared_preferences/shared_preferences.dart';
import 'models/expense_model.dart';

class StorageService {
  static const String _expensesKey = 'expenses';
  static const String _budgetsKey = 'budgets';

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = expenses.map((expense) => expense.toMap()).toList();
    await prefs.setString(_expensesKey, json.encode(expensesJson));
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey);
    if (expensesJson != null) {
      final List<dynamic> expensesList = json.decode(expensesJson);
      return expensesList.map((item) => Expense.fromMap(item)).toList();
    }
    return [];
  }

  static Future<void> saveBudgets(Map<String, double> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetsKey, json.encode(budgets));
  }

  static Future<Map<String, double>> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getString(_budgetsKey);
    if (budgetsJson != null) {
      final Map<String, dynamic> budgetsMap = json.decode(budgetsJson);
      return budgetsMap.map((key, value) => MapEntry(key, value.toDouble()));
    }
    return {};
  }
}
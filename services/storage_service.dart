import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/expense_model.dart';

class StorageService {
  static const String _expensesKey = 'expenses';
  static const String _budgetsKey = 'budgets';

  // Save expenses to local storage
  static Future<void> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = expenses.map((expense) => expense.toMap()).toList();
      await prefs.setString(_expensesKey, json.encode(expensesJson));
    } catch (e) {
      print('Error saving expenses: $e');
      throw Exception('Failed to save expenses');
    }
  }

  // Load expenses from local storage
  static Future<List<Expense>> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = prefs.getString(_expensesKey);

      if (expensesJson != null && expensesJson.isNotEmpty) {
        final List<dynamic> expensesList = json.decode(expensesJson);
        return expensesList.map((item) => Expense.fromMap(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading expenses: $e');
      return [];
    }
  }

  // Save budgets to local storage
  static Future<void> saveBudgets(Map<String, double> budgets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_budgetsKey, json.encode(budgets));
    } catch (e) {
      print('Error saving budgets: $e');
      throw Exception('Failed to save budgets');
    }
  }

  // Load budgets from local storage
  static Future<Map<String, double>> loadBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getString(_budgetsKey);

      if (budgetsJson != null && budgetsJson.isNotEmpty) {
        final Map<String, dynamic> budgetsMap = json.decode(budgetsJson);
        return budgetsMap.map((key, value) {
          if (value is int) {
            return MapEntry(key, value.toDouble());
          } else if (value is double) {
            return MapEntry(key, value);
          } else {
            return MapEntry(key, 0.0);
          }
        });
      }
      return {};
    } catch (e) {
      print('Error loading budgets: $e');
      return {};
    }
  }

  // Export data to a file
  static Future<File> exportToFile() async {
    try {
      final expenses = await loadExpenses();
      final budgets = await loadBudgets();

      final data = {
        'expenses': expenses.map((e) => e.toMap()).toList(),
        'budgets': budgets,
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_tracker_backup.json');
      await file.writeAsString(json.encode(data));

      return file;
    } catch (e) {
      print('Error exporting to file: $e');
      throw Exception('Failed to export data');
    }
  }

  // Import data from a file
  static Future<void> importFromFile(File file) async {
    try {
      final contents = await file.readAsString();
      final data = json.decode(contents) as Map<String, dynamic>;

      if (data['expenses'] != null) {
        final expenses = (data['expenses'] as List)
            .map((item) => Expense.fromMap(item))
            .toList();
        await saveExpenses(expenses);
      }

      if (data['budgets'] != null) {
        final budgets = Map<String, double>.from(data['budgets']);
        await saveBudgets(budgets);
      }
    } catch (e) {
      print('Error importing from file: $e');
      throw Exception('Failed to import data - invalid file format');
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_expensesKey);
      await prefs.remove(_budgetsKey);
    } catch (e) {
      print('Error clearing all data: $e');
      throw Exception('Failed to clear data');
    }
  }
}
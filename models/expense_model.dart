class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    try {
      return Expense(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: map['title']?.toString() ?? 'Unknown',
        amount: (map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount']) ?? 0.0,
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        category: map['category']?.toString() ?? 'Other',
        description: map['description']?.toString(),
      );
    } catch (e) {
      print('Error parsing expense: $e');
      // Return a default expense if parsing fails
      return Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Recovered Expense',
        amount: 0.0,
        date: DateTime.now(),
        category: 'Other',
        description: 'This expense was recovered after an error',
      );
    }
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, date: $date, category: $category)';
  }
}

class Budget {
  final String category;
  final double limit;
  final double spent;

  Budget({
    required this.category,
    required this.limit,
    required this.spent,
  });

  double get remaining => limit - spent;
  double get percentage => limit > 0 ? (spent / limit) * 100 : 0;

  bool get isExceeded => spent > limit;
  bool get isNearLimit => percentage >= 80 && !isExceeded;

  Budget copyWith({
    String? category,
    double? limit,
    double? spent,
  }) {
    return Budget(
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }
}
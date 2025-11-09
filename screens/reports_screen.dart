import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense_model.dart';

class ReportsScreen extends StatefulWidget {
  final List<Expense> expenses;

  const ReportsScreen({super.key, required this.expenses});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedChartType = 0; // 0 = Pie, 1 = Bar
  int _touchedIndex = -1;

  Map<String, double> get _categoryData {
    final Map<String, double> data = {};
    for (final expense in widget.expenses) {
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

  List<PieChartSectionData> _getPieChartSections() {
    final total = _categoryData.values.fold(0.0, (sum, amount) => sum + amount);
    final entries = _categoryData.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final percentage = total > 0 ? (categoryEntry.value / total) * 100 : 0;
      final isTouched = index == _touchedIndex;
      final double radius = isTouched ? 70 : 60;

      return PieChartSectionData(
        color: _getCategoryColor(categoryEntry.key),
        value: categoryEntry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getBarChartGroups() {
    final entries = _categoryData.entries.toList();
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: categoryEntry.value,
            color: _getCategoryColor(categoryEntry.key),
            width: 22,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
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
      Colors.indigo.shade400,
      Colors.pink.shade400,
      Colors.cyan.shade400,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: _getPieChartSections(),
      ),
    );
  }

  Widget _buildBarChart() {
    final categories = _categoryData.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final category = categories[groupIndex];
              return BarTooltipItem(
                '$category\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '\$${rod.toY.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < categories.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      categories[value.toInt()],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: _getBarChartGroups(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.expenses.isNotEmpty;

    return Scaffold(
      body: !hasData
          ? _buildEmptyState()
          : Column(
        children: [
          // Chart Type Selector
          _buildChartTypeSelector(),

          // Chart
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _selectedChartType == 0
                      ? _buildPieChart()
                      : _buildBarChart(),
                ),
              ),
            ),
          ),

          // Legend and Statistics
          Expanded(
            flex: 3,
            child: _buildLegendAndStats(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Data Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some expenses to see reports and charts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(
            value: 0,
            label: Text('Pie Chart'),
            icon: Icon(Icons.pie_chart),
          ),
          ButtonSegment(
            value: 1,
            label: Text('Bar Chart'),
            icon: Icon(Icons.bar_chart),
          ),
        ],
        selected: <int>{_selectedChartType},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            _selectedChartType = newSelection.first;
            _touchedIndex = -1;
          });
        },
      ),
    );
  }

  Widget _buildLegendAndStats() {
    final categories = _categoryData.entries.toList();
    final total = _categoryData.values.fold(0.0, (sum, amount) => sum + amount);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...categories.map((entry) {
                      final percentage = total > 0
                          ? (entry.value / total) * 100
                          : 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${percentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Statistics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem('Total Expenses', _getTotalExpenses()),
                    _buildStatItem('Number of Transactions', '${widget.expenses.length}'),
                    _buildStatItem('Average per Transaction', _getAverageExpense()),
                    _buildStatItem('Largest Expense', _getLargestExpense()),
                    _buildStatItem('Most Spent Category', _getTopCategory()),
                    _buildStatItem('Date Range', _getDateRange()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getTotalExpenses() {
    final total = widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return '\$${total.toStringAsFixed(2)}';
  }

  String _getAverageExpense() {
    if (widget.expenses.isEmpty) return '\$0.00';
    final total = widget.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return '\$${(total / widget.expenses.length).toStringAsFixed(2)}';
  }

  String _getLargestExpense() {
    if (widget.expenses.isEmpty) return '\$0.00';
    final largest = widget.expenses.reduce((a, b) => a.amount > b.amount ? a : b);
    return '\$${largest.amount.toStringAsFixed(2)}';
  }

  String _getTopCategory() {
    if (_categoryData.isEmpty) return 'None';
    final topEntry = _categoryData.entries.reduce((a, b) => a.value > b.value ? a : b);
    return topEntry.key;
  }

  String _getDateRange() {
    if (widget.expenses.isEmpty) return 'N/A';

    final dates = widget.expenses.map((e) => e.date).toList();
    dates.sort();

    final oldest = dates.first;
    final newest = dates.last;

    if (oldest.year == newest.year && oldest.month == newest.month) {
      return '${_formatMonthYear(oldest)}';
    }

    return '${_formatMonthYear(oldest)} - ${_formatMonthYear(newest)}';
  }

  String _formatMonthYear(DateTime date) {
    return '${date.month}/${date.year}';
  }
}
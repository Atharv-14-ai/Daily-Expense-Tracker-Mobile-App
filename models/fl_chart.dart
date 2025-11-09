// Simple custom pie chart widget
class CustomPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CustomPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (sum, amount) => sum + amount);
    final entries = data.entries.toList();

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _PieChartPainter(entries: entries, total: total),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;

  _PieChartPainter({required this.entries, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    var startAngle = -90.0 * (3.141592653589793 / 180.0);

    for (final entry in entries) {
      final sweepAngle = (entry.value / total) * 360.0 * (3.141592653589793 / 180.0);
      final color = _getColorForCategory(entry.key);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  Color _getColorForCategory(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }
}
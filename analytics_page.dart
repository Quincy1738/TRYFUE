import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  final double totalRevenue;
  final List<double> last7DaysRevenue;
  final List<double> last30DaysRevenue;
  final List<double> last12MonthsRevenue;

  const AnalyticsPage({
    super.key,
    required this.totalRevenue,
    required this.last7DaysRevenue,
    required this.last30DaysRevenue,
    required this.last12MonthsRevenue,
  });

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedPeriod = 'Week'; // 'Week', 'Month', 'Year'

  List<double> get _selectedRevenue {
    switch (_selectedPeriod) {
      case 'Month':
        return widget.last30DaysRevenue;
      case 'Year':
        return widget.last12MonthsRevenue;
      case 'Week':
      default:
        return widget.last7DaysRevenue;
    }
  }

  List<String> get _selectedLabels {
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'Month':
      // Label only every 6th day as "Week 1", "Week 2", etc.
        return List.generate(30, (i) {
          if (i % 6 == 0) {
            return 'Week ${(i ~/ 6) + 1}';
          }
          return '';
        });
      case 'Year':
        return [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
      case 'Week':
      default:
      // Show last 7 days with day name and date, e.g., Mon 01
        return List.generate(7, (i) {
          DateTime date = now.subtract(Duration(days: 6 - i));
          return DateFormat('EEE dd').format(date);
        });
    }
  }

  // Format numbers with K/M suffixes for left axis labels
  String formatCurrency(double value) {
    final absValue = value.abs();

    if (absValue >= 1e6) {
      return '₱${(value / 1e6).toStringAsFixed(1)}M';
    } else if (absValue >= 1e3) {
      return '₱${(value / 1e3).toStringAsFixed(1)}K';
    } else {
      // Use comma formatting for values < 1000
      final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
      return formatter.format(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final revenue = _selectedRevenue;
    final labels = _selectedLabels;
    final maxRevenue = revenue.isNotEmpty ? revenue.reduce((a, b) => a > b ? a : b) : 0.0;
    final verticalInterval = maxRevenue / 4 > 0 ? maxRevenue / 4 : 1.0;

    return Scaffold(
      appBar: AppBar(title: Text("Analytics ($_selectedPeriod)")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.show_chart, size: 60, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      "Total Revenue Today",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₱${widget.totalRevenue.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Period selector buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['Week', 'Month', 'Year'].map((period) {
                final isSelected = _selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    },
                    child: Text(period),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Revenue trend chart title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Revenue Trend (Last $_selectedPeriod)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
            ),

            const SizedBox(height: 12),

            // Line chart
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxRevenue * 1.2,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            final label = labels[index];
                            if (label.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 10)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: verticalInterval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            formatCurrency(value),
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: verticalInterval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        revenue.length,
                            (index) => FlSpot(index.toDouble(), revenue[index]),
                      ),
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.blueAccent,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

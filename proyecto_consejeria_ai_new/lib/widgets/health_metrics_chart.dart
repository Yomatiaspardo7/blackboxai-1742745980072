import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_profile.dart';

class HealthMetricsChart extends StatelessWidget {
  final List<HealthReading> readings;
  final String title;
  final Color lineColor;
  final String metricType; // 'heartRate', 'oxygenLevel', 'stressLevel'

  const HealthMetricsChart({
    super.key,
    required this.readings,
    required this.title,
    required this.lineColor,
    required this.metricType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (readings.isEmpty) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final date = readings[value.toInt()].timestamp;
                      return Text(
                        '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _getSpots(),
                  isCurved: true,
                  color: lineColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lineColor.withOpacity(0.2),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: theme.cardColor,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final reading = readings[spot.x.toInt()];
                      return LineTooltipItem(
                        _getTooltipText(reading),
                        theme.textTheme.bodySmall!,
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getSpots() {
    return readings.asMap().entries.map((entry) {
      final value = _getValueForMetric(entry.value);
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  double _getValueForMetric(HealthReading reading) {
    switch (metricType) {
      case 'heartRate':
        return reading.heartRate.toDouble();
      case 'oxygenLevel':
        return reading.oxygenLevel;
      case 'stressLevel':
        return reading.stressLevel.toDouble();
      default:
        return 0;
    }
  }

  String _getTooltipText(HealthReading reading) {
    switch (metricType) {
      case 'heartRate':
        return '${reading.heartRate} BPM';
      case 'oxygenLevel':
        return '${reading.oxygenLevel}%';
      case 'stressLevel':
        return '${reading.stressLevel}/10';
      default:
        return '';
    }
  }
}

class HealthMetricsDetailCard extends StatelessWidget {
  final List<HealthReading> readings;
  final String title;
  final IconData icon;
  final Color color;
  final String metricType;
  final String unit;

  const HealthMetricsDetailCard({
    super.key,
    required this.readings,
    required this.title,
    required this.icon,
    required this.color,
    required this.metricType,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentValue = readings.isNotEmpty ? _getCurrentValue() : 0;
    final average = readings.isNotEmpty ? _getAverageValue() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MetricValueCard(
                  label: 'Actual',
                  value: currentValue,
                  unit: unit,
                  color: color,
                ),
                _MetricValueCard(
                  label: 'Promedio',
                  value: average,
                  unit: unit,
                  color: color.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 16),
            HealthMetricsChart(
              readings: readings,
              title: 'Últimas 24 horas',
              lineColor: color,
              metricType: metricType,
            ),
          ],
        ),
      ),
    );
  }

  double _getCurrentValue() {
    final reading = readings.last;
    switch (metricType) {
      case 'heartRate':
        return reading.heartRate.toDouble();
      case 'oxygenLevel':
        return reading.oxygenLevel;
      case 'stressLevel':
        return reading.stressLevel.toDouble();
      default:
        return 0;
    }
  }

  double _getAverageValue() {
    if (readings.isEmpty) return 0;
    
    double sum = 0;
    for (var reading in readings) {
      switch (metricType) {
        case 'heartRate':
          sum += reading.heartRate;
          break;
        case 'oxygenLevel':
          sum += reading.oxygenLevel;
          break;
        case 'stressLevel':
          sum += reading.stressLevel;
          break;
      }
    }
    return sum / readings.length;
  }
}

class _MetricValueCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _MetricValueCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              children: [
                TextSpan(text: value.toStringAsFixed(1)),
                TextSpan(
                  text: ' $unit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
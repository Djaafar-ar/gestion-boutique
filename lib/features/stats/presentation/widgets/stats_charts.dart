import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/money.dart';
import '../../domain/stats.dart';

/// Short amount for chart axes: 1 250 000,00 DA -> "1,3M", 12 500 -> "12,5k".
String compactDA(int centimes) {
  final da = centimes / 100;
  String one(double v) =>
      v.toStringAsFixed(v.abs() >= 10 ? 0 : 1).replaceAll('.', ',');
  if (da.abs() >= 1000000) return '${one(da / 1000000)}M';
  if (da.abs() >= 1000) return '${one(da / 1000)}k';
  return da.toStringAsFixed(0);
}

/// Money taken per day (or per month): one bar each.
class RevenueBarChart extends StatelessWidget {
  final List<DayAmount> days;
  final bool byMonth;

  const RevenueBarChart({super.key, required this.days, required this.byMonth});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final highest = days.fold<int>(0, (m, d) => max(m, d.amount));
    final lowest = days.fold<int>(0, (m, d) => min(m, d.amount));
    // About 7 labels whatever the number of bars.
    final every = max(1, (days.length / 7).ceil());
    final barWidth = days.length > 20 ? 6.0 : (days.length > 10 ? 10.0 : 18.0);

    String label(DateTime day) => byMonth
        ? '${day.month.toString().padLeft(2, '0')}/${day.year % 100}'
        : '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';

    // Dates always read left to right, also in Arabic.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: highest == 0 ? 1 : highest * 1.15,
            minY: lowest < 0 ? lowest * 1.15 : 0,
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => scheme.inverseSurface,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  '${label(days[group.x].day)}\n${formatDA(days[group.x].amount)}',
                  TextStyle(color: scheme.onInverseSurface, fontSize: 12),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(compactDA(value.round()),
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index % every != 0 || index >= days.length) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(label(days[index].day),
                          style: const TextStyle(fontSize: 10)),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (final (index, day) in days.indexed)
                BarChartGroupData(x: index, barRods: [
                  BarChartRodData(
                    toY: day.amount.toDouble(),
                    color: day.amount < 0 ? scheme.error : scheme.primary,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

/// One slice of a [LegendPieChart].
typedef PieSlice = ({String label, int amount, Color color});

/// A ring chart with its legend (label, amount, share).
class LegendPieChart extends StatelessWidget {
  final List<PieSlice> slices;

  const LegendPieChart({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    final shown = slices.where((s) => s.amount > 0).toList();
    final total = shown.fold<int>(0, (a, s) => a + s.amount);
    if (total == 0) return const SizedBox.shrink();
    return Row(
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: PieChart(PieChartData(
            centerSpaceRadius: 28,
            sectionsSpace: 2,
            sections: [
              for (final slice in shown)
                PieChartSectionData(
                  value: slice.amount.toDouble(),
                  color: slice.color,
                  radius: 24,
                  showTitle: false,
                ),
            ],
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final slice in shown)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: slice.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            '${slice.label} (${(slice.amount * 100 / total).round()} %)',
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Text(formatDAForUi(slice.amount),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A row with a label, an amount and a bar as long as its share of
/// [highest] (sales per person).
class ShareBar extends StatelessWidget {
  final String label;
  final String? detail;
  final int amount;
  final int highest;

  const ShareBar(
      {super.key,
      required this.label,
      this.detail,
      required this.amount,
      required this.highest});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final share = highest <= 0 ? 0.0 : (amount / highest).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(formatDAForUi(amount),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 10,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(detail!,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DailyFinanceChart extends StatelessWidget {
  final List<dynamic> doacoes;
  final List<dynamic> despesas;

  const DailyFinanceChart({super.key, required this.doacoes, required this.despesas});

  @override
  Widget build(BuildContext context) {
    Map<String, double> entradasPorDia = {};
    Map<String, double> saidasPorDia = {};

    // 1. Agrupa Entradas
    for (var d in doacoes) {
      String data = DateFormat('dd/MM').format(DateTime.parse(d['data']));
      entradasPorDia[data] = (entradasPorDia[data] ?? 0) + (d['valor'] as num).toDouble();
    }

    // 2. Agrupa Saídas
    for (var e in despesas) {
      String data = DateFormat('dd/MM').format(DateTime.parse(e['data']));
      saidasPorDia[data] = (saidasPorDia[data] ?? 0) + (e['valor'] as num).toDouble();
    }

    List<String> todasDatas = {...entradasPorDia.keys, ...saidasPorDia.keys}.toList()..sort();

    List<BarChartGroupData> gruposDeBarras = [];
    for (int i = 0; i < todasDatas.length; i++) {
      String data = todasDatas[i];
      double valorEntrada = entradasPorDia[data] ?? 0;
      double valorSaida = saidasPorDia[data] ?? 0;

      gruposDeBarras.add(
        BarChartGroupData(
          x: i,
          barRods: [
            // BARRA VERDE (Entrada)
            BarChartRodData(
              toY: valorEntrada,
              color: Colors.green,
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
            // BARRA VERMELHA (Saída)
            BarChartRodData(
              toY: valorSaida,
              color: Colors.redAccent,
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: gruposDeBarras,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < todasDatas.length) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(todasDatas[index], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}
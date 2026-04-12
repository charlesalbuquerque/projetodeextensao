import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/animal_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final AnimalService _service = AnimalService();

  final List<Color> _coresGrafico = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estatísticas da ONG"),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _service.getStatusCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Sem dados para exibir o gráfico."));
          }

          final dados = snapshot.data!;
          final listaStatus = dados.keys.toList();

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Distribuição por Status",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _gerarSecoes(dados),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: listaStatus.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String status = entry.value;
                    return _buildLegenda(
                      status, 
                      _coresGrafico[idx % _coresGrafico.length]
                    );
                  }).toList(),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _gerarSecoes(Map<String, double> dados) {
    int i = 0;
    return dados.entries.map((entry) {
      final cor = _coresGrafico[i % _coresGrafico.length];
      i++;
      return PieChartSectionData(
        color: cor,
        value: entry.value,
        title: '${entry.value.toInt()}',
        radius: 50,
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          fontSize: 16,
        ),
      );
    }).toList();
  }

  Widget _buildLegenda(String status, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
      child: Row(
        children: [
          Container(
            width: 18, 
            height: 18, 
            decoration: BoxDecoration(
              color: cor, // Cor dinâmica aqui!
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            status,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
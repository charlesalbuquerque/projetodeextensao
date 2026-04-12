import 'package:flutter/material.dart';
import '../services/finance_service.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FinanceService();

    return Scaffold(
      appBar: AppBar(title: const Text("Relatório Geral"), backgroundColor: Colors.blueGrey),
      body: FutureBuilder(
        future: Future.wait([
          service.getResumoFinanceiro(),
          service.fetchTodasDoacoes(),
          service.fetchTodasDespesas(), // Adicionado!
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final resumo = snapshot.data![0];
          final doacoes = snapshot.data![1];
          final despesas = snapshot.data![2];

          List<dynamic> todasTransacoes = [...doacoes, ...despesas];
          todasTransacoes.sort((a, b) => b['data'].compareTo(a['data']));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Situação de Caixa"),
                _buildRow("Entradas total:", "R\$ ${resumo['total_recebido']}", Colors.green),
                _buildRow("Saídas total:", "R\$ ${resumo['total_gasto']}", Colors.red),
                const Divider(height: 30, thickness: 2),
                _buildHeader("Histórico de Transações"),
                Expanded(
                  child: ListView.builder(
                    itemCount: todasTransacoes.length,
                    itemBuilder: (context, index) {
                      final item = todasTransacoes[index];
                      bool isDoacao = item.containsKey('doador');

                      return ListTile(
                        leading: Icon(
                          isDoacao ? Icons.add_circle : Icons.remove_circle,
                          color: isDoacao ? Colors.green : Colors.red,
                        ),
                        title: Text(isDoacao ? item['doador'] : item['descricao']),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(item['data']))),
                        trailing: Text(
                          "${isDoacao ? '+' : '-'} R\$ ${item['valor']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDoacao ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRow(String label, String value, Color cor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: cor))],
    );
  }
}
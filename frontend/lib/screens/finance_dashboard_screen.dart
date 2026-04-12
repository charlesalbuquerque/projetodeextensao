import 'package:flutter/material.dart';
import '../services/finance_service.dart';
import '../widgets/daily_finance_chart.dart';
import 'donation_screen.dart';
import 'expense_screen.dart';
import 'report_screen.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  final FinanceService _service = FinanceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestão Financeira"),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _service.getResumoFinanceiro(),
          _service.fetchTodasDoacoes(),
          _service.fetchTodasDespesas(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar dados financeiros."));
          }

          if (!snapshot.hasData) return const Center(child: Text("Nenhum dado encontrado."));

          // Mapeamento dos dados vindos do Future.wait
          final resumo = snapshot.data![0];
          final doacoes = snapshot.data![1];
          final despesas = snapshot.data![2];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Cartão de Saldo
                _buildBalanceCard(
                  resumo['total_recebido'].toDouble(),
                  resumo['total_gasto'].toDouble(),
                  resumo['saldo'].toDouble(),
                ),
                
                const SizedBox(height: 24),

                // 2. Botões de Ação Rápida
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context, 
                        "Nova Doação", 
                        Icons.add_circle, 
                        Colors.green, 
                        const DonationScreen()
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context, 
                        "Novo Gasto", 
                        Icons.remove_circle, 
                        Colors.redAccent, 
                        const ExpenseScreen()
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                
                const Text(
                  "Fluxo de Caixa Diário", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 16),
                
                // 3. Gráfico de Barras
                SizedBox(
                  height: 250,
                  child: DailyFinanceChart(
                    doacoes: doacoes, 
                    despesas: despesas,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Divider(),
                
                // 4. Link para Relatório Completo
                ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.blueGrey),
                  title: const Text("Ver Relatório Completo", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Detalhamento de todas as transações"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const ReportScreen())
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, Widget screen) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => screen)
      ).then((_) => setState(() {})), // Atualiza a tela ao voltar das telas de cadastro
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildBalanceCard(double entradas, double saidas, double saldo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Saldo Atual em Caixa", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              "R\$ ${saldo.toStringAsFixed(2)}", 
              style: TextStyle(
                fontSize: 36, 
                fontWeight: FontWeight.bold, 
                color: saldo >= 0 ? Colors.green : Colors.red
              )
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat("Entradas", "R\$ ${entradas.toStringAsFixed(2)}", Colors.green),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildMiniStat("Saídas", "R\$ ${saidas.toStringAsFixed(2)}", Colors.redAccent),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
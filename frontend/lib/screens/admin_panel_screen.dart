import 'package:flutter/material.dart';
import 'package:pet_rescue_app/screens/finance_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'admin_management_screen.dart';
import 'lista_fornecedores.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo 🛠️"),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, 
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // 1. GESTÃO DE APROVAÇÕES
            _buildMenuCard(
              context, 
              "Aprovações", 
              Icons.verified_user,
              Colors.teal, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminManagementScreen()))
            ),
            
            // 2. FINANCEIRO
            _buildMenuCard(
              context, 
              "Financeiro", 
              Icons.attach_money, 
              Colors.green, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceDashboardScreen()))
            ),

            // 3. MURAL DE ANIMAIS
            _buildMenuCard(
              context, 
              "Mural de Animais", 
              Icons.pets, 
              Colors.orange, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()))
            ),

            // 4. ESTATÍSTICAS
            _buildMenuCard(
              context, 
              "Estatísticas", 
              Icons.bar_chart, 
              Colors.blue, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()))
            ),

            // 5. FORNECEDORES
            _buildMenuCard(
              context, 
              "Fornecedores", 
              Icons.business, 
              Colors.purple, 
              () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ListaFornecedores())
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }
}
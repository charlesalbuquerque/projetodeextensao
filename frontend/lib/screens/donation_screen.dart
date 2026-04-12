import 'package:flutter/material.dart';
import '../services/finance_service.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _doadorController = TextEditingController();
  final _financeService = FinanceService();
  bool _carregando = false;

  void _salvarDoacao() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      
      double valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
      
      bool sucesso = await _financeService.registrarDoacao(
        valor,
        _doadorController.text,
        null,
      );

      if (!mounted) return;
      setState(() => _carregando = false);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Doação registrada! ❤️")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao registrar doação.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Doação"), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.volunteer_activism, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              TextFormField(
                controller: _doadorController,
                decoration: const InputDecoration(labelText: "Nome do Doador", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Quem doou?" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Valor (R\$)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                validator: (v) => v!.isEmpty ? "Insira o valor" : null,
              ),
              const SizedBox(height: 30),
              _carregando 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _salvarDoacao,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Confirmar Doação", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/finance_service.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descController = TextEditingController();
  String _categoria = 'Ração'; // Valor padrão
  final _service = FinanceService();

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      double valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
      bool sucesso = await _service.registrarDespesa(valor, _descController.text, _categoria);

      if (mounted) {
        if (sucesso) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gasto registrado!")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar.")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Gasto"), backgroundColor: Colors.redAccent),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Descrição (Ex: Clínica Veterinária)", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "O que foi pago?" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Valor (R\$)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.money_off)),
                validator: (v) => v!.isEmpty ? "Qual o valor?" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Categoria"),
                items: ['Ração', 'Veterinário', 'Limpeza', 'Medicamentos', 'Outros']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 50)),
                child: const Text("Registrar Saída", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/animal_service.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nomeController = TextEditingController();
  final _especieController = TextEditingController();
  final _statusController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _descricaoController = TextEditingController();

  final _service = AnimalService();

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      // 2. AGORA PASSAMOS OS 5 ARGUMENTOS
      bool sucesso = await _service.createAnimal(
        _nomeController.text,
        _especieController.text,
        _statusController.text,
        _localizacaoController.text,
        _descricaoController.text,
      );

      if (mounted) {
        if (sucesso) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pet enviado para aprovação! 🐾")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao salvar. Verifique o console.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo Pet"),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome do Animal"),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _especieController,
                decoration: const InputDecoration(labelText: "Espécie (Cão, Gato...)"),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: "Status (Ex: Resgatado)"),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _localizacaoController,
                decoration: const InputDecoration(labelText: "Localização (Cidade/Bairro)"),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 10),
              
              // 3. CAMPO DE DESCRIÇÃO
              TextFormField(
                controller: _descricaoController,
                maxLines: 3, // Dá mais espaço para escrever
                decoration: const InputDecoration(
                  labelText: "Descrição / História do Pet",
                  hintText: "Conte um pouco sobre as condições do resgate...",
                ),
                validator: (v) => v!.isEmpty ? "Conte um pouco sobre o pet" : null,
              ),
              
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Cadastrar Pet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
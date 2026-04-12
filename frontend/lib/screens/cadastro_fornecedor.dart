import 'package:flutter/material.dart';
import '../services/fornecedor_service.dart';

class CadastroFornecedor extends StatefulWidget {
  const CadastroFornecedor({Key? key}) : super(key: key);

  @override
  _CadastroFornecedorState createState() => _CadastroFornecedorState();
}

class _CadastroFornecedorState extends State<CadastroFornecedor> {
  final FornecedorService _service = FornecedorService();

  final nomeController = TextEditingController();
  final contatoController = TextEditingController();
  final servicoController = TextEditingController();
  // 1. Novo controller para o campo exigido pelo banco
  final tipoController = TextEditingController(); 

  Future<void> salvar() async {
    // Verificação básica para não enviar campos vazios
    if (nomeController.text.isEmpty || tipoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nome e Tipo são obrigatórios!")),
      );
      return;
    }

    // 2. Passando o quarto parâmetro (tipo) para o serviço
    bool sucesso = await _service.cadastrarFornecedor(
      nomeController.text,
      contatoController.text,
      servicoController.text,
      tipoController.text, 
    );

    if (sucesso && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Parceiro cadastrado com sucesso!")),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao cadastrar. Verifique o console.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar Parceiro"), 
        backgroundColor: Colors.purple
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome da Empresa",
                prefixIcon: Icon(Icons.business, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 10),
            // 3. Novo TextField para o Tipo
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(
                labelText: "Tipo (Ex: Alimentos, Medicamentos, Serviço)",
                prefixIcon: Icon(Icons.category, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contatoController,
              decoration: const InputDecoration(
                labelText: "Contato (E-mail/Telefone)",
                prefixIcon: Icon(Icons.contact_phone, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: servicoController,
              decoration: const InputDecoration(
                labelText: "Descrição do Serviço",
                prefixIcon: Icon(Icons.description, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "SALVAR PARCEIRO", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
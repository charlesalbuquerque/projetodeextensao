import 'package:flutter/material.dart';
import 'fornecedor_service.dart';

class CadastroFornecedor extends StatefulWidget {
  @override
  _CadastroFornecedorState createState() => _CadastroFornecedorState();
}

class _CadastroFornecedorState extends State<CadastroFornecedor> {
  final nomeController = TextEditingController();
  final cnpjController = TextEditingController();
  final telefoneController = TextEditingController();

  salvar() async {
    await cadastrarFornecedor(
      nomeController.text,
      cnpjController.text,
      telefoneController.text,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastrar Parceiro")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: "Nome"),
            ),
            TextField(
              controller: cnpjController,
              decoration: InputDecoration(labelText: "CNPJ"),
            ),
            TextField(
              controller: telefoneController,
              decoration: InputDecoration(labelText: "Telefone"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvar,
              child: Text("Salvar"),
            )
          ],
        ),
      ),
    );
  }
}
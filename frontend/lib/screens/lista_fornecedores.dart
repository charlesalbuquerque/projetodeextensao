import 'package:flutter/material.dart';
import 'fornecedor_service.dart';

class ListaFornecedores extends StatefulWidget {
  @override
  _ListaFornecedoresState createState() => _ListaFornecedoresState();
}

class _ListaFornecedoresState extends State<ListaFornecedores> {
  List fornecedores = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  carregar() async {
    final data = await listarFornecedores();
    setState(() {
      fornecedores = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fornecedores")),
      body: ListView.builder(
        itemCount: fornecedores.length,
        itemBuilder: (context, index) {
          final f = fornecedores[index];

          return Card(
            child: ListTile(
              title: Text(f['nome']),
              subtitle: Text("CNPJ: ${f['cnpj']}"),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../services/fornecedor_service.dart';
import 'cadastro_fornecedor.dart'; 
class ListaFornecedores extends StatefulWidget {
  const ListaFornecedores({Key? key}) : super(key: key);

  @override
  _ListaFornecedoresState createState() => _ListaFornecedoresState();
}

class _ListaFornecedoresState extends State<ListaFornecedores> {
  final FornecedorService _service = FornecedorService();
  List fornecedores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() => isLoading = true);
    final data = await _service.listarFornecedores();
    setState(() {
      fornecedores = data;
      isLoading = false;
    });
  }

  Future<void> excluir(int id) async {
    // Diálogo de confirmação
    bool? confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Parceiro"),
        content: const Text("Deseja realmente remover este fornecedor?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      bool sucesso = await _service.removerFornecedor(id);
      if (sucesso) {
        carregar(); // Recarrega a lista
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fornecedor removido com sucesso!")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fornecedores"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregar, 
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : fornecedores.isEmpty
              ? const Center(child: Text("Nenhum fornecedor cadastrado."))
              : ListView.builder(
                  itemCount: fornecedores.length,
                  itemBuilder: (context, index) {
                    final f = fornecedores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.withOpacity(0.1),
                          child: Text(
                            f['nome'][0].toUpperCase(),
                            style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(f['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Serviço: ${f['servico']}\nContato: ${f['contato']}"),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () => excluir(f['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Quando voltar da tela de cadastro, recarrega a lista
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroFornecedor()),
          );
          carregar();
        },
      ),
    );
  }
}
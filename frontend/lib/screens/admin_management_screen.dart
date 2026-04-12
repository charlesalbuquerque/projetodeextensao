import 'package:flutter/material.dart';
import '../services/animal_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final AnimalService _service = AnimalService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestão de Aprovações"),
          backgroundColor: Colors.lightGreen,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pending_actions), text: "Mural"),
              Tab(icon: Icon(Icons.people), text: "Candidatos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAprovacaoMuralTab(),
            _buildAprovacaoCandidatosTab(),
          ],
        ),
      ),
    );
  }

  // ABA 1: NOVOS ANIMAIS QUE QUEREM ENTRAR NO MURAL
  Widget _buildAprovacaoMuralTab() {
    return FutureBuilder<List<dynamic>>(
      future: _service.fetchAnimaisPendentes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text("Nenhum pet pendente."));

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final pet = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(pet['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Espécie: ${pet['especie']}\nDescrição: ${pet['descricao']}"),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    if (await _service.aprovarAnimal(pet['id'])) {
                      setState(() {}); // Recarrega a lista
                    }
                  },
                  child: const Text("Aprovar", style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ABA 2: PESSOAS QUE QUEREM ADOTAR
  Widget _buildAprovacaoCandidatosTab() {
    return FutureBuilder<List<dynamic>>(
      future: _service.fetchCandidaturas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isEmpty) return const Center(child: Text("Nenhuma candidatura nova."));

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final app = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pet: ${app['animal']['nome']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Candidato: ${app['user']['nome']} (${app['user']['email']})"),
                    const Divider(),
                    Text("Motivo: ${app['info']}"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (await _service.decidirCandidatura(app['id'], "REJEITADA")) setState(() {});
                          },
                          child: const Text("Rejeitar", style: TextStyle(color: Colors.red)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () async {
                            if (await _service.decidirCandidatura(app['id'], "APROVADA")) setState(() {});
                          },
                          child: const Text("Aprovar Adoção", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
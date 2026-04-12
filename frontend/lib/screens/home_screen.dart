import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/animal_service.dart';
import 'add_animal_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnimalService _animalService = AnimalService();
  final _applicationController = TextEditingController();

  // Função para abrir o formulário de candidatura
  void _abrirCandidatura(BuildContext context, int animalId, String nomeAnimal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Candidatar-se para adotar $nomeAnimal"),
        content: TextField(
          controller: _applicationController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Conte um pouco sobre você, sua casa e por que quer adotar este pet...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              if (_applicationController.text.isEmpty) return;
              
              bool sucesso = await _animalService.seCandidatar(animalId, _applicationController.text);
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(sucesso 
                      ? "Candidatura enviada! O Admin entrará em contato." 
                      : "Erro ao enviar candidatura."),
                    backgroundColor: sucesso ? Colors.green : Colors.red,
                  )
                );
                _applicationController.clear();
              }
            },
            child: const Text("Enviar Interesse"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mural de Adoção 🐾"),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _animalService.fetchAnimais(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Nenhum pet disponível para adoção no momento."),
                ],
              )
            );
          }

          final animais = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: animais.length,
            itemBuilder: (context, index) {
              final animal = animais[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(Icons.pets, color: Colors.white, size: 30),
                      ),
                      title: Text(
                        animal['nome'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Espécie: ${animal['especie']} | Local: ${animal['localizacao']}"),
                          const SizedBox(height: 8),
                          Text(animal['descricao'] ?? "Sem descrição disponível."),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _abrirCandidatura(context, animal['id'], animal['nome']),
                          icon: const Icon(Icons.favorite, color: Colors.white),
                          label: const Text("Quero Adotar!", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Cadastrar Pet", style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAnimalScreen()),
          ).then((_) {
            setState(() {}); 
          });
        },
      ),
    );
  }
}
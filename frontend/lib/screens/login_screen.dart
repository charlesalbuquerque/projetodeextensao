import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _carregando = false;

  void _tentarLogin() async {
    setState(() => _carregando = true);

    // Chama o serviço que criamos antes
    bool sucesso = await _authService.login(
      _emailController.text,
      _senhaController.text,
    );

    setState(() => _carregando = false);

    if (sucesso) {
      // Por enquanto, apenas mostra um aviso de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login realizado! 🐾"), backgroundColor: Colors.green),
      );
      // TODO: Navegar para a Home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Falha no login. Verifique seus dados."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            const Text("Pet Rescue", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _senhaController,
              obscureText: true, // Esconde a senha
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _carregando ? null : _tentarLogin,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: _carregando 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Entrar", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
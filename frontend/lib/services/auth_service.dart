import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://localhost:3000";

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Token recebido: ${data['token']}");
        return true;
      } else {
        print("Erro no login: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Não foi possível conectar ao servidor: $e");
      return false;
    }
  }
}
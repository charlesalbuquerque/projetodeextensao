import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        
        await prefs.setString('role', data['user']['role']);

        print("Login realizado. Role: ${data['user']['role']}");
        return true; 
      } else {
        return false;
      }
    } catch (e) {
      print("Erro de conexão: $e");
      return false;
    }
  }
}
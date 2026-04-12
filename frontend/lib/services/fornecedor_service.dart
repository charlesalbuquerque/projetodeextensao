import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FornecedorService {
  final String baseUrl = "http://localhost:3000";

  // 1. Busca a lista de fornecedores 
  Future<List<dynamic>> listarFornecedores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/fornecedores'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Erro ao buscar fornecedores: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Erro de conexão fornecedores: $e");
      return [];
    }
  }

  // 2. Cadastra um novo fornecedor 
  Future<bool> cadastrarFornecedor(String nome, String contato, String servico, String tipo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/fornecedores'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': nome,
          'contato': contato,
          'servico': servico,
          'tipo': tipo,
        }),
      );

      if (response.statusCode == 201) {
        print("Fornecedor cadastrado com sucesso!");
        return true;
      } else {
        print("Erro do servidor: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro ao cadastrar fornecedor: $e");
      return false;
    }
  }

  // 3. Remove um fornecedor
  Future<bool> removerFornecedor(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('$baseUrl/admin/fornecedores/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Erro ao remover fornecedor: $e");
      return false;
    }
  }
}
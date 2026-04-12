import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FinanceService {
  final String baseUrl = "http://localhost:3000";

  Future<bool> registrarDoacao(double valor, String doador, int? animalId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/financeiro/doacao'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'valor': valor,
          'doador': doador,
          'animalId': animalId,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Erro ao registrar doação: $e");
      return false;
    }
  }

  // Busca o resumo (Total, Gasto, Saldo)
  Future<Map<String, dynamic>> getResumoFinanceiro() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/financeiro/resumo'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {"total_recebido": 0, "total_gasto": 0, "saldo": 0};
  }

  Future<List<dynamic>> fetchTodasDoacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/financeiro/doacoes'),
      headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return [];
  }

  Future<bool> registrarDespesa(double valor, String descricao, String categoria) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/financeiro/despesa'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'valor': valor,
          'descricao': descricao,
          'categoria': categoria,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> fetchTodasDespesas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/financeiro/despesas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }
}
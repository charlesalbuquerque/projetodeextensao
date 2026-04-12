import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AnimalService {
  final String baseUrl = "http://localhost:3000";

  // --- FUNÇÕES PÚBLICAS / USUÁRIO ---

  // Busca a lista de animais aprovados
  Future<List<dynamic>> fetchAnimais() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/animais'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Falha ao carregar animais");
      }
    } catch (e) {
      print("Erro ao buscar animais: $e");
      return [];
    }
  }

  // Cadastra um novo animal
  Future<bool> createAnimal(
    String nome,
    String especie,
    String status,
    String localizacao,
    String descricao,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/animais'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': nome,
          'especie': especie,
          'status': status,
          'localizacao': localizacao,
          'descricao': descricao,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Erro ao cadastrar animal: $e");
      return false;
    }
  }

  // Contagem para gráficos
Future<Map<String, double>> getStatusCount() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/admin/animais/estatisticas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> todos = jsonDecode(response.body);
      Map<String, double> contagem = {};

      for (var animal in todos) {
        String status = animal['status'] ?? 'Outros';
        contagem[status] = (contagem[status] ?? 0) + 1;
      }
      return contagem;
    }
    return {};
  } catch (e) {
    print("Erro ao gerar contagem: $e");
    return {};
  }
}
  // Candidatura para adoção
  Future<bool> seCandidatar(int animalId, String infoAdicionais) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/adocoes/candidatar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'animalId': animalId, 'info': infoAdicionais}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print("Erro ao se candidatar: $e");
      return false;
    }
  }

  // --- ÁREA DO ADMIN ---

  // 1. Busca pets que aguardam aprovação para o mural
  Future<List<dynamic>> fetchAnimaisPendentes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/animais/pendentes'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      print("Erro ao buscar pendentes: $e");
      return [];
    }
  }

  // 2. Aprova o pet para aparecer no mural
  Future<bool> aprovarAnimal(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.put(
        Uri.parse('$baseUrl/admin/animais/$id/aprovar'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erro ao aprovar animal: $e");
      return false;
    }
  }

  // 3. Busca todas as candidaturas de adoção
  Future<List<dynamic>> fetchCandidaturas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/candidaturas'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200 ? jsonDecode(response.body) : [];
    } catch (e) {
      print("Erro ao buscar candidaturas: $e");
      return [];
    }
  }

  // 4. Aprova ou Rejeita uma candidatura
  Future<bool> decidirCandidatura(int id, String novoStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.put(
        Uri.parse('$baseUrl/admin/candidaturas/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'status': novoStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Erro ao decidir candidatura: $e");
      return false;
    }
  }
}
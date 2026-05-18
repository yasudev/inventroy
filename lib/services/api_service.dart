import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService(this.baseUrl);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  void setToken(String? token) => _token = token;

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error'] ?? 'Login failed');
  }

  Future<List<dynamic>> getAll(String entity) async {
    final res = await http.get(Uri.parse('$baseUrl/api/$entity'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch $entity');
  }

  Future<Map<String, dynamic>> getById(String entity, int id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/$entity/$id'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch $entity/$id');
  }

  Future<Map<String, dynamic>> create(String entity, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/$entity'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to create $entity');
  }

  Future<Map<String, dynamic>> update(String entity, int id, Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/$entity/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to update $entity');
  }

  Future<void> delete(String entity, int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/api/$entity/$id'), headers: _headers);
    if (res.statusCode != 200) throw Exception('Failed to delete $entity');
  }

  Future<Map<String, dynamic>> sync(Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/sync'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Sync failed');
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/sales'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to create sale');
  }

  Future<List<dynamic>> getAllSales() async {
    final res = await http.get(Uri.parse('$baseUrl/api/sales'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch sales');
  }
}

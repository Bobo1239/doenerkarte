
import 'dart:convert';
import 'package:http/http.dart' as http;

class BackendCommunicator {
  final String baseUrl;

  BackendCommunicator({required this.baseUrl});

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    _handleResponse(response);
    return json.decode(response.body);
  }

  Future<List<dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    _handleResponse(response);
    return json.decode(utf8.decode(response.bodyBytes));
  }

  Future<List<Map<String, dynamic>>> postListResponse(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    _handleResponse(response);
    return json.decode(response.body);
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}
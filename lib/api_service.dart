// api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://shamandorascout.com/api';

  Future<dynamic> fetchPersons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get-persons-qetaa-baraem'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final base = 'https://api.spaceflightnewsapi.net/v4';

  Future<List<dynamic>> fetchList(String type) async {
    final url = Uri.parse('$base/$type/');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['results'] is List)
        return decoded['results'];
      return [];
    } else {
      throw Exception('HTTP ${resp.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchDetail(String type, String id) async {
    final url = Uri.parse('$base/$type/$id/');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } else {
      throw Exception('HTTP ${resp.statusCode}');
    }
  }
}

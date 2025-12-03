import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> fetchList(String type) async {
    final url = "https://api.spaceflightnewsapi.net/v4/$type/";
    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body)['results'];
  }

  Future<Map<String, dynamic>> fetchDetail(String type, int id) async {
    final url = "https://api.spaceflightnewsapi.net/v4/$type/$id/";
    final response = await http.get(Uri.parse(url));

    return jsonDecode(response.body);
  }
}

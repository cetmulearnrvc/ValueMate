import 'dart:convert';
import 'package:http/http.dart' as http;

class RefIdService {
  // Replace with your actual server IP/URL
  static const String _baseUrl = 'http://72.60.219.196/api/v1';

  static Future<String> generateUniqueId() async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/get-ref-id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['refId']; // The server calculated "2526120601"
      } else {
        throw Exception('Server failed: ${response.statusCode}');
      }
    } catch (e) {
      // Handle "No Internet" or Server Down
      print("Error fetching ID: $e");
      return "ERROR-FETCHING-ID";
    }
  }
}

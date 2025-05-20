import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'https://developer.novusyazilim.com/idn.wa';

  Future<String?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/api/account/SignInWithEmailAndPassword");

    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json-patch+json',
        },
        body: jsonEncode({
          "Email": email,
          "Password": password,
          "RememberMe": true,
        }),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final token = jsonBody["data"]?["token"];
        return token;
      } else {
        print("Giriş başarısız. Hata kodu: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}

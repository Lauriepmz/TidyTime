import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String _apiKey = "AIzaSyDK4d2wsW_Hpt3p5mvBpTdV7WJVdjSQYhk";
  static const String _baseUrl = "https://translation.googleapis.com/language/translate/v2";

  /// Traduit le texte donné dans une langue cible
  static Future<String> translateText(String text, String targetLanguage) async {
    try {
      final Uri url = Uri.parse("$_baseUrl?key=$_apiKey");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "q": text,
          "target": targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data']['translations'][0]['translatedText'];
      } else {
        throw Exception("Failed to translate text: ${response.body}");
      }
    } catch (e) {
      print("Error during translation: $e");
      return text; // Fallback to the original text in case of an error
    }
  }
}

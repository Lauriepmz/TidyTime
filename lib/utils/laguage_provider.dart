import 'package:tidytime/utils/all_imports.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en'; // Langue par défaut

  // Liste des langues disponibles
  final List<String> _supportedLanguages = ['en', 'fr', 'es'];

  String get currentLanguage => _currentLanguage;

  // List<String> get supportedLanguages => _supportedLanguages;

  // Change la langue uniquement si elle est supportée
  void setLanguage(String languageCode) {
    if (_supportedLanguages.contains(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners(); // Informe les widgets que la langue a changé
    } else {
      throw Exception("Langue non supportée : $languageCode");
    }
  }
}

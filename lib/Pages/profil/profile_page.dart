import 'package:tidytime/utils/all_imports.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedMethod = UserSettings.dueDateLastDone; // Méthode par défaut
  String _selectedLanguage = 'en'; // Langue par défaut
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  /// Charge les préférences utilisateur depuis la base de données
  Future<void> _loadPreferences() async {
    final language = await _databaseHelper.getUserPreference('language', defaultValue: 'en');
    final method = await _databaseHelper.getUserPreference(
      'due_date_method',
      defaultValue: UserSettings.dueDateLastDone,
    );

    setState(() {
      _selectedLanguage = language!;
      _selectedMethod = method!;
    });

    // Met à jour la langue de l'application
    _updateAppLanguage(_selectedLanguage);
  }

  /// Met à jour la langue sélectionnée et sauvegarde dans la base de données
  Future<void> _updateLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
    await _databaseHelper.setUserPreference('language', languageCode);

    // Met à jour la langue de l'application
    _updateAppLanguage(languageCode);
  }

  /// Met à jour la méthode de calcul et sauvegarde dans la base de données
  Future<void> _updateMethod(String method) async {
    setState(() {
      _selectedMethod = method;
    });
    await _databaseHelper.setUserPreference('due_date_method', method);
  }

  /// Informe le `LanguageProvider` du changement de langue
  void _updateAppLanguage(String languageCode) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.setLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection de la langue
            Text(
              localization?.selectLanguage ?? "Select Language",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: [
                DropdownMenuItem(value: 'en', child: Text(localization?.english ?? "English")),
                DropdownMenuItem(value: 'fr', child: Text(localization?.french ?? "Français")),
                DropdownMenuItem(value: 'es', child: Text(localization?.spanish ?? "Español")),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateLanguage(newValue);
                }
              },
            ),
            const SizedBox(height: 20),

            // Sélection de la méthode de calcul
            Text(
              localization?.chooseDueDateCalculationMethod ?? "Choose Due Date Calculation Method",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedMethod,
              items: [
                DropdownMenuItem(
                  value: UserSettings.dueDateLastDone,
                  child: Text(localization?.dueDateLastDone ?? "Due Date Last Done"),
                ),
                DropdownMenuItem(
                  value: UserSettings.dueDateLastDoneProposed,
                  child: Text(localization?.dueDateLastProposed ?? "Due Date Last Proposed"),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateMethod(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

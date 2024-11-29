import 'package:tidytime/utils/all_imports.dart';

class UserSettings {
  static const String _dueDateCalculationKey = 'dueDateCalculationMethod';
  static const String dueDateLastDone = 'dueDateLastDone';
  static const String dueDateLastDoneProposed = 'dueDateLastDoneProposed';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Sauvegarder la méthode de calcul choisie
  Future<void> setDueDateCalculationMethod(String method) async {
    await _dbHelper.setUserSetting(_dueDateCalculationKey, method);
  }

  // Récupérer la méthode de calcul de due date choisie
  Future<String> getDueDateCalculationMethod() async {
    String? method = await _dbHelper.getUserSetting(_dueDateCalculationKey);
    return method ?? dueDateLastDone;  // Retourner "dueDateLastDone" si aucune méthode n'est trouvée
  }
}

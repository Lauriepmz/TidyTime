import 'package:tidytime/utils/all_imports.dart';

class DateCalculator {
  // Logic for calculating due dates when creating a task
  static Map<String, DateTime?> calculateTaskCreationDates({
    required DateTime startDate,
  }) {
    // When creating the task, both dueDateLastDone and dueDateLastDoneProposed should be set to startDate
    DateTime dueDateLastDone = startDate;
    DateTime dueDateLastDoneProposed = startDate;

    return {
      'dueDateLastDone': dueDateLastDone,
      'dueDateLastDoneProposed': dueDateLastDoneProposed,
    };
  }
  static Map<String, DateTime?> calculateCompletionDueDates({
    required DateTime currentDate,
    DateTime? lastDone,
    DateTime? lastDoneProposed,
    required int repeatDays,
    required DateTime startDate,
  }) {
    print("---- DateCalculator: Calculating completion due dates ----");

    // Calculer lastDoneProposed (première complétion ou subséquentes)
    DateTime newLastDoneProposed = calculateLastDoneProposed(
      lastDoneProposed: lastDoneProposed,
      startDate: startDate,
      repeatDays: repeatDays,  // Ajouter la périodicité uniquement pour les complétions suivantes
    );

    // Calculer dueDateLastDoneProposed
    DateTime dueDateLastDoneProposed = calculateDueDateLastDoneProposed(
      lastDoneProposed: newLastDoneProposed,
      repeatDays: repeatDays,
    );

    DateTime newLastDone = (lastDone == null) ? currentDate : currentDate.add(Duration());

    return {
      'lastDoneProposed': newLastDoneProposed,  // lastDoneProposed mis à jour
      'dueDateLastDoneProposed': dueDateLastDoneProposed,  // dueDateLastDoneProposed = lastDoneProposed + repeatDays
      'dueDateLastDone': newLastDone.add(Duration(days: repeatDays)),  // lastDone + repeatDays
    };
  }
// Calculer lastDoneProposed séparément
  static DateTime calculateLastDoneProposed({
    required DateTime? lastDoneProposed,
    required DateTime startDate,
    required int repeatDays,
  }) {
    // Si c'est la première complétion, on initialise à startDate
    if (lastDoneProposed == null) {
      return startDate;
    }
    // Pour les complétions suivantes, on ajoute la périodicité à lastDoneProposed
    return lastDoneProposed.add(Duration(days: repeatDays));
  }
// Calculer dueDateLastDoneProposed séparément
  static DateTime calculateDueDateLastDoneProposed({
    required DateTime lastDoneProposed,
    required int repeatDays,
  }) {
    // Ajouter la périodicité à lastDoneProposed (calcul correct)
    return lastDoneProposed.add(Duration(days: repeatDays));
  }

  static Map<String, DateTime?> calculateUpdatedDueDates({
    required DateTime startDate,
    DateTime? lastDone,  // Récupéré via le getter _lastDone
    DateTime? lastDoneProposed,  // Récupéré via le getter _lastDoneProposed
    required int repeatValue,
    required String repeatUnit,
    required bool hasStartDateChanged,
    required bool hasRepeatSettingsChanged,
    DateTime? dueDateLastDone,  // dueDate est indépendant
    DateTime? dueDateLastDoneProposed,  // dueDate est indépendant
  }) {
    int repeatDays = repeatValue * DatabaseHelper.instance.convertUnitToDays(repeatUnit);

    // Cas 1 : Pas de changement de start date ou de repeat settings
    if (!hasStartDateChanged && !hasRepeatSettingsChanged) {
      print("No changes detected, dates should remain the same.");
      return _noChanges(
        lastDone: lastDone,  // Keep lastDone intact
        lastDoneProposed: lastDoneProposed,  // Keep lastDoneProposed intact
        dueDateLastDone: dueDateLastDone,  // Independent due date
        dueDateLastDoneProposed: dueDateLastDoneProposed,  // Independent due date
      );
    }

    // Cas 2 : Changement uniquement des repeat values
    if (!hasStartDateChanged && hasRepeatSettingsChanged) {
      return _updateRepeatValues(
        lastDone: lastDone,
        lastDoneProposed: lastDoneProposed,
        repeatDays: repeatDays,
      );
    }

    // Cas 3 : Changement uniquement du start date
    if (hasStartDateChanged && !hasRepeatSettingsChanged) {
      // Appel à _updateStartDate
      Map<String, DateTime?> updatedDates = _updateStartDate(
        startDate: startDate,
        lastDone: lastDone,  // Keep lastDone intact
        lastDoneProposed: lastDoneProposed,  // New logic: update lastDoneProposed with startDate - periodicity
        repeatDays: repeatDays,
      );

      // Log pour vérifier les dates mises à jour
      print("Updated dates after _updateStartDate: $updatedDates");

      return updatedDates;
    }

    // Cas 4 : Changement des deux (start date + repeat settings)
    if (hasStartDateChanged && hasRepeatSettingsChanged) {
      return _updateStartDateAndRepeatValues(
        startDate: startDate,
        lastDone: lastDone,  // Garder lastDone inchangé
        lastDoneProposed: lastDoneProposed,  // Utiliser pour calculer lastDoneProposed
        repeatDays: repeatDays,  // Utiliser la nouvelle périodicité
      );
    }

    return {};
  }

  static Map<String, DateTime?> _noChanges({
    DateTime? lastDone,
    DateTime? lastDoneProposed,
    DateTime? dueDateLastDone,
    DateTime? dueDateLastDoneProposed,
  }) {
    print("No changes detected, returning original dates.");
    return {
      'dueDateLastDone': dueDateLastDone,
      'dueDateLastDoneProposed': dueDateLastDoneProposed,
      'lastDone': lastDone,  // Retourner la même valeur
      'lastDoneProposed': lastDoneProposed,  // Retourner la même valeur
    };
  }

  static Map<String, DateTime?> _updateRepeatValues({
    DateTime? lastDone,
    DateTime? lastDoneProposed,
    required int repeatDays,
  }) {
    // Log pour vérifier les valeurs avant mise à jour
    print("Updating repeat values:");
    print("Last Done: $lastDone");
    print("Last Done Proposed: $lastDoneProposed");
    print("Repeat Days: $repeatDays");

    // Calculer les nouvelles valeurs basées sur la périodicité
    DateTime? newDueDateLastDone = (lastDone != null) ? lastDone.add(Duration(days: repeatDays)) : null;
    DateTime? newDueDateLastDoneProposed = (lastDoneProposed != null) ? lastDoneProposed.add(Duration(days: repeatDays)) : null;

    // Log pour vérifier les nouvelles dates calculées
    print("New Due Date Last Done: $newDueDateLastDone");
    print("New Due Date Last Done Proposed: $newDueDateLastDoneProposed");

    return {
      'dueDateLastDone': newDueDateLastDone,
      'dueDateLastDoneProposed': newDueDateLastDoneProposed,
      'lastDone': lastDone,
      'lastDoneProposed': lastDoneProposed,
    };
  }

  static Map<String, DateTime?> _updateStartDate({
    required DateTime startDate,
    required DateTime? lastDone,
    required DateTime? lastDoneProposed,
    required int repeatDays,
  }) {
    DateTime newLastDoneProposed = startDate.subtract(Duration(days: repeatDays));
    DateTime newDueDateLastDone = startDate;
    DateTime newDueDateLastDoneProposed = startDate;

    // Log pour vérifier que les valeurs sont calculées
    print("Calculated lastDoneProposed: $newLastDoneProposed");
    print("Returning new values: lastDoneProposed = $newLastDoneProposed, dueDateLastDone = $newDueDateLastDone");

    // Retourner les valeurs calculées
    return {
      'lastDoneProposed': newLastDoneProposed,
      'dueDateLastDone': newDueDateLastDone,
      'dueDateLastDoneProposed': newDueDateLastDoneProposed,
      'lastDone': lastDone,
    };
  }

  static Map<String, DateTime?> _updateStartDateAndRepeatValues({
    required DateTime startDate,
    required DateTime? lastDone,
    required DateTime? lastDoneProposed,
    required int repeatDays,
  }) {
    // Calculer lastDoneProposed comme (new start date - new periodicité)
    DateTime newLastDoneProposed = startDate.subtract(Duration(days: repeatDays));

    // Le dueDateLastDone et dueDateLastDoneProposed sont mis à jour au new start date
    DateTime newDueDateLastDone = startDate;
    DateTime newDueDateLastDoneProposed = startDate;

    // Log pour vérifier les nouvelles valeurs calculées
    print("New Start Date: $startDate");
    print("New Last Done Proposed: $newLastDoneProposed");
    print("New Due Date Last Done: $newDueDateLastDone");
    print("New Due Date Last Done Proposed: $newDueDateLastDoneProposed");

    return {
      'lastDoneProposed': newLastDoneProposed,  // lastDoneProposed = new start date - new periodicité
      'dueDateLastDone': newDueDateLastDone,  // dueDateLastDone = new start date
      'dueDateLastDoneProposed': newDueDateLastDoneProposed,  // dueDateLastDoneProposed = new start date
      'lastDone': lastDone,  // Garder lastDone inchangé
    };
  }


  // Static method to format nullable DateTime values
  static String formatNullableDate(DateTime? date) {
    if (date == null) return 'No date';
    return DateHelper.dateTimeToString(date);
  }
}


import 'package:tidytime/utils/all_imports.dart';

class TaskScheduler {
  /// Calculate and distribute due dates for tasks across groups.
  Future<Map<int, DateTime>> calculateAndDistributeDueDates(
      Map<String, Map<String, dynamic>> groupTimeProportions) async {
    Map<int, DateTime> startDates = {};
    DateTime today = DateTime.now();

    // Étape 1: Ajuster les distributions de tâches pour correspondre aux proportions de temps
    await adjustForTimeProportion(
        groupTimeProportions, _getAllTasks(groupTimeProportions));

    // Générer l'ensemble des jours de la semaine exclus (ceux avec une proportion de temps de 0)
    Set<int> excludedWeekdays = groupTimeProportions.entries
        .where((entry) => (entry.value["timeProportion"] ?? 0) == 0)
        .map((entry) => _dayOfWeek(entry.key))
        .toSet();

    // Étape 2: Générer les dates de début pour chaque groupe
    Map<String, DateTime> groupStartDates = _generateGroupStartDates(
      groupTimeProportions.keys,
      today,
    );

    // Étape 3: Valider et redistribuer les tâches si nécessaire
    _validateAndRedistributeTasks(groupTimeProportions);

    // Étape 4: Traiter les tâches pour chaque groupe
    for (var entry in groupTimeProportions.entries) {
      String groupName = entry.key;
      var group = entry.value;

      // Valider le groupe et les tâches
      if (!_validateGroup(group, groupName)) continue;

      // Extraire les tâches
      List<Map<String, dynamic>> tasksInGroup = List<Map<String, dynamic>>.from(group["tasks"] ?? []);
      DateTime groupStartDate = groupStartDates[groupName]!;

      // Générer les dates flexibles
      List<DateTime> flexibleDates = FlexibleDateGenerator.generateFlexibleDates(
        tasksInGroup,
        groupStartDate,
      );

      // Retirer les dates qui tombent sur les jours exclus
      flexibleDates = flexibleDates
          .where((date) => !excludedWeekdays.contains(date.weekday))
          .toList();

      // Vérifier que flexibleDates n'est pas vide
      if (flexibleDates.isEmpty) {
        continue;
      }

      // Séparer les tâches en tâches quotidiennes et autres
      Map<String, List<Map<String, dynamic>>> taskGroups = _filterTasksByRepeatUnit(tasksInGroup);

      // Calculer la charge quotidienne initiale
      Map<DateTime, int> dailyLoad = DailyLoadManager.calculateDailyLoad(
        flexibleDates,
        tasksInGroup,
      );

      // Distribuer les tâches non quotidiennes
      startDates.addAll(_distributeNonDailyTasks(
        taskGroups["otherTasks"]!,
        flexibleDates,
        dailyLoad,
      ));

      // Traiter les tâches répétées quotidiennement
      await DailyTaskProcessor.processDailyTasks(
        taskGroups["dailyRepeatTasks"]!,
        today,
        groupName,
        groupStartDates,
      );

      // Mettre à jour les données du groupe
      group["tasks"] = [...taskGroups["dailyRepeatTasks"]!, ...taskGroups["otherTasks"]!];
      groupTimeProportions[groupName] = group;
    }
    return startDates;
  }

  /// Méthode pour valider et redistribuer les tâches si nécessaire.
  void _validateAndRedistributeTasks(Map<String, Map<String, dynamic>> groupTimeProportions) {
    for (var entry in groupTimeProportions.entries) {
      String groupName = entry.key;
      Map<String, dynamic> group = entry.value;
      List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(group["tasks"] ?? []);

      // Vérifier si les tâches respectent les proportions de temps
      if (tasks.isEmpty && group["timeProportion"] > 0) {
       _redistributeTasks(groupTimeProportions, groupName);
      }
    }
  }

  /// Redistribuer les tâches pour équilibrer les groupes.
  void _redistributeTasks(
      Map<String, Map<String, dynamic>> groupTimeProportions, String targetGroup) {
    List<Map<String, dynamic>> allTasks = _getAllTasks(groupTimeProportions);

    // Trier les tâches disponibles par valeur décroissante
    allTasks.sort((a, b) => (b["value"] ?? 0).compareTo(a["value"] ?? 0));

    for (var task in allTasks) {
      var targetGroupData = groupTimeProportions[targetGroup];
      if (targetGroupData == null) {
        continue;
      }
      var timeProportion = targetGroupData["timeProportion"] ?? 0.0;
      var targetTasks = targetGroupData["tasks"] as List<Map<String, dynamic>>?;
      if (targetTasks == null) {
        targetGroupData["tasks"] = <Map<String, dynamic>>[];
        targetTasks = targetGroupData["tasks"] as List<Map<String, dynamic>>;
      }

      // Vérifier si la tâche peut être assignée au groupe cible
      if (timeProportion > 0 && !targetTasks.contains(task)) {
        targetTasks.add(task);
        break;
      }
    }
  }

  /// Méthode auxiliaire pour obtenir le numéro du jour de la semaine à partir du nom du jour.
  int _dayOfWeek(String dayName) {
    Map<String, int> daysOfWeek = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };
    return daysOfWeek[dayName] ?? 0;
  }

  /// Générer les dates de début pour tous les groupes basés sur les jours de la semaine.
  Map<String, DateTime> _generateGroupStartDates(
      Iterable<String> groupKeys, DateTime today) {
    Map<String, DateTime> groupStartDates = {};
    Map<String, int> daysOfWeek = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    for (String day in groupKeys) {
      int targetDay = daysOfWeek[day]!;
      int daysUntilNext = (targetDay - today.weekday + 7) % 7;

      DateTime targetDate = today.add(Duration(days: daysUntilNext));
      groupStartDates[day] = targetDate;
    }

    return groupStartDates;
  }

  /// Filtrer les tâches en tâches répétées quotidiennement et autres.
  Map<String, List<Map<String, dynamic>>> _filterTasksByRepeatUnit(
      List<Map<String, dynamic>> tasksInGroup) {
    List<Map<String, dynamic>> dailyRepeatTasks = [];
    List<Map<String, dynamic>> otherTasks = [];

    for (var task in tasksInGroup) {
      if (task["repeatUnit"] == "days") {
        dailyRepeatTasks.add(Map<String, dynamic>.from(task));
      } else {
        otherTasks.add(Map<String, dynamic>.from(task));
      }
    }

    return {
      "dailyRepeatTasks": dailyRepeatTasks,
      "otherTasks": otherTasks,
    };
  }

  /// Distribuer les tâches non quotidiennes sur les dates flexibles.
  Map<int, DateTime> _distributeNonDailyTasks(
      List<Map<String, dynamic>> otherTasks,
      List<DateTime> flexibleDates,
      Map<DateTime, int> dailyLoad) {
    Map<int, DateTime> startDates = {};
    int currentDateIndex = 0;

    for (var task in otherTasks) {
      int repeatDays = TaskDueDateGenerator.convertRepeatUnitToDays(
        task["repeatUnit"],
        task["repeatValue"] ?? 1,
      );

      // Calculer les scores pour les dates potentielles de début
      Map<DateTime, double> dateScores = ProximityPenaltyManager.calculateDateScores(
        flexibleDates,
        dailyLoad,
        task,
        repeatDays,
        otherTasks,
      );

      // Trouver la date de début optimale
      DateTime optimalStartDate = ProximityPenaltyManager.findOptimalStartDate(dateScores);

      task["startDate"] = optimalStartDate;
      task["dueDates"] = TaskDueDateGenerator.generateDueDates(task, optimalStartDate);

      if (!task.containsKey("id") || task["id"] == null) {
        throw Exception("La tâche manque d'un 'id'.");
      }

      startDates[task["id"]] = optimalStartDate;

      // Mettre à jour la charge quotidienne
      dailyLoad = DailyLoadManager.recalculateDailyLoad(flexibleDates, otherTasks);

      // Passer à la date flexible suivante (rotation)
      currentDateIndex = (currentDateIndex + 1) % flexibleDates.length;
    }

    return startDates;
  }

  /// Valider la structure du groupe et les données des tâches.
  bool _validateGroup(Map<String, dynamic> group, String groupName) {
    if (!group.containsKey("tasks") || group["tasks"] == null) {
      return false;
    }

    List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(group["tasks"] ?? []);
    if (tasks.isEmpty) {
      return false;
    }

    TaskValidator.validateTasks(tasks);
    return true;
  }

  /// Récupérer toutes les tâches à partir des proportions de temps des groupes.
  List<Map<String, dynamic>> _getAllTasks(
      Map<String, Map<String, dynamic>> groupTimeProportions) {
    return groupTimeProportions.values
        .expand((group) => List<Map<String, dynamic>>.from(group["tasks"] ?? []))
        .toList();
  }
}


import 'package:tidytime/utils/all_imports.dart';

Future<void> distributeByTaskType(
    Map<String, Map<String, dynamic>> groupTimeProportions,
    List<Map<String, dynamic>> taskWeights,
    int answer) async {
  // Étape 1 : Extraire les tâches existantes
  List<Map<String, dynamic>> allTasks = [];
  for (var group in groupTimeProportions.values) {
    if (group["tasks"] != null) {
      allTasks.addAll(group["tasks"].cast<Map<String, dynamic>>());
    }
  }

  // Étape 2 : Trier les tâches selon l'ordre utilisateur
  switch (answer) {
    case 1: // Regrouper d'abord les tâches de valeur 3, puis 2, puis 1
      allTasks.sort((a, b) => (b["value"] as int).compareTo(a["value"] as int));
      break;
    case 2: // Regrouper d'abord les tâches de valeur 1, puis 2, puis 3
      allTasks.sort((a, b) => (a["value"] as int).compareTo(b["value"] as int));
      break;
    case 3: // Répartir équitablement les tâches entre les valeurs 1, 2 et 3
      allTasks = balanceTasksByValue(allTasks);
      break;
    case 4: // Regrouper uniquement les tâches d'une valeur à la fois (ex. : toutes les tâches de valeur 3, puis 2)
      allTasks = groupByValueSequentially(allTasks);
      break;
    default:
      print("Invalid answer for distributeByTaskType: $answer");
      return;
  }

  // Étape 3 : Redistribuer les tâches dans les groupes existants en respectant les proportions
  for (var groupName in groupTimeProportions.keys) {
    var group = groupTimeProportions[groupName]!;
    group["tasks"] = []; // Réinitialiser uniquement pour redistribuer proprement
    int totalValueAssigned = 0;

    // Calculer le maximum de valeur pour ce groupe
    int maxValue = group["totalValue"] ?? 0;

    // Ajouter les tâches jusqu'à ce que le groupe atteigne sa capacité
    while (allTasks.isNotEmpty && totalValueAssigned < maxValue) {
      var task = allTasks.removeAt(0); // Retirer la tâche de la liste globale
      int taskValue = task["value"] as int;
      if (totalValueAssigned + taskValue <= maxValue) {
        group["tasks"].add(task);
        totalValueAssigned += taskValue;
      } else {
        // Si le groupe atteint sa limite, replacer la tâche dans la liste
        allTasks.insert(0, task);
        break;
      }
    }

    // Log pour debug
    print("Group: $groupName, Total Value Assigned: $totalValueAssigned, Tasks: ${group["tasks"]?.map((t) => t["taskName"]).toList()}");
  }
}

// Helper : Répartir équitablement les tâches selon leur valeur
List<Map<String, dynamic>> balanceTasksByValue(List<Map<String, dynamic>> tasks) {
  List<Map<String, dynamic>> value1 = [];
  List<Map<String, dynamic>> value2 = [];
  List<Map<String, dynamic>> value3 = [];

  // Séparer les tâches selon leur valeur
  for (var task in tasks) {
    switch (task["value"]) {
      case 1:
        value1.add(task);
        break;
      case 2:
        value2.add(task);
        break;
      case 3:
        value3.add(task);
        break;
    }
  }

  // Répartition équilibrée
  List<Map<String, dynamic>> balancedTasks = [];
  int maxLength = [value1.length, value2.length, value3.length].reduce((a, b) => a > b ? a : b);
  for (int i = 0; i < maxLength; i++) {
    if (i < value3.length) balancedTasks.add(value3[i]);
    if (i < value2.length) balancedTasks.add(value2[i]);
    if (i < value1.length) balancedTasks.add(value1[i]);
  }

  return balancedTasks;
}

// Helper : Grouper par valeur séquentiellement
List<Map<String, dynamic>> groupByValueSequentially(List<Map<String, dynamic>> tasks) {
  List<Map<String, dynamic>> value1 = [];
  List<Map<String, dynamic>> value2 = [];
  List<Map<String, dynamic>> value3 = [];

  for (var task in tasks) {
    switch (task["value"]) {
      case 1:
        value1.add(task);
        break;
      case 2:
        value2.add(task);
        break;
      case 3:
        value3.add(task);
        break;
    }
  }

  return [...value3, ...value2, ...value1];
}

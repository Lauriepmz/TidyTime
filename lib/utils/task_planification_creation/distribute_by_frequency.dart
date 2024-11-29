import 'package:tidytime/utils/all_imports.dart';

Future<void> distributeByFrequency(
    Map<String, Map<String, dynamic>> groupTimeProportions,
    List<Map<String, dynamic>> taskWeights,
    int answer) async {
  switch (answer) {
    case 1:
    // Regrouper par fréquence : quotidien -> hebdomadaire -> mensuel
      for (var group in groupTimeProportions.values) {
        if (group["tasks"] == null) continue;
        organizeTasksByFrequency(group, ["daily", "weekly", "monthly"]);
      }
      break;
    case 2:
    // Répartir équitablement les tâches par fréquence
      for (var group in groupTimeProportions.values) {
        balanceTasksByFrequency(group);
      }
      break;
    case 3:
    // Placer les tâches quotidiennes/hebdomadaires au début de la semaine
      for (var group in groupTimeProportions.values) {
        prioritizeDailyWeekly(group);
      }
      break;
  }

  // Appliquer les contraintes de proportion de temps après la distribution
  await adjustForTimeProportion(groupTimeProportions, taskWeights);
}

void organizeTasksByFrequency(Map<String, dynamic> group, List<String> frequencyOrder) {
  if (group["tasks"] == null || group["tasks"].isEmpty) {
    print("No tasks to organize by frequency.");
    return;
  }

  List<Map<String, dynamic>> tasks = group["tasks"].cast<Map<String, dynamic>>();

  // Debug : Afficher les fréquences avant tri
  print("Tasks before sorting by frequency: ${tasks.map((t) => t['repeatUnit'])}");

  // Trier les tâches par ordre de fréquence
  tasks.sort((a, b) => frequencyOrder.indexOf(a["repeatUnit"]).compareTo(frequencyOrder.indexOf(b["repeatUnit"])));

  // Réattribuer les tâches triées au groupe
  group["tasks"] = tasks;

  // Debug : Afficher les tâches après tri
  print("Tasks after sorting by frequency: ${group['tasks'].map((t) => t['taskName'])}");
}

void balanceTasksByFrequency(Map<String, dynamic> group) {
  if (group["tasks"] == null || group["tasks"].isEmpty) {
    print("No tasks to balance by frequency.");
    return;
  }

  Map<String, List<Map<String, dynamic>>> frequencyBuckets = {
    "daily": [],
    "weekly": [],
    "monthly": []
  };

  // Catégoriser les tâches par fréquence
  for (var task in group["tasks"]) {
    String repeatUnit = task["repeatUnit"];
    if (frequencyBuckets.containsKey(repeatUnit)) {
      frequencyBuckets[repeatUnit]!.add(task);
    }
  }

  // Redistribuer équitablement les tâches
  List<Map<String, dynamic>> balancedTasks = [];
  while (frequencyBuckets.values.any((bucket) => bucket.isNotEmpty)) {
    for (var frequency in frequencyBuckets.keys) {
      if (frequencyBuckets[frequency]!.isNotEmpty) {
        balancedTasks.add(frequencyBuckets[frequency]!.removeAt(0));
      }
    }
  }

  // Réattribuer les tâches équilibrées au groupe
  group["tasks"] = balancedTasks;

  // Debug : Afficher les tâches après répartition
  print("Tasks after balancing by frequency: ${group['tasks'].map((t) => t['taskName'])}");
}

void prioritizeDailyWeekly(Map<String, dynamic> group) {
  if (group["tasks"] == null || group["tasks"].isEmpty) {
    print("No tasks to prioritize daily/weekly.");
    return;
  }

  List<Map<String, dynamic>> dailyTasks = [];
  List<Map<String, dynamic>> weeklyTasks = [];
  List<Map<String, dynamic>> otherTasks = [];

  // Catégoriser les tâches
  for (var task in group["tasks"]) {
    switch (task["repeatUnit"]) {
      case "daily":
        dailyTasks.add(task);
        break;
      case "weekly":
        weeklyTasks.add(task);
        break;
      default:
        otherTasks.add(task);
        break;
    }
  }

  // Réorganiser : quotidien + hebdomadaire + autres
  group["tasks"] = [...dailyTasks, ...weeklyTasks, ...otherTasks];

  // Debug : Afficher les tâches après réorganisation
  print("Tasks after prioritizing daily/weekly: ${group['tasks'].map((t) => t['taskName'])}");
}

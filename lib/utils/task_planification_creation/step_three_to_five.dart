import 'package:tidytime/utils/all_imports.dart';

Future<void> applyUserPreferencesToTaskDistribution(
    Map<String, Map<String, dynamic>> groupTimeProportions,
    List<Map<String, dynamic>> taskWeights) async {
  // Fetch user preferences from the QuizzResultsBox
  var quizResultsBox = Hive.box<QuizzResults>('QuizzResultsBox');

  // Convert Hive objects to a list of maps for easier handling
  List<Map<String, dynamic>> userPreferences = quizResultsBox.values
      .map((entry) => {
    "question": entry.question,
    "rank": entry.rank,
    "answer": entry.answer,
  })
      .toList();

  // Debug: Log user preferences for distribution
  print("User Preferences Loaded: $userPreferences");

  // Sort preferences by rank (low rank first)
  userPreferences.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));

  // Apply each preference in order of rank
  for (var preference in userPreferences) {
    int questionNumber = preference['question'];
    int answer = preference['answer'];

    print("Applying preference: Question $questionNumber, Answer $answer");

    switch (questionNumber) {
      case 1: // Frequency-based distribution
        await distributeByFrequency(groupTimeProportions, taskWeights, answer);
        break;
      case 2: // Task type-based distribution
        await distributeByTaskType(groupTimeProportions, taskWeights, answer);
        break;
      case 3: // Room-based distribution
        await distributeByRoomPreference(groupTimeProportions, taskWeights, answer);
        break;
      default:
        print("Warning: Unknown question number $questionNumber");
    }

    // Debug: Log groupTimeProportions after each preference application
    for (var day in groupTimeProportions.keys) {
      // Vérifiez si le groupe pour le jour existe
      var group = groupTimeProportions[day];
      if (group == null) {
        print("Day: $day has no tasks assigned due to null group.");
        continue;
      }

      var tasks = group["tasks"] ?? [];
      int totalValue = tasks.fold(0, (sum, task) => sum + (task["value"] as int));
      double proportion = group["timeProportion"] ?? 0.0;

      print(
          "After Question $questionNumber: Day: $day, Total Value: $totalValue, Expected Proportion: $proportion, Tasks: ${tasks.map((t) => t["taskName"]).toList()}");
    }
  }

    // Debug: Final state after applying all preferences
  print("Final groupTimeProportions after applying user preferences:");
  groupTimeProportions.forEach((day, data) {
    print("Day: $day, Data: $data");
  });
}

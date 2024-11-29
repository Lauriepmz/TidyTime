import 'package:tidytime/utils/all_imports.dart';

class MultipleChoiceQuestion extends StatelessWidget {
  final String questionText;
  final List<String> options;
  final int? selectedOption;
  final ValueChanged<int?> onOptionSelected;

  const MultipleChoiceQuestion({
    super.key,
    required this.questionText,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          questionText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...options.asMap().entries.map((entry) {
          int index = entry.key + 1; // Answer as 1-based index
          String option = entry.value;
          return ListTile(
            title: Text(option),
            leading: Radio<int>(
              value: index,
              groupValue: selectedOption,
              onChanged: (value) {
                // Call the onOptionSelected only, without logging here
                onOptionSelected(value);
              },
            ),
          );
        }),
      ],
    );
  }
}

class IntensityPreferenceQuestion extends StatelessWidget {
  final int? selectedOption;
  final ValueChanged<int?> onOptionSelected;

  IntensityPreferenceQuestion({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MultipleChoiceQuestion(
      questionText: "How do you prefer to handle tasks with varying frequencies?",
      options: [
        "Prioritize frequent tasks, such as daily and weekly, ensuring they’re scheduled consistently before less frequent tasks.",
        "Balance between frequent and infrequent tasks to avoid burnout on high-frequency tasks.",
        "Group high-frequency tasks at the beginning of the week and reserve less frequent tasks for the weekend."
      ],
      selectedOption: selectedOption,
      onOptionSelected: onOptionSelected, // Directly pass the function without additional logic
    );
  }
}

class RepetitiveTaskPreferenceQuestion extends StatelessWidget {
  final int? selectedOption;
  final ValueChanged<int?> onOptionSelected;

  RepetitiveTaskPreferenceQuestion({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MultipleChoiceQuestion(
      questionText: "What priority should be given to task types across all rooms?",
      options: [
        "Focus on high-effort tasks (e.g., deep cleaning) before regular maintenance tasks.",
        "Prioritize maintenance tasks first, keeping all rooms generally clean before deep cleaning.",
        "Alternate between high and low-effort tasks to balance the workload across sessions.",
        "Focus on specific task groups each session (e.g., all dusting tasks in one session, all vacuuming tasks in another)."
      ],
      selectedOption: selectedOption,
      onOptionSelected: onOptionSelected, // Directly pass the function without additional logic
    );
  }
}

class CustomPlaceholderQuestion extends StatelessWidget {
  final int? selectedResponse;
  final ValueChanged<int?> onResponseSelected;

  CustomPlaceholderQuestion({
    super.key,
    required this.selectedResponse,
    required this.onResponseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MultipleChoiceQuestion(
      questionText: "How would you like tasks to be organized within each room?",
      options: [
        "Focus on completing a single task type across all rooms before moving to the next (e.g., dusting in all rooms, then vacuuming in all rooms).",
        "Group all cleaning tasks for a single room together, completing each room fully before moving on to the next.",
        "Organize based on task priority within each room (e.g., high-use areas cleaned more frequently)."
        "Prioritize tasks based on their impact on cleanliness (e.g., bathrooms and kitchens over lesser-used rooms).",
      ],
      selectedOption: selectedResponse,
      onOptionSelected: onResponseSelected, // Directly pass the function without additional logic
    );
  }
}

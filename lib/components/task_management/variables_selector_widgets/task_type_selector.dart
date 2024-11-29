import 'package:tidytime/utils/all_imports.dart';

class TaskTypeSelectorWidget extends StatelessWidget {
  final List<String> selectedTaskTypes;
  final List<String> taskTypeChoices;
  final Function(String) onTaskTypeSelected; // Function passed from parent

  const TaskTypeSelectorWidget({
    super.key,
    required this.selectedTaskTypes,
    required this.taskTypeChoices,
    required this.onTaskTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Task Type(s)', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          SingleChildScrollView(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: taskTypeChoices.map((taskType) {
                return FilterChip(
                  label: Text(taskType),
                  selected: selectedTaskTypes.contains(taskType),
                  onSelected: (bool selected) {
                    onTaskTypeSelected(taskType); // Call parent function
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

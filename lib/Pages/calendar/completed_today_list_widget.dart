import 'package:tidytime/utils/all_imports.dart';

class CompletedTodayList extends StatelessWidget {
  final List<Task> tasksCompletedToday;

  const CompletedTodayList({
    super.key,
    required this.tasksCompletedToday,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // Ajout du contexte de traduction

    if (tasksCompletedToday.isEmpty) {
      return const SizedBox(); // If no tasks, show nothing
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            localization?.completedTasks ?? "Completed tasks",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150, // Limit the height to avoid taking up too much space
          child: ListView.builder(
            itemCount: tasksCompletedToday.length,
            itemBuilder: (context, index) {
              final Task task = tasksCompletedToday[index];

              return TaskItem(
                task: task,
                onTaskCompleted: () {}, // No action, already completed
                onTaskDetails: () {
                  AgendaTaskService.navigateToTaskDetail(context, task.id!);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

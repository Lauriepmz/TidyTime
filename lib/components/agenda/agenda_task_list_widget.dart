import 'package:tidytime/utils/all_imports.dart';

class AgendaWidget extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onTaskUpdated;

  const AgendaWidget({
    super.key,
    required this.tasks,
    required this.onTaskUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text("No tasks for today", style: TextStyle(fontSize: 16)),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final Task task = tasks[index];

          return TaskItem(
            task: task,
            onTaskCompleted: () async {
              await AgendaTaskService.markTaskAsCompleted(
                context: context, // Pass the current BuildContext
                task: task,       // Pass the specific task
                onTaskUpdated: onTaskUpdated, // Use the provided callback for updating tasks
              );
            },
            onTaskDetails: () {
              AgendaTaskService.navigateToTaskDetail(context, task.id!);
            },
          );
        },
        childCount: tasks.length,
      ),
    );
  }
}

import 'package:tidytime/utils/all_imports.dart';

class TaskChecklistWidget extends StatefulWidget {
  const TaskChecklistWidget({super.key});

  @override
  TaskChecklistWidgetState createState() => TaskChecklistWidgetState();
}

class TaskChecklistWidgetState extends State<TaskChecklistWidget> {

  Future<void> _onTaskChecked(int taskId, bool isChecked) async {
    final SessionBloc sessionBloc = context.read<SessionBloc>();
     sessionBloc.add(UpdateTaskStatus(taskId, isChecked));

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state is SessionInProgress) {
          final incompleteTasks = state.tasks.where((task) => !state.completedTaskIds.contains(task.id!)).toList();
          final completedTasks = state.tasks.where((task) => state.completedTaskIds.contains(task.id!)).toList();

          return ListView(
            children: [
              ListTile(
                title: const Text('Incomplete Tasks'),
              ),
              // Affichage des tâches incomplètes avec des cases à cocher
              ...incompleteTasks.map((task) {
                return CheckboxListTile(
                  title: Text(task.taskName),
                  value: state.completedTaskIds.contains(task.id!),
                  onChanged: (bool? value) {
                    if (value != null) {
                      _onTaskChecked(task.id!, value);  // Dispatch the event with taskId and checkbox state
                    }
                  },
                );
              }),
              ListTile(
                title: const Text('Completed Tasks'),
              ),
              // Affichage des tâches complétées avec le temps écoulé
              ...completedTasks.map((task) {
                return ListTile(
                  title: Text(task.taskName),
                  subtitle: Text('Elapsed Time: ${state.elapsedTimeMap[task.id] ?? 'N/A'}'),  // Temps écoulé de la session
                  trailing: Checkbox(
                    value: true,
                    onChanged: (bool? value) {
                      if (value != null && !value) {
                        _onTaskChecked(task.id!, false);  // Suivre l'état de la tâche si elle devient incomplète
                      }
                    },
                  ),
                );
              }),
            ],
          );
        } else if (state is SessionStopped) {
          return const Center(child: Text("Session completed."));
        } else {
          return const Center(child: Text("No tasks available."));
        }
      },
    );
  }
}

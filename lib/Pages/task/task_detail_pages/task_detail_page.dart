import 'package:tidytime/utils/all_imports.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;
  final VoidCallback? onTaskUpdated;
  final VoidCallback? onTaskDeleted;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.onTaskUpdated,
    this.onTaskDeleted,
  });

  @override
  TaskDetailPageState createState() => TaskDetailPageState();
}

class TaskDetailPageState extends State<TaskDetailPage> {
  late TaskManagementHandler _taskHandler;
  String _dueDateCalculationMethod = UserSettings.dueDateLastDone;
  List<DateTime> _completionLog = [];  // Pour stocker le log de complétion
  List<TaskTimeLog> _taskTimeLogs = [];  // Log de temps écoulé

  @override
  void initState() {
    super.initState();
    _taskHandler = TaskManagementHandler(
      TaskCompletionService(DatabaseHelper.instance, TaskDetailsFetcher()),
    );
    _loadSettings();
    _loadCompletionLog();  // Charger les logs de complétion
    _loadTaskTimeLogs();  // Charger les logs de temps
  }

  // Charger la méthode de calcul de due date préférée par l'utilisateur
  Future<void> _loadSettings() async {
    _dueDateCalculationMethod = await UserSettings().getDueDateCalculationMethod();
    setState(() {});  // Mettre à jour l'UI une fois que la méthode de calcul est récupérée
  }

  // Charger le log de complétion
  Future<void> _loadCompletionLog() async {
    List<DateTime> log = await _taskHandler.fetchCompletionLog(widget.taskId);
    setState(() {
      _completionLog = log;
    });
  }

  Future<void> _loadTaskTimeLogs() async {
    TaskTimeLogger timeLogger = TaskTimeLogger(taskId: widget.taskId);
    List<TaskTimeLog> logs = await timeLogger.fetchTaskLogs();

    // Debugging: Assurez-vous que les logs sont bien chargés dans l'état
    print('Loaded ${logs.length} time logs for Task ${widget.taskId}');
    for (var log in logs) {
      print('Log Date: ${log.logDate}, Time Took: ${log.timeTook} seconds');
    }

    setState(() {
      _taskTimeLogs = logs;
    });
  }


  // Récupérer les détails de la tâche avec TaskManagementHandler
  Future<Task> _fetchTaskDetails() async {
    return await _taskHandler.getTaskObject(widget.taskId);  // Utiliser TaskManagementHandler pour récupérer les détails
  }

  void _markTaskAsCompleted(Task task) async {
    print("Marking task as completed...");

    // Appeler `markTaskAsCompleted` avec le callback pour rafraîchir
    await _taskHandler.markTaskAsCompleted(
      context,
      task,
          () {
        // Callback pour rafraîchir les données après Undo
        setState(() {
          _fetchTaskDetails(); // Met à jour les détails de la tâche
          _loadCompletionLog(); // Recharge les logs de complétion
        });
      },
    );

    print("Task marked as completed.");
  }


  // Éditer une tâche
  void _editTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskPage(taskId: widget.taskId),
      ),
    ).then((updatedTask) async {
      if (updatedTask != null && updatedTask is Task) {
        await _taskHandler.editTask(widget.taskId, updatedTask);

        setState(() {
          _fetchTaskDetails();
        });

        if (widget.onTaskUpdated != null) {
          widget.onTaskUpdated!();
        }
      }
    });
  }

  // Supprimer une tâche
  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _taskHandler.deleteTask(widget.taskId).then((_) {
                  Navigator.pop(context, true);
                  if (widget.onTaskDeleted != null) widget.onTaskDeleted!();
                }).catchError((e) {
                  debugPrint("Error occurred while deleting task: $e");
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Task Details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteTask(context),
          ),
        ],
      ),
      body: FutureBuilder<Task>(
        future: _fetchTaskDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No task details available.'));
          } else {
            final task = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Task Name: ${task.taskName}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  Text('Room: ${getTranslatedRoomName(context, task.room)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Repeat: ${task.repeatValue} ${task.repeatUnit}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Text('Start Date: ${DateHelper.dateTimeToString(task.startDate)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),

                  // Affichage conditionnel basé sur la méthode de calcul des due dates choisie
                  if (_dueDateCalculationMethod == UserSettings.dueDateLastDone) ...[
                    Text('Last Done: ${DateCalculator.formatNullableDate(task.lastDone)}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text('Due Date (Last Done): ${DateCalculator.formatNullableDate(task.dueDateLastDone)}', style: const TextStyle(fontSize: 16)),
                  ] else ...[
                    Text('Last Done: ${DateCalculator.formatNullableDate(task.lastDone)}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text('Last Done Proposed: ${DateCalculator.formatNullableDate(task.lastDoneProposed)}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Text('Due Date (Proposed): ${DateCalculator.formatNullableDate(task.dueDateLastDoneProposed)}', style: const TextStyle(fontSize: 16)),
                  ],

                  const SizedBox(height: 20),

                  // Log de complétion
                  if (_completionLog.isNotEmpty) ...[
                    const Text('Completion Log:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: _completionLog.length,
                        itemBuilder: (context, index) {
                          return Text(DateHelper.dateTimeToString(_completionLog[index]));
                        },
                      ),
                    ),
                  ] else
                    const Text('No completions logged yet.', style: TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  // Log du temps écoulé
                  if (_taskTimeLogs.isNotEmpty) ...[
                    const Text('Time Logs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: _taskTimeLogs.length,
                        itemBuilder: (context, index) {
                          final log = _taskTimeLogs[index];
                          return Text(
                            'Log Date: ${DateHelper.dateTimeToString(log.logDate)}, '
                                'Time Took: ${log.timeTook} seconds',
                          );
                        },
                      ),
                    ),
                  ] else
                    const Text('No time logs available.', style: TextStyle(fontSize: 16)),

                  const SizedBox(height: 20),

                  // Bouton pour marquer la tâche comme complétée
                  ElevatedButton(
                    onPressed: () async {
                      _markTaskAsCompleted(task);
                    },
                    child: const Text('Mark as Completed'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

import 'package:tidytime/utils/all_imports.dart';

class CleaningSessionTransitionPage extends StatefulWidget {
  final TaskService taskService;  // Inject the TaskService
  final VoidCallback onShowFloatingTimer; // Callback to show floating timer
  final VoidCallback onHideFloatingTimer; // Callback to hide floating timer

  const CleaningSessionTransitionPage({
    super.key,
    required this.taskService,  // Pass the taskService
    required this.onShowFloatingTimer,  // Pass the callback to show floating timer
    required this.onHideFloatingTimer,  // Pass the callback to hide floating timer
  });

  @override
  CleaningSessionTransitionPageState createState() => CleaningSessionTransitionPageState();
}

class CleaningSessionTransitionPageState extends State<CleaningSessionTransitionPage> {
  List<Task> _tasks = [];  // List to store fetched tasks

  @override
  void initState() {
    super.initState();
    _loadTasks();  // Load tasks when the page opens
    widget.onHideFloatingTimer();  // Hide the floating timer by default
  }

  // Method to load tasks from the TaskService
  Future<void> _loadTasks() async {
    final tasksDueTodayMaps = await widget.taskService.getTasksDueTodayOrOverdue();

    setState(() {
      _tasks = tasksDueTodayMaps.map((taskMap) => Task.fromMap(taskMap)).toList();
    });
  }

  // Show the confirmation dialog before starting the session
  Future<void> _showStartCleaningSessionDialog() async {
    bool shouldStart = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Start Cleaning Session'),
          content: const Text('Do you want to start the cleaning session?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Start'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;

    if (shouldStart) {
      // Once confirmed, navigate to CleaningSessionPage with the modified task list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CleaningSessionPage(
            onHideFloatingTimer: widget.onHideFloatingTimer,  // Ensure the floating timer is hidden
            onShowFloatingTimer: widget.onShowFloatingTimer,  // Pass the callback to show floating timer
            timerService: context.read<TimerService>(),
            modifiedTasks: _tasks,  // Pass the modified task list
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Prepare Cleaning Session',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Retour à la page précédente
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              onReorder: _onReorder,
              children: _tasks.asMap().entries.map((entry) {
                int index = entry.key;
                Task task = entry.value;
                return ListTile(
                  key: ValueKey(task.id),  // Important for ReorderableListView
                  title: Text(task.taskName),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeTask(index),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showStartCleaningSessionDialog,  // Confirm and navigate to the next page
              child: const Text('Start Cleaning Session'),
            ),
          ),
        ],
      ),
    );
  }

  // Method to reorder the tasks in the list
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
  }

  // Method to remove a task from the list
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }
}

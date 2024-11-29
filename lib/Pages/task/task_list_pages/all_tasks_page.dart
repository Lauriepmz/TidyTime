import 'package:tidytime/utils/all_imports.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  AllTasksPageState createState() => AllTasksPageState();
}

class AllTasksPageState extends State<AllTasksPage> with TaskSelectionMixin {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    refreshTasks();  // Utilisez la méthode du mixin pour initialiser les tâches
  }

  @override
  void refreshTasks() {
    setState(() {
      _tasksFuture = DatabaseHelper.instance.getAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "All Tasks",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Retourner à la page précédente
          },
        ),
        actions: isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteSelectedTasks,
          ),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: toggleSelectionMode,
          ),
        ]
            : [], // Pas d'actions lorsque le mode sélection est inactif
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found'));
          } else {
            final tasks = List<Map<String, dynamic>>.from(snapshot.data!);
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return GestureDetector(
                  onLongPress: () {
                    if (!isSelectionMode) {
                      toggleSelectionMode();  // Activer le mode de sélection
                    }
                    toggleTaskSelection(task['id'] as int);
                  },
                  onTap: () {
                    if (isSelectionMode) {
                      toggleTaskSelection(task['id'] as int);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailPage(
                            taskId: task['id'] as int,
                            onTaskUpdated: refreshTasks,
                            onTaskDeleted: refreshTasks,
                          ),
                        ),
                      ).then((_) => refreshTasks());
                    }
                  },
                  child: Container(
                    color: selectedTaskIds.contains(task['id']) ? Color(0xFFD5E3FD) : Colors.white, // Changer la couleur si sélectionné
                    child: ListTile(
                      title: Text(task['taskName'] ?? 'No Task Name'),
                      subtitle: Text('Room: ${getTranslatedRoomName(context, task['room'] ?? '')}'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

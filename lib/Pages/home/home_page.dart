import 'package:tidytime/utils/all_imports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<String>> _roomsWithTasks;
  late Future<bool> _hasTasks;
  TaskService taskService = TaskService(); // Utiliser TaskService pour charger les tâches et les pièces

  @override
  void initState() {
    super.initState();
    _roomsWithTasks = taskService.getRoomsWithTasks(); // Charger les pièces avec des tâches
    _hasTasks = taskService.hasTasks(); // Vérifier s'il y a des tâches
  }

  Future<void> _refreshRooms() async {
    List<String> rooms = await taskService.getRoomsWithTasks();
    setState(() {
      _roomsWithTasks = Future.value(rooms);
      _hasTasks = taskService.hasTasks(); // Re-vérifier s'il y a des tâches après le rafraîchissement
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // Accès à la localisation
    final double screenHeight = MediaQuery.of(context).size.height;
    final double dashboardHeight = screenHeight * 0.45;

    return Scaffold(
      body: FutureBuilder<bool>(
        future: _hasTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('${localization?.errorMessage ?? "Error"}: ${snapshot.error}');
          }

          final bool hasTasks = snapshot.data ?? false;

          return Stack(
            children: [
              // Contenu principal
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: dashboardHeight,
                    pinned: true,
                    flexibleSpace: const FlexibleSpaceBar(
                      background: DashboardWidget(), // DashboardWidget gère les tâches
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          ButtonStyles.gradientButton(
                            label: localization?.allTasks ?? "All Tasks",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllTasksPage(),
                                ),
                              );
                            },
                            fontSize: 16,
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<List<String>>(
                            future: _roomsWithTasks,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('${localization?.errorMessage ?? "Error"}: ${snapshot.error}');
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Text(localization?.noRoomsFound ?? 'No rooms with tasks found');
                              } else {
                                final rooms = snapshot.data!;
                                return RoomListWidget(rooms: rooms, onRefresh: _refreshRooms);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Utiliser EmptyTaskContainer lorsqu'il n'y a pas de tâches
              if (!hasTasks)
                Positioned.fill(
                  child: EmptyTaskContainer(
                    message: localization?.createFirstTaskMessage ?? 'Create your first task',
                    oncreateTask: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskCreationTransitionPage(),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

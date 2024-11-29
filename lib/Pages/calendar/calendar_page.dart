import 'package:tidytime/utils/all_imports.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Task> _tasksForSelectedDay = [];
  List<Task> _tasksCompletedForSelectedDay = [];
  Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _loadTasksForSelectedDay();
    _loadTasksForAllDays();
    _loadTasksCompletedForDate(_selectedDay); // Charger les tâches complétées pour la date sélectionnée
  }

  Future<void> _loadTasksForSelectedDay() async {
    // Fetch tasks for the selected day
    List<Task> tasks = await AgendaService.getTasksForDay(_selectedDay);

    // Check if the selected day is today
    if (isSameDay(_selectedDay, DateTime.now())) {
      // Fetch overdue tasks and ensure no duplicates with today's tasks
      List<Task> overdueTasks = await AgendaService.getOverdueTasks(DateTime.now());
      tasks = [
        ...tasks,
        ...overdueTasks.where((overdueTask) =>
        !tasks.any((task) => task.id == overdueTask.id)) // Avoid duplicates
      ];
    }

    setState(() {
      _tasksForSelectedDay = tasks;
    });
  }

  Future<void> _loadTasksCompletedForDate(DateTime date) async {
    List<Task> completedTasks = await AgendaService.getTasksCompletedForDate(date);
    setState(() {
      _tasksCompletedForSelectedDay = completedTasks;
    });
  }

  Future<void> _loadTasksForAllDays() async {
    Map<DateTime, List<Task>> tasksByDate = await AgendaService.getTasksForDateRange(
      DateTime.now().subtract(const Duration(days: 90)),
      DateTime.now().add(const Duration(days: 90)),
    );
    setState(() {
      _tasksByDate = tasksByDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // Ajout de la localisation

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Calendar Section
          SliverToBoxAdapter(
            child: CalendarWidget(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              tasksByDate: _tasksByDate,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadTasksForSelectedDay();
                _loadTasksCompletedForDate(selectedDay); // Charger les tâches complétées pour la date sélectionnée
              },
            ),
          ),
          // Agenda Section
          if (_tasksForSelectedDay.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final task = _tasksForSelectedDay[index];
                  return TaskItem(
                    task: task,
                    onTaskCompleted: () async {
                      await AgendaTaskService.markTaskAsCompleted(
                        context: context, // Pass the current BuildContext
                        task: task, // Pass the current task
                        onTaskUpdated: () {
                          // Refresh tasks after undo or completion
                          _loadTasksForSelectedDay();
                          _loadTasksForAllDays();
                          _loadTasksCompletedForDate(_selectedDay);
                        },
                      );
                    },
                    onTaskDetails: () {
                      AgendaTaskService.navigateToTaskDetail(context, task.id!);
                    },
                  );
                },
                childCount: _tasksForSelectedDay.length,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    localization?.noTasksForSelectedDay ?? "No tasks for the selected day",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          // Completed Tasks for the Selected Day Section
          if (_tasksCompletedForSelectedDay.isNotEmpty)
            SliverToBoxAdapter(
              child: CompletedTodayList(tasksCompletedToday: _tasksCompletedForSelectedDay),
            ),
        ],
      ),
    );
  }
}

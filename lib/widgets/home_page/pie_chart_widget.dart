import 'package:tidytime/utils/all_imports.dart';

class PieChartWidget extends StatefulWidget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final double chartSize;

  const PieChartWidget({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.chartSize,
  });

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int totalTasks = 0;  // To-Do tasks
  int completedTasks = 0;  // Completed tasks
  TaskService taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _loadTaskData();  // Load task data based on date range
  }

  Future<void> _loadTaskData() async {
    // Use the date range to calculate total and completed tasks
    int tasksInRange = await taskService.calculateTotalTasksInRange(widget.endDate); // To-Do tasks
    int completedInRange = await taskService.calculateCompletedTasksInRange(widget.startDate, widget.endDate); // Completed tasks

    // Ensure the widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      totalTasks = tasksInRange; // To-Do tasks
      completedTasks = completedInRange; // Completed tasks
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the total value for the chart (to-do + completed)
    int chartTotal = totalTasks + completedTasks;

    // Calculate the percentage of completed tasks
    double completedPercentage = chartTotal > 0 ? (completedTasks / chartTotal) * 100 : 0;
    double toDoPercentage = chartTotal > 0 ? (totalTasks / chartTotal) * 100 : 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.chartSize,
          height: widget.chartSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: widget.chartSize / 2 - 12,
                  sections: [
                    PieChartSectionData(
                      color: const Color(0xFF85CD88),  // Green for completed tasks
                      value: completedPercentage,
                      radius: 6,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFFEA6D6A),  // Red for to-do tasks
                      value: toDoPercentage,
                      radius: 6,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'To do',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalTasks',  // To-Do tasks
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFEA6D6A)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Completed',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$completedTasks',  // Completed tasks
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF85CD88)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}

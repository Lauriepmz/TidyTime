import 'package:tidytime/utils/all_imports.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  DashboardWidgetState createState() => DashboardWidgetState();
}

class DashboardWidgetState extends State<DashboardWidget> {
  int overdueTasks = 0;
  bool _showMessage = false;

  TaskService taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _loadOverdueTasks();
  }

  Future<void> _loadOverdueTasks() async {
    int calculatedOverdueTasks = await taskService.calculateOverdueTasks();
    setState(() {
      overdueTasks = calculatedOverdueTasks;
    });
  }

  void _toggleMessage() {
    setState(() {
      _showMessage = !_showMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // Accès aux traductions
    double screenWidth = MediaQuery.of(context).size.width;
    double chartSize = screenWidth * 0.42;

    DateTime today = DateTime.now();
    DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Monday
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6)); // Sunday

    return GestureDetector(
      onTap: _showMessage ? _toggleMessage : null,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy', Localizations.localeOf(context).toString())
                      .format(DateTime.now())
                      .toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // PieChart for Today's Tasks
                    PieChartWidget(
                      title: localization?.today ?? 'Today',
                      startDate: today,
                      endDate: today,
                      chartSize: chartSize,
                    ),
                    const SizedBox(width: 20),
                    // PieChart for This Week's Tasks
                    PieChartWidget(
                      title: localization?.thisWeek ?? 'This Week',
                      startDate: startOfWeek,
                      endDate: endOfWeek,
                      chartSize: chartSize,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleMessage,
              child: Image.asset(
                overdueTasks > 0 ? 'assets/images/warning-sign.png' : 'assets/images/checked.png',
                width: 20,
                height: 20,
              ),
            ),
          ),
          if (_showMessage)
            Positioned(
              top: 40,
              right: 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Text(
                  overdueTasks > 0
                      ? localization?.overdueTasksMessage(overdueTasks) ??
                      'You have $overdueTasks overdue task(s) waiting to be completed.'
                      : localization?.allTasksUpToDateMessage ?? 'Great job! All tasks are up-to-date.',
                  style: TextStyle(
                    fontSize: 14,
                    color: overdueTasks > 0 ? Colors.redAccent : Colors.green,
                  ),
                  softWrap: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

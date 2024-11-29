import 'package:tidytime/utils/all_imports.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<dynamic>> tasksByDate;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.tasksByDate,
    required this.onDaySelected,
  });

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  /// Gère les glissements verticaux pour changer de vue (mois/semaine)
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 && _calendarFormat != CalendarFormat.week) {
      setState(() {
        _calendarFormat = CalendarFormat.week;
      });
    } else if (details.delta.dy > 0 && _calendarFormat != CalendarFormat.month) {
      setState(() {
        _calendarFormat = CalendarFormat.month;
      });
    }
  }

  /// Capitalise la première lettre d'une chaîne
  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // Accès aux traductions

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      child: TableCalendar(
        locale: Localizations.localeOf(context).toString(), // Définit la langue du calendrier
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: widget.focusedDay,
        selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
        onDaySelected: widget.onDaySelected,
        eventLoader: (day) => _eventLoader(day),
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          formatButtonVisible: false, // Optional: Hide format toggle button
        ),
        calendarBuilders: CalendarBuilders(
          headerTitleBuilder: (context, day) {
            final locale = Localizations.localeOf(context).toString();
            final translatedMonth = DateFormat.yMMMM(locale).format(day);
            final capitalizedMonth = capitalizeFirstLetter(translatedMonth);
            return Center(
              child: Text(
                capitalizedMonth,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          },
          markerBuilder: (context, day, events) =>
              _buildMarker(context, day, events, localization),
        ),
      ),
    );
  }

  /// Charge les événements pour un jour donné
  List<Task> _eventLoader(DateTime day) {
    final DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    final DateTime normalizedToday = DateTime.now();

    List<Task> tasksForDay = (widget.tasksByDate[normalizedDay] ?? []).cast<Task>();

    if (isSameDay(day, normalizedToday)) {
      final List<Task> overdueTasks = widget.tasksByDate.entries
          .where((entry) => entry.key.isBefore(normalizedToday))
          .expand((entry) => entry.value.cast<Task>())
          .where((task) =>
      task.dueDate!.isBefore(normalizedToday) &&
          !isSameDay(task.dueDate, normalizedToday))
          .toList();
      final List<Task> allTasksToday = [...tasksForDay, ...overdueTasks];
      return allTasksToday;
    } else {
      tasksForDay = tasksForDay
          .where((task) =>
      task.dueDate == null ||
          task.dueDate!.isAfter(normalizedDay) ||
          isSameDay(task.dueDate, normalizedDay))
          .toList();
      return tasksForDay;
    }
  }

  /// Construit un marqueur pour les jours avec des tâches
  Widget _buildMarker(BuildContext context, DateTime day, List<dynamic> events,
      AppLocalizations? localization) {
    final DateTime today = DateTime.now();

    if (isSameDay(day, today)) {
      final int totalTasksForToday = events.length;
      return _buildTaskMarker(localization, totalTasksForToday);
    } else if (events.isNotEmpty) {
      return _buildTaskMarker(localization, events.length);
    }

    return const SizedBox();
  }

  /// Construit un marqueur visuel pour les tâches
  Widget _buildTaskMarker(AppLocalizations? localization, int taskCount) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.yellow,
        shape: BoxShape.circle,
      ),
      width: 20,
      height: 20,
      child: Center(
        child: Text(
          localization?.taskCountMarker(taskCount) ?? '$taskCount',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

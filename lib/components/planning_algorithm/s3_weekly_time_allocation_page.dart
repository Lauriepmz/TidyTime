import 'package:tidytime/utils/all_imports.dart';

class WeeklyTimeAllocationPage extends StatefulWidget {
  final Function(Map<String, double>) onTimeAllocated;

  const WeeklyTimeAllocationPage({super.key, required this.onTimeAllocated});

  @override
  _WeeklyTimeAllocationPageState createState() => _WeeklyTimeAllocationPageState();
}

class _WeeklyTimeAllocationPageState extends State<WeeklyTimeAllocationPage> {
  Map<String, double> dailyTimeAllocation = {
    'Monday': 0,
    'Tuesday': 0,
    'Wednesday': 0,
    'Thursday': 0,
    'Friday': 0,
    'Saturday': 0,
    'Sunday': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadTimeAllocationLogs(); // Charger les données sauvegardées au démarrage de la page
  }

  Future<void> _loadTimeAllocationLogs() async {
    final box = Hive.box<TimeAllocation>('tempTimeAllocationBox'); // Assurez-vous que le nom de la boîte est correct
    if (box.isNotEmpty) {
      // Si des données sont présentes, mettez à jour dailyTimeAllocation avec les valeurs sauvegardées
      for (var entry in box.values) {
        if (dailyTimeAllocation.containsKey(entry.day)) {
          dailyTimeAllocation[entry.day] = entry.allocatedTime;
          print('Loaded time allocation for ${entry.day}: ${entry.allocatedTime}');
        }
      }
      // Différer l'appel de onTimeAllocated pour éviter l'appel de setState pendant la construction
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTimeAllocated(Map.from(dailyTimeAllocation));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Allocate your daily time',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: [
                  ...dailyTimeAllocation.keys
                      .map((day) => _buildDayTile(context, day))
                      .toList(),
                  _buildTotalTile(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTile(BuildContext context, String day) {
    return ListTile(
      title: Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      trailing: Text(
        _formatTime(dailyTimeAllocation[day]!),
        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
      ),
      onTap: () => _openTimeSelectionDialog(context, day),
    );
  }

  Widget _buildTotalTile() {
    return ListTile(
      title: const Text(
        'Weekly Total',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
      trailing: Text(
        _formatTime(_calculateTotalTime()),
        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
      ),
    );
  }

  double _calculateTotalTime() {
    return dailyTimeAllocation.values.fold(0, (sum, value) => sum + value);
  }

  void _openTimeSelectionDialog(BuildContext context, String day) {
    double selectedTime = dailyTimeAllocation[day]!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Allocate time for $day', textAlign: TextAlign.center),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 10,
                      activeTrackColor: _getSliderColor(selectedTime),
                      inactiveTrackColor: Colors.grey[300],
                      thumbColor: Colors.black,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: selectedTime,
                      min: 0.0,
                      max: 8.0,
                      divisions: 32,
                      onChanged: (newValue) {
                        setState(() => selectedTime = newValue);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _formatTime(selectedTime),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  dailyTimeAllocation[day] = selectedTime;
                });
                widget.onTimeAllocated(Map.from(dailyTimeAllocation)); // Met à jour le log
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(double value) {
    int totalMinutes = (value * 60).toInt();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours h $minutes min';
    } else if (hours > 0) {
      return '$hours h';
    } else {
      return '$minutes min';
    }
  }

  Color _getSliderColor(double value) {
    if (value <= 5.0) {
      return Color.lerp(Colors.green, Colors.yellow, value / 5.0)!;
    } else {
      return Color.lerp(Colors.yellow, Colors.red, (value - 5.0) / 3.0)!;
    }
  }
}

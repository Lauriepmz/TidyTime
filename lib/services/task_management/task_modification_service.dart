import 'package:tidytime/utils/all_imports.dart';

class TaskModification extends StatefulWidget {
  final int taskId;
  final ValueChanged<Task>? onTaskUpdated;

  const TaskModification({super.key, required this.taskId, this.onTaskUpdated});

  @override
  State<TaskModification> createState() => _TaskModificationState();
}

class _TaskModificationState extends State<TaskModification> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _customRoomController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _dueDateLastDone;
  DateTime? _dueDateLastDoneProposed;
  DateTime? _lastDone; // Separate field for lastDone
  DateTime? _lastDoneProposed; // Separate field for lastDoneProposed
  String _selectedRoomKey = 'LivingRoom'; // Room key for backend logic
  int _repeatValue = 1;
  String _repeatUnit = 'days';
  bool _isLoading = true;
  late DateTime _initialStartDate;
  late int _initialRepeatValue;
  late String _initialRepeatUnit;

  List<String> _customRooms = [];
  late List<Map<String, String>> _roomChoices; // Centralized room data

  // Getters for lastDone and lastDoneProposed
  DateTime? get lastDone => _lastDone;
  DateTime? get lastDoneProposed => _lastDoneProposed;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
    _loadCustomRooms();
  }

  Future<void> _loadTaskDetails() async {
    try {
      Map<String, dynamic>? taskData = await DatabaseHelper.instance.getTaskById(widget.taskId);

      if (taskData != null) {
        Task task = Task.fromMap(taskData);
        await _initializeTask(task);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task not found')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error loading task details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomRooms() async {
    List<String> customRooms = await DatabaseHelper.instance.getCustomRooms();
    setState(() {
      _customRooms = customRooms;
      _updateRoomChoices();
    });
  }

  void _updateRoomChoices() {
    setState(() {
      _roomChoices = [
        ...roomChoices(context), // Utilise les pièces prédéfinies avec clé + nom
        ..._customRooms.map((room) => {'key': room, 'name': room}), // Pièces personnalisées ajoutées avec seulement le nom
      ];
    });
  }

  void _addCustomRoom(String newRoom) async {
    if (newRoom.isNotEmpty) {
      await DatabaseHelper.instance.insertCustomRoom(newRoom);
      setState(() {
        _customRooms.add(newRoom); // Ajoute directement le nom brut
        _updateRoomChoices();
        _customRoomController.clear();
        _selectedRoomKey = newRoom; // Utilise le nom comme clé pour les pièces personnalisées
      });
    }
  }


  void _saveTaskChanges() async {
    if (_taskNameController.text.isEmpty || _selectedRoomKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    bool hasStartDateChanged = _startDate != _initialStartDate;
    bool hasRepeatSettingsChanged = _repeatValue != _initialRepeatValue || _repeatUnit != _initialRepeatUnit;

    Map<String, DateTime?> updatedDates = DateCalculator.calculateUpdatedDueDates(
      startDate: _startDate,
      lastDone: _lastDone,
      dueDateLastDone: _dueDateLastDone,
      dueDateLastDoneProposed: _dueDateLastDoneProposed,
      lastDoneProposed: _lastDoneProposed,
      repeatValue: _repeatValue,
      repeatUnit: _repeatUnit,
      hasStartDateChanged: hasStartDateChanged,
      hasRepeatSettingsChanged: hasRepeatSettingsChanged,
    );

    _lastDoneProposed = updatedDates['lastDoneProposed'];

    Task updatedTask = Task(
      id: widget.taskId,
      taskName: _taskNameController.text,
      room: _selectedRoomKey, // Envoie directement la clé (prédéfinie) ou le nom (personnalisé)
      startDate: _startDate,
      dueDateLastDone: updatedDates['dueDateLastDone'] ?? _dueDateLastDone,
      dueDateLastDoneProposed: updatedDates['dueDateLastDoneProposed'] ?? _dueDateLastDoneProposed,
      lastDone: _lastDone,
      lastDoneProposed: _lastDoneProposed,
      repeatValue: _repeatValue,
      repeatUnit: _repeatUnit,
    );

    await DatabaseHelper.instance.updateTask(widget.taskId, updatedTask);

    if (widget.onTaskUpdated != null) {
      widget.onTaskUpdated!(updatedTask);
    }

    Navigator.pop(context);
  }

  Future<void> _initializeTask(Task task) async {
    setState(() {
      _taskNameController.text = task.taskName;
      _startDate = task.startDate;
      _initialStartDate = task.startDate;
      _dueDateLastDone = task.dueDateLastDone;
      _dueDateLastDoneProposed = task.dueDateLastDoneProposed;
      _lastDone = task.lastDone;
      _lastDoneProposed = task.lastDoneProposed;
      _selectedRoomKey = task.room; // Use the key to identify the room
      _repeatValue = task.repeatValue;
      _repeatUnit = task.repeatUnit;
      _initialRepeatValue = task.repeatValue;
      _initialRepeatUnit = task.repeatUnit;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateRoomChoices(); // Ensure the room choices are updated for translations

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Name Section
          const Text(
            'Task Name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                hintText: 'Enter task name',
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Room Selection Section
          ExpansionTile(
            title: const Text('Room Selection'),
            children: [
              RoomSelector(
                selectedRoom: _selectedRoomKey,
                roomChoices: _roomChoices, // Transmettez la liste complète (clé + nom)
                customRoomController: _customRoomController,
                onRoomSelected: (String? room) {
                  setState(() {
                    // Recherche de la clé uniquement pour les pièces prédéfinies
                    final predefinedRoom = _roomChoices.firstWhere(
                          (r) => r['name'] == room,
                    );

                    // Si c'est une pièce prédéfinie, utiliser sa clé, sinon conserver le nom brut
                    _selectedRoomKey = predefinedRoom['key'] ?? room!;
                  });
                },
                onCustomRoomSubmitted: _addCustomRoom,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Start Date Section
          ExpansionTile(
            title: const Text('Start Date'),
            children: [
              CalendarDatePicker(
                initialDate: _startDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                onDateChanged: (newDate) {
                  setState(() {
                    _startDate = newDate;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Repeat Settings Section
          ExpansionTile(
            title: const Text('Repeat Settings'),
            children: [
              PeriodicSelector(
                repeatValue: _repeatValue,
                repeatUnit: _repeatUnit,
                onRepeatValueChanged: (value) {
                  setState(() {
                    _repeatValue = value;
                  });
                },
                onRepeatUnitChanged: (unit) {
                  setState(() {
                    _repeatUnit = unit;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Save Button
          ElevatedButton(
            onPressed: _saveTaskChanges,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

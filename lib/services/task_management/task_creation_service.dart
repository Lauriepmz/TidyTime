import 'package:tidytime/utils/all_imports.dart';

class TaskCreationWidget extends StatefulWidget {
  final Future<int> Function(Task) onTaskAdded;
  final String? preSelectedRoom;

  const TaskCreationWidget({
    super.key,
    required this.onTaskAdded,
    this.preSelectedRoom,
  });

  @override
  TaskCreationWidgetState createState() => TaskCreationWidgetState();
}

class TaskCreationWidgetState extends State<TaskCreationWidget> with PageNavigationMixin<TaskCreationWidget> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _customRoomController = TextEditingController();
  String? _selectedRoomKey; // Use keys for backend logic
  DateTime _startDate = DateTime.now();
  int _repeatValue = 1;
  String _repeatUnit = 'days';
  final bool _isLoading = false;
  final List<String> _selectedTaskTypes = [];
  List<String> _customRooms = [];
  late List<Map<String, String>> _roomChoices; // List with keys and translations

  @override
  void initState() {
    super.initState();
    _selectedRoomKey = widget.preSelectedRoom;
    _customRooms = [];
    setMaxPages(4); // Définit le nombre de pages maximum pour la navigation
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRoomChoices(); // Gère les pièces traduites et personnalisées
    _loadCustomRooms(); // Charge les pièces personnalisées
  }

  void _updateRoomChoices() {
    final generatedChoices = roomChoices(context);
    print('[DEBUG] Raw Room Choices: $generatedChoices');

    setState(() {
      _roomChoices = [
        ...generatedChoices, // Predefined rooms
        ..._customRooms.map((room) => {'key': room, 'name': room}), // Custom rooms
      ];
      print('[DEBUG] Final Room Choices: $_roomChoices');
    });
  }

  Future<void> _loadCustomRooms() async {
    try {
      List<String> customRooms = await RoomManager.getCustomRooms();
      setState(() {
        _customRooms = customRooms; // Pas de clé, juste le nom brut
        _updateRoomChoices();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.failedToLoadCustomRooms ?? 'Failed to load custom rooms',
          ),
        ),
      );
    }
  }

  // Handle the task type selection
  void _toggleTaskType(String taskType) {
    setState(() {
      if (_selectedTaskTypes.contains(taskType)) {
        _selectedTaskTypes.remove(taskType);
      } else {
        _selectedTaskTypes.add(taskType);
      }
    });
  }

  void _addCustomRoom(String newRoom) async {
    if (newRoom.isNotEmpty) {
      try {
        await RoomManager.addCustomRoom(newRoom);
        setState(() {
          _customRooms.add(newRoom);
          _updateRoomChoices();
          _selectedRoomKey = newRoom; // Utilise la clé personnalisée
        });
      } catch (e) {
        print('Failed to add custom room: $e');
      }
    }
  }

  void _submitTask() async {
    if (_taskNameController.text.isEmpty || _selectedRoomKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.fillRequiredFields ?? 'Please fill all required fields',
          ),
        ),
      );
      print('[ERROR] Validation failed: task name or selected room is missing.');
      return;
    }

    // Vérifiez si la clé est valide
    final roomKeyExists = _roomChoices.any((room) => room['key'] == _selectedRoomKey);
    if (!roomKeyExists) {
      print('[ERROR] Validation failed: selected room key is invalid.');
      return;
    }

    print('[INFO] Task validation passed. Preparing to submit task...');
    print('Task Name: ${_taskNameController.text}');
    print('Selected Room Key: $_selectedRoomKey');
    print('Task Types: $_selectedTaskTypes');
    print('Repeat Value: $_repeatValue');
    print('Repeat Unit: $_repeatUnit');
    print('Start Date: $_startDate');

    try {
      await handleTaskSubmission(
        context: context,
        taskNameController: _taskNameController,
        selectedRoom: _selectedRoomKey,
        selectedTaskTypes: _selectedTaskTypes,
        repeatValue: _repeatValue,
        repeatUnit: _repeatUnit,
        startDate: _startDate,
      );
      print('[SUCCESS] Task submitted successfully.');
    } catch (e) {
      print('[ERROR] Task submission failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView(
                controller: pageController, // Utilisation du contrôleur du mixin
                physics: const BouncingScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {});
                },
                children: [
                  // Task Name Page using TaskNameInputWidget
                  _buildPageFrame(
                    child: TaskNameInputWidget(controller: _taskNameController),
                  ),
                  // Task Type Page using TaskTypeSelectorWidget
                  _buildPageFrame(
                    child: TaskTypeSelectorWidget(
                      selectedTaskTypes: _selectedTaskTypes,
                      taskTypeChoices: taskTypeChoices,
                      onTaskTypeSelected: _toggleTaskType,
                    ),
                  ),
                  // Room Selection Page using RoomSelector widget
                  _buildPageFrame(
                    child: RoomSelector(
                      selectedRoom: _selectedRoomKey,
                      roomChoices: _roomChoices, // Use updated room choices
                      customRoomController: _customRoomController,
                      onRoomSelected: (String? selectedRoomName) {
                        setState(() {
                          _selectedRoomKey = selectedRoomName; // Directement la valeur traduite
                          print('[DEBUG] Selected Room Name: $_selectedRoomKey');
                        });
                      },
                      onCustomRoomSubmitted: (String newRoom) {
                        _addCustomRoom(newRoom);
                      },
                    ),
                  ),
                  // Start Date Page using StartDateSelectorWidget
                  _buildPageFrame(
                    child: StartDateSelectorWidget(
                      selectedDate: _startDate,
                      onDateChanged: (date) {
                        setState(() {
                          _startDate = date;
                        });
                      },
                    ),
                  ),
                  // Repeat Settings using PeriodicSelector
                  _buildPageFrame(
                    child: PeriodicSelector(
                      repeatValue: _repeatValue,
                      repeatUnit: _repeatUnit,
                      onRepeatValueChanged: (int value) {
                        setState(() {
                          _repeatValue = value;
                        });
                      },
                      onRepeatUnitChanged: (String unit) {
                        setState(() {
                          _repeatUnit = unit;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  AppLocalizations.of(context)?.step('${currentPage + 1}', '5') ?? "Step ${currentPage + 1}/5",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Align "Back" button to the left
              if (currentPage > 0)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: ButtonStyles.gradientButton(
                    label: AppLocalizations.of(context)?.back ?? 'Back',
                    onPressed: previousPage,
                    fontSize: 18,
                    pattern: GradientPattern.patternThree,
                  ),
                ),
              const Spacer(), // Flexible spacing between buttons
              // Align "Next" and "Save Task" buttons to the right
              if (currentPage < 4)
                Align(
                  alignment: Alignment.bottomRight,
                  child: ButtonStyles.gradientButton(
                    label: AppLocalizations.of(context)?.next ?? 'Next',
                    onPressed: nextPage,
                    fontSize: 18,
                    pattern: GradientPattern.patternThree,
                  ),
                ),
              if (currentPage == 4)
                Align(
                  alignment: Alignment.bottomRight,
                  child: ButtonStyles.gradientButton(
                    label: AppLocalizations.of(context)?.saveTask ?? 'Save Task',
                    onPressed: _submitTask,
                    fontSize: 18,
                    pattern: GradientPattern.patternThree,
                  ),
                ),
            ],
          ),
        ),
        if (_isLoading) const CircularProgressIndicator(),
      ],
    );
  }

  // Helper method to wrap widgets in a centered frame
  Widget _buildPageFrame({required Widget child}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          elevation: 0.0,
          color: Colors.transparent, // Background transparent
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}

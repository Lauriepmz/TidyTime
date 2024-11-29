import 'package:tidytime/utils/all_imports.dart';

class PredefinedTaskWizardPage extends StatefulWidget {
  final Map<String, dynamic> predefinedTask;

  const PredefinedTaskWizardPage({super.key, required this.predefinedTask});

  @override
  PredefinedTaskWizardPageState createState() => PredefinedTaskWizardPageState();
}

class PredefinedTaskWizardPageState extends State<PredefinedTaskWizardPage>
    with PageNavigationMixin<PredefinedTaskWizardPage> {
  DateTime _startDate = DateTime.now(); // Default start date
  late String _taskName;
  late String _selectedRoom;
  late List<String> _selectedTaskTypes;
  late int _repeatValue;
  late String _repeatUnit;
  final TextEditingController _taskNameController = TextEditingController();

  bool _isRepeatSettingsExpanded = true; // Boolean to track if Repeat Settings should be expanded

  List<Map<String, String>> _roomChoices = [];
  final TextEditingController _customRoomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _taskName = widget.predefinedTask['taskName'];
    _selectedRoom = widget.predefinedTask['rooms'].first;
    _selectedTaskTypes = widget.predefinedTask['taskType'] is List
        ? List<String>.from(widget.predefinedTask['taskType'])
        : [widget.predefinedTask['taskType'].toString()];
    _repeatValue = widget.predefinedTask['repeatValue'];
    _repeatUnit = _validateRepeatUnit(widget.predefinedTask['repeatUnit']);
    _taskNameController.text = _taskName; // Initialize the task name controller
    setMaxPages(1); // Define the number of pages in the wizard
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRoomChoices(); // Update room choices dynamically based on the current locale
  }

  void _updateRoomChoices() {
    setState(() {
      _roomChoices = roomChoices(context);
    });
  }

  // Method to validate the repeat unit
  String _validateRepeatUnit(String unit) {
    List<String> validUnits = ['days', 'weeks', 'months'];
    return validUnits.contains(unit) ? unit : 'days';
  }

  // Method to save the task using handleTaskSubmission
  void _saveTask() async {
    await handleTaskSubmission(
      context: context,
      taskNameController: _taskNameController,
      selectedRoom: _selectedRoom,
      selectedTaskTypes: _selectedTaskTypes,
      repeatValue: _repeatValue,
      repeatUnit: _repeatUnit,
      startDate: _startDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: AppLocalizations.of(context)?.predefinedTaskWizard ?? 'Predefined Task Wizard',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Retourner à la page précédente
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildConfirmPredefinedTaskPage(),
                _buildStartDatePage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
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
                const Spacer(),
                if (currentPage < 1)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ButtonStyles.gradientButton(
                      label: AppLocalizations.of(context)?.next ?? 'Next',
                      onPressed: nextPage,
                      fontSize: 18,
                      pattern: GradientPattern.patternThree,
                    ),
                  ),
                if (currentPage == 1)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ButtonStyles.gradientButton(
                      label: AppLocalizations.of(context)?.saveTask ?? 'Save Task',
                      onPressed: _saveTask,
                      fontSize: 18,
                      pattern: GradientPattern.patternThree,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPredefinedTaskPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskNameInputWidget(controller: _taskNameController),
          const SizedBox(height: 16),

          ExpansionTile(
            title: Text(AppLocalizations.of(context)?.roomSelection ?? 'Room Selection'),
            children: [
              Container(
                constraints: BoxConstraints(maxHeight: 300), // Limitez la hauteur des enfants
                child: RoomSelector(
                  selectedRoom: _selectedRoom,
                  roomChoices: _roomChoices,
                  customRoomController: _customRoomController,
                  onRoomSelected: (String? roomKey) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedRoom = roomKey ?? _roomChoices.first['key']!;
                      });
                    });
                  },
                  onCustomRoomSubmitted: (String newRoomKey) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedRoom = newRoomKey;
                      });
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ExpansionTile(
            title: Text(AppLocalizations.of(context)?.taskType ?? 'Task Type'),
            children: [
              SingleChildScrollView(
                child: TaskTypeSelectorWidget(
                  selectedTaskTypes: _selectedTaskTypes,
                  taskTypeChoices: taskTypeChoices,
                  onTaskTypeSelected: (String selectedType) {
                    setState(() {
                      if (_selectedTaskTypes.contains(selectedType)) {
                        _selectedTaskTypes.remove(selectedType);
                      } else {
                        _selectedTaskTypes.add(selectedType);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ExpansionTile for Repeat Settings, automatically expanded
          ExpansionTile(
            initiallyExpanded: _isRepeatSettingsExpanded,
            title: Text(AppLocalizations.of(context)?.repeatSettings ?? 'Repeat Settings'),
            onExpansionChanged: (bool expanded) {
              setState(() {
                _isRepeatSettingsExpanded = expanded; // Update the expanded state
              });
            },
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
        ],
      ),
    );
  }

  // Page 2: Start Date Selection Page
  Widget _buildStartDatePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: StartDateSelectorWidget(
        selectedDate: _startDate,
        onDateChanged: (newDate) {
          setState(() {
            _startDate = newDate;
          });
        },
      ),
    );
  }
}

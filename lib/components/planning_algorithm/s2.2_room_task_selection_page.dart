import 'package:tidytime/utils/all_imports.dart';

class RoomTaskSelectionPage extends StatefulWidget {
  final String roomKey; // Add roomKey parameter
  final String roomName; // Existing roomName parameter
  final VoidCallback onSelectionConfirmed;

  const RoomTaskSelectionPage({
    Key? key,
    required this.roomKey, // Ensure roomKey is required
    required this.roomName,
    required this.onSelectionConfirmed,
  }) : super(key: key);

  @override
  State<RoomTaskSelectionPage> createState() => RoomTaskSelectionPageState();
}

class RoomTaskSelectionPageState extends State<RoomTaskSelectionPage>
    with TickerProviderStateMixin {
  String _selectedTaskType = 'All';
  Map<String, List<Map<String, Object>>> _selectedTasksByRoom = {};
  List<Map<String, dynamic>> _selectedTasks = [];
  late TabController _tabController;
  TabController? _taskTypeTabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSelectedTasksForRoom();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTaskTypeTabController();
  }

  void _updateTaskTypeTabController() {
    List<String> dynamicTaskTypes = _getTaskTypeChoices();

    _taskTypeTabController?.dispose();
    _taskTypeTabController = TabController(
      length: dynamicTaskTypes.length,
      vsync: this,
    );

    _taskTypeTabController!.addListener(() {
      if (_taskTypeTabController!.indexIsChanging) {
        setState(() {
          _selectedTaskType =
          dynamicTaskTypes[_taskTypeTabController!.index];
        });
      }
    });
  }

  List<String> _getTaskTypeChoices() {
    final taskTypeChoicesWithTasks = taskTypeChoices.where((type) {
      final filteredTasks = filterPredefinedTasks(
        context,
        selectedRoom: widget.roomKey, // Use roomKey for filtering
        selectedTaskType: type,
      );
      return filteredTasks.isNotEmpty;
    }).toList();

    return ['All', ...taskTypeChoicesWithTasks];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskTypeTabController?.dispose();
    super.dispose();
  }

  void _loadSelectedTasksForRoom() {
    print('[DEBUG] Loading selected tasks for room "${widget.roomKey}"');
    final bloc = context.read<TaskPlanningBloc>();
    final tasks = bloc.getTasksForRoom(widget.roomKey);

    setState(() {
      _selectedTasksByRoom[widget.roomKey] = tasks.map((task) => Map<String, Object>.from(task)).toList();
      _selectedTasks = _selectedTasksByRoom[widget.roomKey] ?? [];
      print('[DEBUG] Loaded tasks for room "${widget.roomKey}": $_selectedTasks');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedTasks.isEmpty,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (!didPop && _selectedTasks.isNotEmpty) {
          bool discard = await _showDiscardDialog();
          if (discard) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: MainAppBar(
          title: 'Select Tasks for ${widget.roomName}', // Use roomName for display
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_selectedTasks.isNotEmpty) {
                bool discard = await _showDiscardDialog();
                if (discard) {
                  Navigator.pop(context, false);
                }
              } else {
                Navigator.pop(context, false);
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _confirmSelection,
              tooltip: 'Confirm Selection',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All Tasks'),
              Tab(text: 'Selected Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Column(
              children: [
                TabBar(
                  controller: _taskTypeTabController,
                  isScrollable: true,
                  tabs: _getTaskTypeChoices()
                      .map((type) => Tab(text: type))
                      .toList(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _taskTypeTabController,
                    children: _getTaskTypeChoices().map((type) {
                      return _buildSelectableTaskList(type);
                    }).toList(),
                  ),
                ),
              ],
            ),
            _buildSelectedTasksList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableTaskList(String type) {
    // Use the room key for filtering, not the translated name
    List<Map<String, dynamic>> filteredTasks = filterPredefinedTasks(
      context,
      selectedRoom: widget.roomKey, // Use roomKey
      selectedTaskType: _selectedTaskType, // Use the selected task type
    ).where((task) => (task['rooms'] as List).contains(widget.roomKey)).toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)?.noTasksFound ?? 'No tasks found'),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> task = filteredTasks[index];
        bool isSelected = _selectedTasksByRoom[widget.roomKey]
            ?.any((t) => t['taskName'] == task['taskName']) ??
            false;

        return ListTile(
          title: Text(task['taskName']),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedTasksByRoom.putIfAbsent(widget.roomKey, () => []);
                  if (!_selectedTasksByRoom[widget.roomKey]!
                      .any((t) => t['taskName'] == task['taskName'])) {
                    _selectedTasksByRoom[widget.roomKey]!
                        .add(Map<String, Object>.from(task));
                  }
                } else {
                  _removeTaskFromRoom(task['taskName']);
                }
              });
            },
          ),
        );
      },
    );
  }

  void _removeTaskFromRoom(String taskName) {
    setState(() {
      _selectedTasksByRoom[widget.roomKey]
          ?.removeWhere((task) => task['taskName'] == taskName);
      _selectedTasks.removeWhere((task) => task['taskName'] == taskName);
      if (_selectedTasksByRoom[widget.roomKey]?.isEmpty ?? true) {
        _selectedTasksByRoom.remove(widget.roomKey);
      }
    });
  }

  Widget _buildSelectedTasksList() {
    final selectedTasks = _selectedTasksByRoom[widget.roomKey] ?? [];

    if (selectedTasks.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)?.noTasksSelected ??
            'No tasks selected'),
      );
    }

    return ListView.builder(
      itemCount: selectedTasks.length,
      itemBuilder: (context, index) {
        Map<String, Object> task =
        Map<String, Object>.from(selectedTasks[index]);

        return ListTile(
          title: Text(task['taskName'] as String),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _selectedTasksByRoom[widget.roomKey]?.removeAt(index);
                if (_selectedTasksByRoom[widget.roomKey]?.isEmpty ?? true) {
                  _selectedTasksByRoom.remove(widget.roomKey);
                }
              });
            },
          ),
        );
      },
    );
  }

  void _confirmSelection() {
    final selectedTasksForRoom = _selectedTasksByRoom[widget.roomKey] ?? [];

    List<Map<String, Object?>> tasksToSave = selectedTasksForRoom.map((task) {
      return {
        'taskNameSelected': task['taskName'],
        'taskRoomSelected': widget.roomKey,
        'taskTypeSelected': task['taskType'],
        'repeatUnitSelected': task['repeatUnit'],
        'repeatValueSelected': task['repeatValue'],
      };
    }).toList();

    context
        .read<TaskPlanningBloc>()
        .add(SaveSelectedTasks(widget.roomKey, tasksToSave));

    Navigator.pop(context, true);
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.unsavedChanges ??
              'Unsaved Changes'),
          content: Text(AppLocalizations.of(context)
              ?.discardChangesMessage ??
              'You have selected tasks that are not saved. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
              Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                  AppLocalizations.of(context)?.discard ?? 'Discard'),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}

import 'package:tidytime/utils/all_imports.dart';

class TaskCreationPlanificationQuizz extends StatefulWidget {
  const TaskCreationPlanificationQuizz({super.key});

  @override
  TaskCreationPlanificationQuizzState createState() => TaskCreationPlanificationQuizzState();
}

class TaskCreationPlanificationQuizzState extends State<TaskCreationPlanificationQuizz> {
  final Map<String, double> dailyTimeAllocation = {
    'Monday': 0,
    'Tuesday': 0,
    'Wednesday': 0,
    'Thursday': 0,
    'Friday': 0,
    'Saturday': 0,
    'Sunday': 0,
  };

  final List<String> allPreferences = ['By frequency', 'By task type', 'By room'];
  List<String?> rankedPreferences = List<String?>.filled(3, null);
  List<String> availablePreferences = ['By room', 'By task type', 'By frequency'];
  int? intensityPreference = 1;
  int? repetitiveTaskPreference = 1;
  int? customPreference = 1;
  Map<int, int> rankingMap = {};
  List<String> selectedRooms = [];
  late final PageController _pageController;
  int _currentPageIndex = 0;
  Map<int, List<String>> groupedRooms = {0: [], 1: [], 2: []};
  List<Map<String, String>> rooms = [];
  late Future<void> _initialLoadFuture;
  int get _pageCount => 8;
  bool isRankingComplete = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _initialLoadFuture = _initializePlanningSession().then((_) {
      _loadRoomsFromHive();
    }).catchError((e) {
      print("Error during _initialLoadFuture execution: $e");
    });
    _pageController.addListener(() {
      // If navigating to RoomGroupingWidget page, reload rooms
      if (_pageController.page?.round() == 7) {
        _loadRoomsFromHive();
      }
    });
  }

  Future<void> _initializePlanningSession() async {
    try {
      await context.read<TaskPlanningBloc>().ensureBoxesInitialized();
      context.read<TaskPlanningBloc>().add(StartTaskPlanning());
      await Future.delayed(Duration.zero);
    } catch (e) {
      print("Error in _initializePlanningSession: $e");
    }
  }

  void _syncRankingMap() {
    rankingMap = {
      for (int i = 0; i < rankedPreferences.length; i++)
        if (rankedPreferences[i] != null) i + 1: allPreferences.indexOf(rankedPreferences[i]!) + 1
    };

    print("Synced rankingMap: $rankingMap");
  }

  void _updateRanking(int targetIndex, String item) {
    setState(() {
      if (rankedPreferences[targetIndex] != null) {
        availablePreferences.add(rankedPreferences[targetIndex]!);
      }
      rankedPreferences[targetIndex] = item;

      // Log les préférences classées
      print("Updated rankedPreferences: $rankedPreferences");

      availablePreferences = allPreferences
          .where((option) => !rankedPreferences.contains(option))
          .toList();

      // Synchroniser rankingMap
      _syncRankingMap();
    });
  }
  void _removeItemFromRanking(int targetIndex) {
    setState(() {
      if (rankedPreferences[targetIndex] != null) {
        availablePreferences.add(rankedPreferences[targetIndex]!);
        rankedPreferences[targetIndex] = null;
      }

      // Log les préférences classées après suppression
      print("Updated rankedPreferences after removal: $rankedPreferences");

      availablePreferences = allPreferences
          .where((option) => !rankedPreferences.contains(option))
          .toList();

      // Synchroniser rankingMap
      _syncRankingMap();
    });
  }

  Future<void> _loadRoomsFromHive() async {
    try {
      final box = Hive.box<RoomSelected>('tempRoomSelectedBox');
      setState(() {
        rooms = box.values
            .map((room) => {'key': room.roomKey, 'name': _getTranslatedRoomName(room.roomKey)})
            .toList();
      });
    } catch (e) {
      print("Error loading rooms from Hive: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateGroupedRooms(int groupIndex, List<String> roomKeys) {
    setState(() {
      groupedRooms[groupIndex] = roomKeys.map(_getTranslatedRoomName).toList();
    });
  }

  Future<void> _completeQuiz() async {
    context.read<TaskPlanningBloc>().add(SaveGroupedRoomsTemporarily(groupedRooms));
    context.read<TaskPlanningBloc>().add(CompleteTaskPlanning());
    print("Quiz completed. Returning to Home Page.");
  }

  String _getTranslatedRoomName(String roomKey) {
    return getTranslatedRoomName(context, roomKey); // Use the utility function for translation
  }

  Future<bool> _validatePageData() async {
    switch (_currentPageIndex) {
      case 0:
        if (selectedRooms.isEmpty) {
          _showWarningDialog('Veuillez sélectionner au moins une pièce.');
          return false;
        }
        break;
      case 1:
        bool allRoomsHaveTasks = await _checkAllRoomsHaveTasks();
        if (!allRoomsHaveTasks) {
          _showWarningDialog('Chaque pièce sélectionnée doit avoir au moins une tâche associée.');
          return false;
        }
        break;
      case 2:
        if (_isTimeAllocationEmpty()) {
          _showWarningDialog('Veuillez allouer du temps pour au moins un jour.');
          return false;
        }
        break;
      default:
        break;
    }
    return true;
  }

  bool _isTimeAllocationEmpty() {
    return dailyTimeAllocation.values.every((time) => time == 0);
  }

  Future<bool> _checkAllRoomsHaveTasks() async {
    final bloc = context.read<TaskPlanningBloc>();
    for (String room in selectedRooms) {
      int taskCount = await bloc.getTaskCountForRoom(room);
      if (taskCount == 0) {
        return false;
      }
    }
    return true;
  }

  Future<void> _showWarningDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Information manquante'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialLoadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading data: ${snapshot.error}"));
        }
        return BlocConsumer<TaskPlanningBloc, TaskPlanningState>(
          listener: (context, state) {
            if (state is TaskPlanningLoaded) {
              _loadSelectedRooms();
            }
          },
          builder: (context, state) {
            if (state is TaskPlanningLoaded) {
              return _buildQuizContent();
            } else if (state is TaskPlanningProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskPlanningError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  void _loadSelectedRooms() {
    final bloc = context.read<TaskPlanningBloc>();
    setState(() {
      selectedRooms = bloc.getSelectedRooms();
    });
  }

  Widget _buildQuizContent() {
    return BlocListener<TaskPlanningBloc, TaskPlanningState>(
      listener: (context, state) {
        if (state is TaskPlanningCompleted) {
          print("Task planning complete. Returning to Home Page.");
          Navigator.of(context).popUntil((route) => route.isFirst); // Return to Home Page
        } else if (state is TaskPlanningError) {
          _showErrorDialog(state.message);
        }
      },
      child: Scaffold(
        appBar: MainAppBar(
          title: 'Task Creation Planification',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // Return to the previous page
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: (_) {}, // Disable horizontal swipe gestures
                child: PageView(
                  key: const PageStorageKey('task_creation_planification_pageview'),
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    _buildMultiRoomSelector(),
                    // Page 1: Room Selected Task Selection
                    RoomSelectedTaskSelection(
                      onTaskSelectionComplete: () async {
                        await _reloadTasks();
                      },
                    ),
                    WeeklyTimeAllocationPage(
                      onTimeAllocated: (updatedAllocation) {
                        setState(() {
                          dailyTimeAllocation.addAll(updatedAllocation);
                        });
                      },
                    ),
                    PreferenceRankingWidget(
                      rankedPreferences: rankedPreferences,
                      availablePreferences: availablePreferences,
                      onRankingUpdated: _updateRanking,
                      onRemoveItem: _removeItemFromRanking,
                      onRankingCompleted: (isComplete) {
                        setState(() {
                          isRankingComplete = isComplete;
                        });
                      },
                    ),
                    IntensityPreferenceQuestion(
                      selectedOption: intensityPreference,
                      onOptionSelected: (value) {
                        setState(() => intensityPreference = value);
                      },
                    ),
                    RepetitiveTaskPreferenceQuestion(
                      selectedOption: repetitiveTaskPreference,
                      onOptionSelected: (value) {
                        setState(() => repetitiveTaskPreference = value);
                      },
                    ),
                    CustomPlaceholderQuestion(
                      selectedResponse: customPreference,
                      onResponseSelected: (value) {
                        setState(() => customPreference = value);
                      },
                    ),
                    RoomGroupingWidget(
                      rooms: rooms.map((room) => room['name']!).toList(),
                      groupedRooms: groupedRooms,
                      onRoomGroupingUpdated: _updateGroupedRooms,
                    ),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }


  Widget _buildMultiRoomSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MultiRoomSelector(
        pageController: _pageController,
        initialSelectedRooms: selectedRooms,
        roomChoices: rooms.map((room) => room['key']!).toList(),
        onRoomsSelected: (roomKeys) {
          setState(() {
            selectedRooms = roomKeys;
          });
        },
        customRoomController: TextEditingController(),
        onCustomRoomSubmitted: (newRoomKey) {
          final translatedName = _getTranslatedRoomName(newRoomKey);
          setState(() {
            rooms.add({'key': newRoomKey, 'name': translatedName});
          });
        },
      ),
    );
  }


  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          if (_currentPageIndex > 0)
            ElevatedButton(
              onPressed: _previousPage,
              child: const Text("Back"),
            ),
          const Spacer(),
          ElevatedButton(
            onPressed: _nextPage,
            child: Text(_currentPageIndex == _pageCount - 1 ? "Done" : "Next"),
          ),
        ],
      ),
    );
  }

  void _nextPage() async {
    print('[DEBUG] Validating data for page $_currentPageIndex...');
    bool isDataValid = await _validatePageData();

    if (!isDataValid) {
      print('[DEBUG] Data invalid for page $_currentPageIndex.');
      return;
    }

    if (_currentPageIndex == 0) {
      print('[DEBUG] Saving selected rooms...');
      _saveSelectedRooms();
    } else if (_currentPageIndex == 1) {
      // Ensure tasks are saved after task selection is complete
      print('[DEBUG] Logging selected tasks for rooms...');
      await _logCurrentPageData();
    }

    // Navigate to the next page within PageView
    if (_currentPageIndex < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPageIndex++;
      });
    } else {
      print('[DEBUG] Quiz complete; saving final preferences...');
      _completeQuiz();
    }
  }


  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _logCurrentPageData() async {
    final taskPlanningBloc = context.read<TaskPlanningBloc>();

    print('Logging data for page index $_currentPageIndex');
    print('Current ranking map: $rankingMap');

    switch (_currentPageIndex) {
      case 1:
      // Si vous êtes sur la page des tâches sélectionnées
        print('Logging selected tasks for rooms...');
        await _reloadTasks();
        break;
      case 2:
        _saveTimeAllocations();
        break;
      case 4:
        if (intensityPreference != null) {
          final rank = rankingMap[1] ?? -1;
          print('Logging intensity preference: rank=$rank, preference=$intensityPreference');
          taskPlanningBloc.add(SaveSingleChoiceAnswer(1, rank, intensityPreference!));
        }
        break;
      case 5:
        if (repetitiveTaskPreference != null) {
          final rank = rankingMap[2] ?? -1;
          print('Logging repetitive task preference: rank=$rank, preference=$repetitiveTaskPreference');
          taskPlanningBloc.add(SaveSingleChoiceAnswer(2, rank, repetitiveTaskPreference!));
        }
        break;
      case 6:
        if (customPreference != null) {
          final rank = rankingMap[3] ?? -1;
          print('Logging custom preference: rank=$rank, preference=$customPreference');
          taskPlanningBloc.add(SaveSingleChoiceAnswer(3, rank, customPreference!));
        }
        break;
      default:
        break;
    }
  }


  void _saveTimeAllocations() {
    context.read<TaskPlanningBloc>().add(SaveTimeAllocation(Map.from(dailyTimeAllocation)));
  }

  void _saveSelectedRooms() {
    final structuredRooms = selectedRooms.map((roomKey) {
      final roomName = _getTranslatedRoomName(roomKey); // Translate the key to a readable name
      return {'key': roomKey, 'name': roomName};
    }).toList();

    context.read<TaskPlanningBloc>().add(SaveSelectedRooms(structuredRooms));
    print('[DEBUG] Saved rooms: $structuredRooms');
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reloadTasks() async {
    final bloc = context.read<TaskPlanningBloc>();
    setState(() {
      selectedRooms = bloc.getSelectedRooms();
    });

    print('[DEBUG] Reloaded tasks for selected rooms (keys): $selectedRooms');
  }
}

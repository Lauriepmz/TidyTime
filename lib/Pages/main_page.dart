import 'package:tidytime/utils/all_imports.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<String> _pageTitles = ['Home', 'Calendar', 'Profile'];
  late List<Widget> _pages;
  bool _isFloatingVisible = false;
  bool _isFullScreen = false;
  OverlayEntry? _floatingTimerEntry;

  // Initial position for the floating widget
  Offset _floatingWidgetPosition = const Offset(50, 50);

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      const CalendarPage(),
      const ProfilePage(),
    ];
  }

  void _onStartCleaningPressed() {
    final sessionBloc = context.read<SessionBloc>();

    if (sessionBloc.state is SessionInProgress) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CleaningSessionPage(
            onShowFloatingTimer: showFloatingTimer,
            modifiedTasks: [],
            timerService: context.read<TimerService>(),
            onHideFloatingTimer: hideFloatingTimer,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CleaningSessionTransitionPage(
            onHideFloatingTimer: hideFloatingTimer,
            onShowFloatingTimer: showFloatingTimer,
            taskService: context.read<TaskService>(),
          ),
        ),
      );
    }
  }

  void _onCreateTaskPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskCreationTransitionPage(), // Redirection vers la page de transition
      ),
    );
  }

  void showFloatingTimer() {
    final overlayState = Overlay.of(context);

    if (_floatingTimerEntry == null || !_floatingTimerEntry!.mounted) {
      // Create the overlay entry for the draggable floating timer
      _floatingTimerEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: _floatingWidgetPosition.dy,
          left: _floatingWidgetPosition.dx,
          child: Draggable(
            feedback: Material(
              color: Colors.transparent,
              child: FloatingTimerWidget(
                onFullScreenPressed: _onFullScreenPressed,
                onStopPressed: onStopPressed,
              ),
            ),
            childWhenDragging: Container(),  // Show nothing while dragging
            onDragEnd: (details) {
              // Update position after drag
              setState(() {
                _floatingWidgetPosition = details.offset;
              });
            },
            child: FloatingTimerWidget(
              onFullScreenPressed: _onFullScreenPressed,
              onStopPressed: onStopPressed,
            ),
          ),
        ),
      );

      // Insert the overlay entry
      if (mounted) {
        overlayState.insert(_floatingTimerEntry!);
        setState(() {
          _isFloatingVisible = true;
        });
      }
    }
  }

  void hideFloatingTimer() {
    if (_floatingTimerEntry != null && _floatingTimerEntry!.mounted) {
      _floatingTimerEntry!.remove();
      _floatingTimerEntry = null;
      setState(() {
        _isFloatingVisible = false;
      });
    }
  }

  void _removeFloatingTimer() {
    if (_isFloatingVisible) {
      _floatingTimerEntry?.remove();
      setState(() {
        _isFloatingVisible = false;
      });
    }
  }

  void toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      context.read<SessionBloc>().add(ToggleFullScreenEvent(_isFullScreen));

      if (_isFullScreen) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CleaningSessionPage(
              onHideFloatingTimer: hideFloatingTimer,
              onShowFloatingTimer: showFloatingTimer,
              modifiedTasks: [],
              timerService: context.read<TimerService>(),
            ),
          ),
        );
      } else {
        showFloatingTimer();
      }
    });
  }

  void _onFullScreenPressed() {
    if (_isFullScreen) {
      context.read<SessionBloc>().add(ToggleFullScreenEvent(false));
      Navigator.pop(context);

      if (_floatingTimerEntry == null || !_floatingTimerEntry!.mounted) {
        showFloatingTimer();
      }
    } else {
      hideFloatingTimer();
      context.read<SessionBloc>().add(ToggleFullScreenEvent(true));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CleaningSessionPage(
            onHideFloatingTimer: hideFloatingTimer,
            timerService: context.read<TimerService>(),
            modifiedTasks: [],
            onShowFloatingTimer: showFloatingTimer,
          ),
        ),
      );
    }
  }

  void onStopPressed() {
    context.read<SessionBloc>().add(StopSession(DateTime.now(), context));
    _removeFloatingTimer();
  }

  Widget? _getAppBarLeading(BuildContext context) {
    // Afficher le bouton retour pour toutes les pages sauf les principales
    if (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2) {
      return null; // Le `MainAppBar` affichera automatiquement le menu
    } else {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  List<Widget> _getAppBarActions() {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: _pageTitles[_currentIndex], // Titre dynamique selon la page
        leading: _getAppBarLeading(context), // Bouton dynamique (menu ou retour)
        actions: _getAppBarActions(), // Actions dynamiques si nécessaire
      ),
      drawer: _currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2
          ? MainDrawer(
        onCreateTaskPressed: _onCreateTaskPressed,
        onStartCleaningPressed: _onStartCleaningPressed,
      )
          : null, // Pas de tiroir pour les pages secondaires
      body: Stack(
        children: [
          _pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
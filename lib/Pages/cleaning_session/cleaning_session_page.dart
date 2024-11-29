import 'package:tidytime/utils/all_imports.dart';

class CleaningSessionPage extends StatefulWidget {
  final TimerService timerService;
  final List<Task> modifiedTasks;
  final VoidCallback onShowFloatingTimer;
  final VoidCallback onHideFloatingTimer;  // New callback to hide the floating timer

  const CleaningSessionPage({
    super.key,
    required this.timerService,
    required this.modifiedTasks,
    required this.onShowFloatingTimer,
    required this.onHideFloatingTimer,  // Add the callback in the constructor
  });

  @override
  CleaningSessionPageState createState() => CleaningSessionPageState();
}

class CleaningSessionPageState extends State<CleaningSessionPage> {
  TimerService? _timerService;
  SessionBloc? _sessionBloc;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _timerService = widget.timerService;
      _sessionBloc = context.read<SessionBloc>();

      if (_timerService != null && _sessionBloc != null) {
        _initializeSession();
        _isInitialized = true;
      }
    }

    // Ensure the floating timer is hidden safely after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onHideFloatingTimer();  // Hide the floating timer
      }
    });

    // Attach the callback to TimerService
    _timerService?.addCallback((elapsedSeconds) {
      if (mounted) {
        _sessionBloc!.add(UpdateTimer(elapsedSeconds));
      }
    });

    // Ensure TimerService starts if not already running
    if (_timerService != null && !_timerService!.isRunning) {
      _timerService!.start((elapsedSeconds) {
        if (mounted) {
          _sessionBloc!.add(UpdateTimer(elapsedSeconds));
        }
      });
    }
  }

  @override
  void dispose() {
    if (_timerService != null && _timerService!.isStopped) {
      _timerService?.removeAllCallbacks();
    }
    super.dispose();
  }

  Future<void> _initializeSession() async {
    if (!mounted) return;

    final currentState = _sessionBloc?.state;

    if (currentState is SessionInProgress) {
      print("Session already in progress, not reinitializing.");
      return; // Don't reinitialize if a session is already in progress
    }

    _sessionBloc!.add(StartSession(modifiedTasks: widget.modifiedTasks));
    _timerService!.start((elapsedSeconds) {
      if (mounted) {
        _sessionBloc!.add(UpdateTimer(elapsedSeconds));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return PopScope<Object?>(
      canPop: false,  // Block the initial back navigation by setting canPop to false
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        print("Predictive back invoked: didPop = $didPop");

        if (didPop) {
          // The pop already happened, no further action needed
          return;
        }

        // Show confirmation dialog if the pop was blocked
        final bool shouldPop = await showExitConfirmationDialog(context, _cancelCleaningSession);
        if (shouldPop ) {
          // If the user confirms, manually pop the page
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: MainAppBar(
          title: "Cleaning Session",
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              bool shouldPop = await showExitConfirmationDialog(context, _cancelCleaningSession);
              if (shouldPop) {
                _cancelCleaningSession(context);
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            if (state is SessionInProgress) {
              return Column(
                children: [
                  // Fullscreen Timer Widget
                  SizedBox(
                    width: screenWidth,
                    height: screenHeight * 0.25,
                    child: TimerWidget(
                      isFullScreen: true,
                      onFullScreenPressed: () {
                        setState(() {
                          _sessionBloc!.add(ToggleFullScreenEvent(false));  // Switch to floating mode
                        });
                        Navigator.pop(context); // Exit fullscreen
                        widget.onShowFloatingTimer(); // Show floating timer
                      },
                      onStopPressed: () {
                        showStopCleaningSessionDialog(context, _stopCleaningSession);
                      },
                    ),
                  ),
                  Expanded(
                    child: TaskChecklistWidget(),
                  ),
                ],
              );
            } else if (state is SessionStopped) {
              return const Center(child: Text("Session completed."));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<void> _cancelCleaningSession(BuildContext context) async {
    final DateTime cancelTime = DateTime.now();
    _sessionBloc!.add(CancelSession(cancelTime));
    _timerService!.stop();
    _timerService!.removeAllCallbacks();
  }

  Future<void> _stopCleaningSession(BuildContext context) async {
    _sessionBloc!.add(StopSession(DateTime.now(), context));  // Dispatch event first
    await Future.delayed(const Duration(milliseconds: 100));  // Small delay to ensure processing
    _timerService!.stop();  // Stop the timer only after the event is processed
    _timerService!.removeAllCallbacks();
  }
}

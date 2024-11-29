import 'package:tidytime/utils/all_imports.dart';

class FloatingTimerWidget extends StatefulWidget {
  final VoidCallback onFullScreenPressed;
  final VoidCallback onStopPressed;

  const FloatingTimerWidget({
    super.key,
    required this.onFullScreenPressed,
    required this.onStopPressed,
  });

  @override
  FloatingTimerWidgetState createState() => FloatingTimerWidgetState();
}

class FloatingTimerWidgetState extends State<FloatingTimerWidget> {
  TimerService? _timerService;
  SessionBloc? _sessionBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _timerService ??= context.read<TimerService>();
    _sessionBloc ??= context.read<SessionBloc>();

    // Attach the callback to update the timer in the bloc
    _timerService?.addCallback((elapsedSeconds) {
      _sessionBloc?.add(UpdateTimer(elapsedSeconds));
    });

    // Start the TimerService if not running
    if (!_timerService!.isRunning) {
      _timerService?.start((elapsedSeconds) {
        // Handle the time updates, if necessary
        _sessionBloc?.add(UpdateTimer(elapsedSeconds));
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        final bloc = context.read<SessionBloc>();

        if (state is SessionInProgress && bloc.isFloatingVisible) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 200,  // Size for floating mode
                maxHeight: 100,
              ),
              child: Material(
                color: Colors.transparent,
                child: TimerWidget(
                  isFullScreen: false,  // Not fullscreen in floating mode
                  onFullScreenPressed: widget.onFullScreenPressed,
                  onStopPressed: widget.onStopPressed,
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

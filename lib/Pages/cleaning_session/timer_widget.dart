import 'package:tidytime/utils/all_imports.dart';

class TimerWidget extends StatefulWidget {
  final bool isFullScreen;
  final VoidCallback onFullScreenPressed;
  final VoidCallback onStopPressed;

  const TimerWidget({
    super.key,
    required this.isFullScreen,
    required this.onFullScreenPressed,
    required this.onStopPressed,
  });

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  TimerService? _timerService;  // Store TimerService reference
  late String displayedTime;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timerService = context.read<TimerService>();

    // Ensure that the callback is not added redundantly
    if (_timerService != null) {
      _timerService?.removeAllCallbacks();  // Clear previous callbacks to avoid duplicates

      // Add the callback to update displayed time
      _timerService?.addCallback((elapsedSeconds) {
        setState(() {
          displayedTime = _timerService!.formattedTime();
        });
      });
    }

    displayedTime = _timerService!.formattedTime();  // Initial display
  }


  @override
  Widget build(BuildContext context) {
    final double iconSize = widget.isFullScreen ? 30 : 20;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: widget.isFullScreen ? BorderRadius.zero : BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Fullscreen toggle button
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                widget.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
                size: iconSize,
              ),
              onPressed: widget.onFullScreenPressed,
            ),
          ),
          // Centered time display
          Center(
            child: TimerDisplayWidget(
              formattedTime: displayedTime,
              isFullScreen: widget.isFullScreen,
            ),
          ),
          // Play, pause, and stop buttons
          Positioned(
            bottom: -5,
            left: 0,
            right: 0,
            child: TimerControlButtons(
              timerService: _timerService!,  // Pass the timer service to control buttons
              iconSize: iconSize,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the TimerService callbacks only if they are valid
    if (_timerService != null && _timerService!.isStopped) {
      _timerService?.removeAllCallbacks();
    }
    super.dispose();
  }
}
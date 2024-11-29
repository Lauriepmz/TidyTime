import 'package:tidytime/utils/all_imports.dart';

class TimerService {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;
  bool _isStopped = false; // Track if the timer is completely stopped

  final List<Function(int)> _callbacks = [];

  void addCallback(Function(int) callback) {
    _callbacks.add(callback);
    callback(_secondsElapsed);  // Notify with the current time immediately
  }

  void removeCallback(Function(int) callback) {
    _callbacks.remove(callback);
  }

  void removeAllCallbacks() {
    _callbacks.clear();  // Remove all callbacks
  }

  void _notifyCallbacks() {
    for (var callback in List.from(_callbacks)) {
      callback(_secondsElapsed);  // Ensure all registered callbacks are notified
    }
  }

  void start(Function(int) onTick) {
    if (_isRunning) return; // Don't start if already running
    _isRunning = true;
    _isStopped = false; // Timer is running

    addCallback(onTick);  // Register the callback that will receive elapsed seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      _notifyCallbacks();  // Notify all registered callbacks with the elapsed time
    });
  }



  void pause() {
    _isRunning = false;
    _timer?.cancel(); // Pause the timer
  }

  void stop() {
    _isRunning = false;
    _isStopped = true;  // Timer is fully stopped
    _timer?.cancel();
    _notifyCallbacks();
  }

  void reset() {
    stop();
    _secondsElapsed = 0;  // Reset the timer
    _notifyCallbacks();  // Update the time to 00:00:00
  }

  String formattedTime() {
    final hours = _secondsElapsed ~/ 3600;
    final minutes = (_secondsElapsed % 3600) ~/ 60;
    final seconds = _secondsElapsed % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  int getElapsedTime() {
    return _secondsElapsed;
  }

  bool get isRunning => _isRunning;
  bool get isStopped => _isStopped;
}

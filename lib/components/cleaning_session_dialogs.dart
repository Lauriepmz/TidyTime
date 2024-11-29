import 'package:tidytime/utils/all_imports.dart';

Future<void> showStartCleaningSessionDialog(
    BuildContext context,
    TimerService timerService,
    Function(int) updateTimeDisplay,
    Future<void> Function(BuildContext) startCleaningSession) async {
  bool shouldStart = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Start Cleaning Session'),
        content: const Text('Do you want to start the cleaning session?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Start'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;

  if (shouldStart) {
    await startCleaningSession(context);
    timerService.start(updateTimeDisplay);
  }
}

Future<void> showStopCleaningSessionDialog(
    BuildContext context,
    Future<void> Function(BuildContext) stopCleaningSession) async {
  bool shouldStop = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Stop Cleaning Session'),
        content: const Text('Do you want to stop the cleaning session?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Stop'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  ) ?? false;

  if (shouldStop) {
    await stopCleaningSession(context);
  }
}


Future<bool> showExitConfirmationDialog(
    BuildContext context,
    Future<void> Function(BuildContext) cancelCleaningSession) async {
  bool shouldCancel = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Do you want to exit the cleaning session? All temporary data will be lost.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop(true);  // Retourne true si l'utilisateur confirme
            },
          ),
        ],
      );
    },
  ) ?? false;

  // Si l'utilisateur confirme, annule la session
  if (shouldCancel) {
    await cancelCleaningSession(context);
  }

  return shouldCancel;  // Retourne la valeur booléenne du résultat
}

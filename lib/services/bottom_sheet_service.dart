import 'package:tidytime/utils/all_imports.dart';

class TaskBottomSheetService {
  static void showUndoBottomSheet({
    required BuildContext context,
    required String message,
    required Future<void> Function() undoCallback,
    required VoidCallback onUndoSuccess, // Nouveau callback pour notifier le succès
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                message,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Appel au callback Undo
                        await undoCallback();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task restored')),
                        );

                        // Notifier le succès
                        onUndoSuccess();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to undo the task')),
                        );
                      }
                    },
                    child: const Text('Undo'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
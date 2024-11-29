import 'package:tidytime/utils/all_imports.dart';

class TaskLoadingPage extends StatelessWidget {
  final bool isEditing;

  const TaskLoadingPage({super.key, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "isEditing ? 'Updating Task' : 'Creating Task'",
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              isEditing
                  ? 'Your task is being updated, please wait...'
                  : 'Your task is being created, please wait...',
            ),
          ],
        ),
      ),
    );
  }
}

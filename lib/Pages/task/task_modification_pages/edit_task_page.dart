import 'package:tidytime/utils/all_imports.dart';

class EditTaskPage extends StatefulWidget {
  final int taskId;
  final VoidCallback? onTaskUpdated;

  const EditTaskPage({super.key, required this.taskId, this.onTaskUpdated});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          await Future.delayed(Duration(milliseconds: 100));

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(taskId: widget.taskId),
            ),
                (Route<dynamic> route) => route.isFirst,
          );
        }
      },
      child: Scaffold(
        appBar: MainAppBar(
          title: 'Edit Task',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => TaskDetailPage(taskId: widget.taskId),
                ),
                    (Route<dynamic> route) => route.isFirst,
              );
            },
          ),
        ),
        body: SafeArea(
          child: TaskModification(
            taskId: widget.taskId,
            onTaskUpdated: (Task updatedTask) {
              if (widget.onTaskUpdated != null) {
                widget.onTaskUpdated!();
              }
            },
          ),
        ),
      ),
    );
  }
}
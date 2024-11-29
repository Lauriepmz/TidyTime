import 'package:tidytime/utils/all_imports.dart';

class TaskNameInputWidget extends StatelessWidget {
  final TextEditingController controller;

  const TaskNameInputWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Enter Task Name', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Task Name',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

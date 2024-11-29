import 'package:tidytime/utils/all_imports.dart';

class createTaskPage extends StatelessWidget {
  final Future<int> Function(Task) onTaskAdded; // Modifié pour retourner 'int'
  final String? selectedRoom; // Pièce pré-sélectionnée

  const createTaskPage({super.key, required this.onTaskAdded, this.selectedRoom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainAppBar(
            title: 'Create Task',
            leading: IconButton(
        icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop(); // Retourner à la page précédente
      },
    ),),
      body: SafeArea(
        child: GestureDetector(
          // Detect any tap outside of text fields and close the keyboard
          onTap: () {
            FocusScope.of(context).unfocus(); // Close the keyboard when tapped outside
          },
          child: TaskCreationWidget(
            // Passe la fonction de rappel pour l'ajout de tâche
            onTaskAdded: (Task newTask) async {
              try {
                // Appel à la fonction d'insertion dans la base de données et retourne l'ID de la tâche
                int newTaskId = await DatabaseHelper.instance.insertTask(newTask);
                print("Task added with ID: $newTaskId");

                // Retourne l'ID de la tâche créée
                return newTaskId;
              } catch (e) {

                // En cas d'erreur, renvoyer -1 ou un code d'erreur
                return -1; // ou gérer l'erreur comme tu le souhaites
              }
            },
            preSelectedRoom: selectedRoom, // Passe la pièce pré-sélectionnée
          ),
        ),
      ),
    );
  }
}

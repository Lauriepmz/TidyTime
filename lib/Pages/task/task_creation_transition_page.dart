import 'package:tidytime/utils/all_imports.dart';

class TaskCreationTransitionPage extends StatelessWidget {
  const TaskCreationTransitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: 'Task Creation Method', // Passez simplement le titre ici
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Retour à la page précédente
          },
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.create), // Icône pour représenter la création de tâche
            title: const Text('Create a New Task'),
            subtitle: const Text('Manually create a new task'),
            onTap: () {
              // Redirection vers la page de création de tâche manuelle
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => createTaskPage(
                    onTaskAdded: (Task newTask) async {
                      // Appel à la fonction onTaskAdded
                      return await DatabaseHelper.instance.insertTask(newTask);
                    },
                  ),
                ),
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.library_books), // Icône pour représenter les tâches prédéfinies
            title: const Text('Use a Predefined Task'),
            subtitle: const Text('Choose from predefined tasks'),
            onTap: () {
              // Redirection vers la page des tâches prédéfinies
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PredefinedTaskPage()), // Assurez-vous que PredefinedTaskPage est bien importée
              );
            },
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings), // Icône pour représenter la configuration des préférences
            title: const Text('Configure Task Planning Preferences'),
            subtitle: const Text('Set up preferences for task planning'),
            onTap: () {
              // Redirection vers la page du questionnaire des préférences utilisateur
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskCreationPlanificationQuizz(
                )),
              );
            },
          ),
        ],
      ),
    );
  }
}

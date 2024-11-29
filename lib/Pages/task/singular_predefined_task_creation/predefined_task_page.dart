import 'package:tidytime/utils/all_imports.dart';

class PredefinedTaskPage extends StatefulWidget {
  const PredefinedTaskPage({super.key});

  @override
  PredefinedTaskPageState createState() => PredefinedTaskPageState();
}

class PredefinedTaskPageState extends State<PredefinedTaskPage> with TickerProviderStateMixin {
  Map<String, String> _selectedRoom = {'key': 'All', 'name': 'All'};
  String _selectedTaskType = 'All';

  late TabController _roomTabController;
  late TabController _taskTypeTabController;
  late List<Map<String, String>> _roomChoices;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _roomChoices = _getRoomChoices(); // Initialisation des pièces traduites ici
    _initializeTabControllers();
  }

  @override
  void dispose() {
    _roomTabController.dispose();
    _taskTypeTabController.dispose();
    super.dispose();
  }

  // Initialize tab controllers dynamically based on room and task type choices
  void _initializeTabControllers() {
    _roomTabController = TabController(length: _roomChoices.length, vsync: this);
    _taskTypeTabController = TabController(length: _getTaskTypeChoices().length, vsync: this);
  }

  List<Map<String, String>> _getRoomChoices() {
    List<Map<String, String>> translatedRoomChoices = roomChoices(context); // Utilisation de la fonction centralisée
    translatedRoomChoices.insert(0, {'key': 'All', 'name': AppLocalizations.of(context)?.all ?? 'All'}); // Ajouter "All" au début
    return translatedRoomChoices;
  }

  List<String> _getTaskTypeChoices() {
    List<String> taskTypeChoicesWithAll = [...taskTypeChoices];
    taskTypeChoicesWithAll.insert(0, 'All'); // Ajouter "All" au début
    return taskTypeChoicesWithAll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: AppLocalizations.of(context)?.predefinedTasks ?? 'Predefined Tasks',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Retourner à la page précédente
          },
        ),
      ),
      body: Column(
        children: [
          SelectionTabBar(
            controller: _roomTabController,
            options: _roomChoices.map((room) => room['name']!).toList(), // Utilisation des noms traduits
            onSelectionChanged: (index) {
              setState(() {
                _selectedRoom = _roomChoices[index];
              });
            },
          ),
          SelectionTabBar(
            controller: _taskTypeTabController,
            options: _getTaskTypeChoices(),
            onSelectionChanged: (index) {
              setState(() {
                _selectedTaskType = _getTaskTypeChoices()[index];
              });
            },
          ),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    // Filtrer les tâches
    List<Map<String, dynamic>> filteredTasks = filterPredefinedTasks(
      context,
      selectedRoom: _selectedRoom['name']!, // Nom de la pièce sélectionnée
      selectedTaskType: _selectedTaskType,  // Type de tâche sélectionné
    );

    // Vérifier si aucune tâche n'est trouvée
    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.noTasksFound ?? 'No tasks found',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    // Construire la liste des tâches filtrées
    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> task = filteredTasks[index];

        // Vérifier si l'onglet "All" est sélectionné
        String subtitle;
        if (_selectedRoom['key'] == 'All') {
          // Concaténer toutes les pièces associées
          subtitle = (task['rooms'] as List<String>)
              .map((roomKey) => getTranslatedRoomName(context, roomKey))
              .join(', '); // Séparé par une virgule
        } else {
          // Afficher uniquement la pièce sélectionnée
          subtitle = getTranslatedRoomName(context, _selectedRoom['key']!);
        }

        return ListTile(
          title: Text(task['taskName']),
          subtitle: Text(subtitle), // Affiche la pièce ou les pièces associées
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PredefinedTaskWizardPage(predefinedTask: task),
              ),
            );
          },
        );
      },
    );
  }
}

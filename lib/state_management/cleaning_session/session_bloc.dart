import 'package:tidytime/utils/all_imports.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final TaskService taskService;
  final TimerService timerService;

  // Variable pour gérer la visibilité du widget flottant
  bool _isFloatingVisible = false;
  // Variable pour gérer le mode plein écran
  bool _isFullScreen = false;

  // Getter pour accéder à ces variables à partir de l'extérieur
  bool get isFloatingVisible => _isFloatingVisible;
  bool get isFullScreen => _isFullScreen;

  SessionBloc(this.taskService, this.timerService) : super(SessionInitial()) {
    on<StartSession>(_onStartSession);
    on<StopSession>(_onStopSession);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<CancelSession>(_onCancelSession);
    on<UpdateTimer>(_onUpdateTimer);
    on<ToggleFloatingVisibilityEvent>((event, emit) {
      _toggleFloatingVisibility(event.isFloatingVisible, emit);
    });
    on<ToggleFullScreenEvent>((event, emit) {
      _toggleFullScreen(event.isFullScreen, emit);
    });
  }

  Future<void> _onStartSession(StartSession event, Emitter<SessionState> emit) async {
    try {
      // Vérifier si une session est déjà en cours
      if (state is SessionInProgress) {
        print("Session déjà en cours, synchronisation des données.");

        // Émettre l'état actuel pour s'assurer que l'UI reste à jour
        final currentState = state as SessionInProgress;
        emit(SessionInProgress(
          currentState.tasks,
          currentState.completedTaskIds,
          currentState.elapsedTimeMap,
          currentState.startTime,
        ));

        // Ne pas réinitialiser la session mais continuer à synchroniser l'état
        return;
      }

      // Réinitialiser les données de la session lors d'une nouvelle session
      await _resetSessionData();
      _isFloatingVisible = false;

      // Ouvrir la boîte Hive pour les logs temporaires
      var taskLogBox = await Hive.openBox<TemporaryTaskTimerLog>('temporaryTaskLogs');
      List<Task> tasks = [];
      Map<int, String> elapsedTimeMap = {};

      // Charger les tâches modifiées ou récupérer les logs depuis Hive
      if (event.modifiedTasks != null && event.modifiedTasks!.isNotEmpty) {
        tasks = event.modifiedTasks!;
      } else if (taskLogBox.isNotEmpty) {
        tasks = taskLogBox.values.map((log) {
          elapsedTimeMap[log.taskId] = _formatElapsedTime(log.elapsedTime);
          return Task(
            id: log.taskId,
            taskName: "Task ${log.taskId}",
            room: "Room",
            repeatValue: 1,
            repeatUnit: 'days',
            startDate: DateTime.now(),
          );
        }).toList();
      } else {
        // Si pas de logs, on récupère les tâches dues ou en retard
        final taskMaps = await taskService.getTasksDueTodayOrOverdue();
        tasks = taskMaps.map((taskMap) => Task.fromMap(taskMap)).toList();
      }

      // Tâches déjà complétées (depuis Hive)
      final completedTaskIds = taskLogBox.values
          .where((log) => log.status)
          .map((log) => log.taskId)
          .toList();

      // Définir l'heure de début
      DateTime startTime = DateTime.now();

      // Émettre l'état de la session en cours
      emit(SessionInProgress(tasks, completedTaskIds, elapsedTimeMap, startTime));

      // Lancer le timer si non déjà démarré
      if (!timerService.isRunning) {
        timerService.start((elapsedTime) {
          add(UpdateTimer(elapsedTime));  // Ajouter l'événement UpdateTimer pour mettre à jour le bloc
        });
      }
    } catch (e) {
      print("Erreur lors du démarrage de la session : $e");
      emit(SessionError('Failed to start session'));
    }
  }

  Future<void> _resetSessionData() async {
    // Réinitialiser les logs temporaires
    final taskLogBox = await Hive.openBox<TemporaryTaskTimerLog>('temporaryTaskLogs');
    await taskLogBox.clear();  // Effacer tous les logs temporaires

    // Réinitialiser le chronomètre
    timerService.reset();  // Réinitialiser complètement le timer

    // Masquer le widget flottant
    _isFloatingVisible = false;
  }

  Future<void> _onStopSession(StopSession event, Emitter<SessionState> emit) async {
    try {
      // Ouvrir la base Hive pour récupérer les logs temporaires
      final taskLogBox = await Hive.openBox<TemporaryTaskTimerLog>('temporaryTaskLogs');

      // Récupérer les tâches complétées depuis l'état actuel
      final tasks = (state as SessionInProgress).tasks;
      final completedTaskIds = (state as SessionInProgress).completedTaskIds;

      // Initialiser TaskCompletionService pour marquer les tâches comme complétées
      final taskCompletionService = TaskCompletionService(DatabaseHelper(), TaskDetailsFetcher());

      // Stocker temporairement les logs pour toutes les tâches (éviter la suppression pendant la boucle)
      final Map<int, List<TemporaryTaskTimerLog>> tempLogsByTask = {};
      for (final log in taskLogBox.values) {
        if (!tempLogsByTask.containsKey(log.taskId)) {
          tempLogsByTask[log.taskId] = [];
        }
        tempLogsByTask[log.taskId]!.add(log);
      }

      // Traiter chaque tâche complétée
      for (final taskId in completedTaskIds) {
        final task = tasks.firstWhere((task) => task.id == taskId);
        if (task == null) continue; // Skip if task is not found

        final logsForTask = tempLogsByTask[taskId] ?? [];
        if (logsForTask.isEmpty) {
          print('No logs found for taskId $taskId. Skipping completion.');
          continue; // Skip tasks with no logs
        }

        logsForTask.sort((a, b) => b.endTime.compareTo(a.endTime));
        final logWithMaxEndTime = logsForTask.first;

        final taskTimeLog = TaskTimeLog(
          id: UniqueKey().hashCode,
          taskId: logWithMaxEndTime.taskId,
          logDate: DateTime.now(),
          timeTook: logWithMaxEndTime.elapsedTime,
        );

        final taskTimeLogger = TaskTimeLogger(taskId: task.id!);
        await taskTimeLogger.insertTaskTimeLog(taskTimeLog);

        await taskCompletionService.markTaskAsCompleted(task.id!, task);
      }

      // Effacer les logs Hive temporaires après traitement
      await taskLogBox.clear();

      // Émettre l'état de session arrêtée
      emit(SessionStopped(event.endTime));

      // Redirect to the home page after session is stopped
      Navigator.of(event.context).popUntil((route) => route.isFirst);  // Navigate back to the home page
    } catch (e) {
      emit(SessionError('Erreur lors de l\'arrêt de la session : $e'));
    }
  }

  Future<void> _onCancelSession(CancelSession event, Emitter<SessionState> emit) async {
    try {
      // Arrêter le timer et masquer le widget flottant
      await _resetSessionData();

      // Émettre l'état de session annulée
      emit(SessionCanceled());
    } catch (e) {
      emit(SessionError('Erreur lors de l’annulation de la session : $e'));
    }
  }

  void _onUpdateTaskStatus(UpdateTaskStatus event, Emitter<SessionState> emit) async {
    final currentState = state;

    // Ouvrir la boîte Hive pour stocker et récupérer les logs
    final taskLogBox = await Hive.openBox<TemporaryTaskTimerLog>('temporaryTaskLogs');

    if (currentState is SessionInProgress) {
      // Copie de l'état actuel pour effectuer des mises à jour
      List<Task> updatedTasks = [...currentState.tasks];
      Map<int, String> updatedElapsedTimeMap = {...currentState.elapsedTimeMap};
      List<int> updatedCompletedTaskIds = [...currentState.completedTaskIds];

      if (event.isCompleted) {
        // Récupérer l'heure actuelle du TimerService
        int currentEndTime = timerService.getElapsedTime();

        // Identifier le log avec le temps de fin le plus élevé pour calculer le temps écoulé
        TemporaryTaskTimerLog? highestEndTimeLog = taskLogBox.values.fold<TemporaryTaskTimerLog?>(null, (prev, curr) {
          return prev == null || curr.endTime > prev.endTime ? curr : prev;
        });

        int startTime = highestEndTimeLog?.endTime ?? 0; // Par défaut, démarrer à 0 si aucun log
        int elapsedTime = currentEndTime - startTime;

        // Créer et enregistrer un nouveau log pour la tâche marquée comme terminée
        TemporaryTaskTimerLog newLog = TemporaryTaskTimerLog(
          taskId: event.taskId,
          startTime: startTime,
          endTime: currentEndTime,
          elapsedTime: elapsedTime,
          status: true,
        );

        // Ajout du print pour vérifier le contenu du log
        print('Creating new log for taskId ${event.taskId}: $newLog');

        await taskLogBox.put(event.taskId, newLog);

        // Mettre à jour le temps écoulé pour l'affichage
        updatedElapsedTimeMap[event.taskId] = _formatElapsedTime(newLog.elapsedTime);

        // Ajouter l'ID de la tâche à la liste des tâches terminées
        if (!updatedCompletedTaskIds.contains(event.taskId)) {
          updatedCompletedTaskIds.add(event.taskId);
        }
      } else {
        // Gestion de la tâche décochée (non terminée)
        List<TemporaryTaskTimerLog> logsForTask = taskLogBox.values
            .where((log) => log.taskId == event.taskId)
            .toList();

        if (logsForTask.isNotEmpty) {
          // Supprimer le dernier log de la tâche marquée comme non terminée
          logsForTask.sort((a, b) => b.endTime.compareTo(a.endTime));
          TemporaryTaskTimerLog logToDelete = logsForTask.first;

          await taskLogBox.delete(logToDelete.taskId);
          updatedElapsedTimeMap.remove(event.taskId);
          updatedCompletedTaskIds.remove(event.taskId);
        }
      }

      // Émettre un nouvel état avec les mises à jour
      emit(SessionInProgress(
        updatedTasks,
        updatedCompletedTaskIds,
        updatedElapsedTimeMap,
        currentState.startTime,
      ));
    }
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<SessionState> emit) {
    if (state is SessionInProgress) {
      final currentState = state as SessionInProgress;

      // Copy the existing elapsedTimeMap and update the time
      final updatedElapsedTimeMap = Map<int, String>.from(currentState.elapsedTimeMap)
        ..[-1] = _formatElapsedTime(event.elapsedTime);

      // Emitting a new state with updated elapsed time
      emit(SessionInProgress(
        List.from(currentState.tasks), // Ensure a new instance of the task list
        List.from(currentState.completedTaskIds), // Ensure a new instance of completed tasks
        updatedElapsedTimeMap, // The updated elapsed time map
        currentState.startTime, // The same start time
      ));
    }
  }


  void _toggleFullScreen(bool isFullScreen, Emitter<SessionState> emit) {
    _isFullScreen = isFullScreen;

    // Réémettre l'état pour forcer la mise à jour de l'UI
    if (!_isFullScreen) {
      _toggleFloatingVisibility(true, emit);
    } else {
      _toggleFloatingVisibility(false, emit);
    }

    // Réémettre l'état actuel pour forcer la mise à jour
    if (state is SessionInProgress) {
      final currentState = state as SessionInProgress;
      emit(SessionInProgress(
        currentState.tasks,
        currentState.completedTaskIds,
        currentState.elapsedTimeMap,
        currentState.startTime,
      ));
    }
  }

  void _toggleFloatingVisibility(bool isVisible, Emitter<SessionState> emit) {
    _isFloatingVisible = isVisible;
    print(_isFloatingVisible ? 'Widget flottant visible.' : 'Masquage du widget flottant.');

    // Réémettre l'état actuel pour forcer la mise à jour
    if (state is SessionInProgress) {
      final currentState = state as SessionInProgress;
      emit(SessionInProgress(
        currentState.tasks,
        currentState.completedTaskIds,
        currentState.elapsedTimeMap,
        currentState.startTime,
      ));
    }
  }


  String _formatElapsedTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }
}

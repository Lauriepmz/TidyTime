import 'package:tidytime/utils/all_imports.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = _join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 21,
      onCreate: (db, version) {
        // Crée la table tasks avec la nouvelle colonne taskType
        db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskName TEXT NOT NULL,
        room TEXT NOT NULL,
        repeatValue INTEGER NOT NULL,
        repeatUnit TEXT NOT NULL,
        startDate TEXT NOT NULL,
        dueDateLastDone TEXT,
        dueDateLastDoneProposed TEXT,
        lastDone TEXT,
        lastDoneProposed TEXT,
        taskType TEXT
      )
    ''');

        // Create the other tables
        db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL
      )
    ''');

        db.execute('''
      CREATE TABLE custom_rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        roomName TEXT NOT NULL UNIQUE
      )
    ''');

        db.execute('''
      CREATE TABLE completion_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        completionDate TEXT NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

        db.execute('''
      CREATE TABLE profile_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL
      )
    ''');

        // Create the task_time_logs table, allowing NULL values for taskId and endTime
        db.execute('''
       CREATE TABLE task_time_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,  
        logDate TEXT NOT NULL,     
        timeTook INTEGER NOT NULL,    
        FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
      )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 21) {
          // Ajoute la colonne 'taskType' dans la table existante
          await db.execute('ALTER TABLE tasks ADD COLUMN taskType TEXT');
        }
      },
    );
  }

// Mettre à jour ou insérer une préférence utilisateur
  Future<void> setUserPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace, // Remplace la valeur si la clé existe déjà
    );
  }

// Récupérer une préférence utilisateur
  Future<String?> getUserPreference(String key, {String? defaultValue}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isNotEmpty) {
      return results.first['value'] as String;
    }

    // Retourne la valeur par défaut si la clé n'existe pas
    return defaultValue;
  }

  String _join(String part1, String part2) {
    return '$part1/$part2';
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return maps.map((map) {
      return Map<String, dynamic>.from({
        'id': map['id'],
        'taskName': map['taskName'] ?? 'Unnamed Task',
        'room': map['room'] ?? 'Unknown Room',
        'repeatDays': map['repeatDays'] ?? 1,
        'repeatPeriod': map['repeatPeriod'] ?? 'days',
        'startDate': DateHelper.sqlToDateTime(map['startDate'] as String),
        'dueDate': map['dueDate'] != null ? DateHelper.sqlToDateTime(map['dueDate'] as String) : null,
        'lastDone': map['lastDone'] != null ? DateHelper.sqlToDateTime(map['lastDone'] as String) : null,
        'lastDoneProposed': map['lastDoneProposed'] != null ? DateHelper.sqlToDateTime(map['lastDoneProposed'] as String) : null,
        'dueDateLastDoneProposed': map['dueDateLastDoneProposed'] != null ? DateHelper.sqlToDateTime(map['dueDateLastDoneProposed'] as String) : null,  // Handling dueDateLastDoneProposed
      });
    }).toList();
  }

  Future<List<String>> getRoomsWithTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> rooms = await db.rawQuery('SELECT DISTINCT room FROM tasks');
    return rooms.map((roomMap) => roomMap['room'] as String).toList();
  }

  // Insert new task
  Future<int> insertTask(Task task) async {
    final db = await database;

    // Use the DateCalculator for task creation
    Map<String, DateTime?> calculatedDates = DateCalculator.calculateTaskCreationDates(
      startDate: task.startDate,
    );

    // Set the calculated due dates in the task map
    Map<String, dynamic> taskMap = task.toMap();
    taskMap['dueDateLastDone'] = DateHelper.dateTimeToSql(calculatedDates['dueDateLastDone']!);
    taskMap['dueDateLastDoneProposed'] = DateHelper.dateTimeToSql(calculatedDates['dueDateLastDoneProposed']!);

    // Debug logs
    print('[INFO] Preparing to insert task into database...');
    print('Task Map: $taskMap');

    try {
      int id = await db.insert('tasks', taskMap);
      print('[SUCCESS] Task inserted into database with ID: $id');
      return id;
    } catch (e) {
      print('[ERROR] Failed to insert task into database: $e');
      rethrow;
    }
  }


  Future<void> updateTask(int id, Task updatedTask) async {
    final db = await database;

    Map<String, dynamic> updatedTaskMap = updatedTask.toMap();

    if (updatedTask.lastDone != null) {
      updatedTaskMap['lastDone'] = DateHelper.dateTimeToSql(updatedTask.lastDone!);
    } else {
      updatedTaskMap['lastDone'] = null;
    }

    if (updatedTask.lastDoneProposed != null) {
      updatedTaskMap['lastDoneProposed'] = DateHelper.dateTimeToSql(updatedTask.lastDoneProposed!);
    } else {
      updatedTaskMap['lastDoneProposed'] = null;
    }

    await db.update('tasks', updatedTaskMap, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTaskCompletion(int taskId, {
    required DateTime lastDone,  // lastDone est toujours obligatoire
    DateTime? lastDoneProposed,  // Peut être null
    DateTime? dueDateLastDone,  // Peut être null
    DateTime? dueDateLastDoneProposed,  // Peut être null
  }) async {
    final db = await database;

    Map<String, dynamic> updateFields = {
      'lastDone': DateHelper.dateTimeToSql(lastDone),  // lastDone est obligatoire
    };

    // Mise à jour des champs optionnels s'ils ne sont pas null
    if (lastDoneProposed != null) {
      updateFields['lastDoneProposed'] = DateHelper.dateTimeToSql(lastDoneProposed);
    }

    if (dueDateLastDone != null) {
      updateFields['dueDateLastDone'] = DateHelper.dateTimeToSql(dueDateLastDone);
    }

    if (dueDateLastDoneProposed != null) {
      updateFields['dueDateLastDoneProposed'] = DateHelper.dateTimeToSql(dueDateLastDoneProposed);
    }

    await db.update(
      'tasks',
      updateFields,
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Convert repeat unit to days
  int convertUnitToDays(String repeatUnit) {
    switch (repeatUnit) {
      case 'weeks':
        return 7;
      case 'months':
        return 30;
      case 'days':
      default:
        return 1;
    }
  }

  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      var taskMap = Map<String, dynamic>.from(maps.first);
      taskMap['startDate'] = taskMap['startDate'] is String
          ? DateHelper.sqlToDateTime(taskMap['startDate'] as String)
          : taskMap['startDate'];

      taskMap['lastDoneProposed'] = taskMap['lastDoneProposed'] is String
          ? DateHelper.sqlToDateTime(taskMap['lastDoneProposed'] as String)
          : taskMap['lastDoneProposed'];

      taskMap['dueDateLastDoneProposed'] = taskMap['dueDateLastDoneProposed'] is String
          ? DateHelper.sqlToDateTime(taskMap['dueDateLastDoneProposed'] as String)
          : taskMap['dueDateLastDoneProposed'];

      return taskMap;
    }
    return null;
  }


  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertCustomRoom(String roomName) async {
    final db = await database;
    await db.insert('custom_rooms', {'roomName': roomName});
  }

  Future<List<String>> getCustomRooms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('custom_rooms');
    return maps.map((map) => map['roomName'] as String).toList();
  }

  Future<void> setUserSetting(String key, String value) async {
    final db = await database;

    // Insert or update the user setting
    await db.insert(
      'user_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,  // Replace the value if the key exists
    );
  }

  Future<String?> getUserSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isNotEmpty) {
      return results.first['value'] as String;
    }
    return null;
  }
  // Insérer le chemin de l'image dans la base de données
  Future<void> insertProfileImage(String imagePath) async {
    final db = await database;

    // Supprimer l'ancienne image et insérer la nouvelle
    await db.delete('profile_images');
    await db.insert('profile_images', {'imagePath': imagePath});
  }

  Future<String?> getProfileImage() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('profile_images', limit: 1);

    if (results.isNotEmpty) {
      return results.first['imagePath'] as String;
    }
    return null;  // Si aucune image n'a été sauvegardée
  }

  Future<List<Task>> getTasksDueToday() async {
    final db = await database;
    final today = DateTime.now().toIso8601String();
    final result = await db.query(
      'tasks',
      where: 'dueDateLastDone <= ?',
      whereArgs: [today],
    );
    return result.map((taskMap) => Task.fromMap(taskMap)).toList();
  }

  Future<int?> getTaskId(int taskId) async {
    final db = await instance.database;
    // Query pour récupérer l'ID de la tâche
    final List<Map<String, dynamic>> result = await db.query(
      'tasks',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [taskId],
    );
    // Vérifier si un résultat est trouvé, sinon retourner null
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return null;
    }
  }
}

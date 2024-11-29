import 'package:tidytime/utils/all_imports.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback onTaskCompleted;
  final VoidCallback onTaskDetails;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTaskCompleted,
    required this.onTaskDetails,
  });

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin {
  bool _isClicked = false;
  late AnimationController _controller;

  // Variable pour stocker le nom traduit
  String _translatedTaskName = '';
  bool _translationInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_translationInitialized) {
      _translationInitialized = true;
      _loadTranslatedTaskName(); // Charger la traduction après les dépendances
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTaskClick() {
    setState(() {
      _isClicked = !_isClicked;
      _isClicked ? _controller.forward() : _controller.reverse();
    });
  }

  Future<void> _loadTranslatedTaskName() async {
    final locale = Localizations.localeOf(context).languageCode;
    final translatedName = await widget.task.getTranslatedName(locale);

    if (!mounted) return; // Check if the widget is still in the tree

    setState(() {
      // Decode the HTML entities in the translated text
      _translatedTaskName = HtmlUnescape().convert(translatedName);
    });
  }


  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context); // Accès à la localisation
    final double containerWidth = MediaQuery.of(context).size.width;
    final double taskWidth = containerWidth * (_isClicked ? 4 / 7 : 1);
    final double buttonWidth = (containerWidth * 3 / 7) / 2;

    final today = DateHelper.dateTimeToString(DateTime.now());
    final taskDate = DateHelper.dateTimeToString(widget.task.dueDate ?? widget.task.startDate);

    // Vérifie si la tâche est strictement avant aujourd'hui
    final isOverdue = taskDate.compareTo(today) < 0;

    return GestureDetector(
      onTap: _onTaskClick,
      child: Stack(
        children: [
          if (_isClicked)
            Positioned(
              left: taskWidth,
              top: 0,
              bottom: 0,
              child: Row(
                children: [
                  SizedBox(
                    width: buttonWidth,
                    height: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onTaskCompleted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: buttonWidth,
                    height: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onTaskDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Icon(Icons.info, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: taskWidth,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isOverdue)
                            const Icon(Icons.error, color: Colors.red, size: 16),
                          Expanded(
                            child: Text(
                              _translatedTaskName.isNotEmpty ? _translatedTaskName : widget.task.taskName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                color: isOverdue ? Colors.red : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOverdue
                            ? '${localization?.overdueSince ?? "Overdue since"}: ${DateHelper.dateTimeToString(widget.task.dueDate ?? widget.task.startDate)}'
                            : '${localization?.due ?? "Due"}: ${widget.task.dueDate != null ? DateHelper.dateTimeToString(widget.task.dueDate!) : localization?.notSet ?? "Not Set"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                if (!_isClicked)
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        ),
                        onPressed: _onTaskClick,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:tidytime/utils/all_imports.dart';

class PreferenceRankingWidget extends StatelessWidget {
  final List<String?> rankedPreferences;
  final List<String> availablePreferences;
  final Function(int, String) onRankingUpdated;
  final Function(int) onRemoveItem;
  final Function(bool) onRankingCompleted;

  const PreferenceRankingWidget({
    Key? key,
    required this.rankedPreferences,
    required this.availablePreferences,
    required this.onRankingUpdated,
    required this.onRemoveItem,
    required this.onRankingCompleted,
  }) : super(key: key);

  void _onItemDroppedOnTarget(int targetIndex, String item) {
    onRankingUpdated(targetIndex, item);
    onRankingCompleted(!rankedPreferences.contains(null));
  }

  void _onRemoveItemFromTarget(int targetIndex) {
    onRemoveItem(targetIndex);
    onRankingCompleted(!rankedPreferences.contains(null));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Rank your cleaning preferences:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Column(
            children: List.generate(rankedPreferences.length, (index) {
              return Row(
                children: [
                  Text('${index + 1}', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onRemoveItemFromTarget(index),
                      child: DragTarget<String>(
                        onAcceptWithDetails: (data) {
                          _onItemDroppedOnTarget(index, data.data);
                        },
                        builder: (context, candidateData, rejectedData) => Container(
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: rankedPreferences[index] == null
                                ? Colors.grey[200]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          height: 50,
                          alignment: Alignment.center,
                          child: Text(
                            rankedPreferences[index] ?? 'Drag here',
                            style: TextStyle(
                              fontSize: 16,
                              color: rankedPreferences[index] == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: availablePreferences.map((preference) {
                return Draggable<String>(
                  data: preference,
                  child: _buildChoiceContainer(preference),
                  feedback: Material(
                    child: _buildChoiceContainer(preference, isDragging: true),
                  ),
                  childWhenDragging: _buildChoiceContainer(preference, isDragging: true),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceContainer(String preference, {bool isDragging = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      margin: EdgeInsets.all(4.0),
      constraints: BoxConstraints(minWidth: 150, maxWidth: 200, minHeight: 50),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.withOpacity(0.5) : Colors.blue[100],
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        preference,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:tidytime/utils/all_imports.dart';

class PeriodicSelector extends StatefulWidget {
  final String repeatUnit;
  final int repeatValue;
  final ValueChanged<int>? onRepeatValueChanged;
  final ValueChanged<String>? onRepeatUnitChanged;

  const PeriodicSelector({
    super.key,
    required this.repeatUnit,
    required this.repeatValue,
    this.onRepeatValueChanged,
    this.onRepeatUnitChanged,
  });

  @override
  _PeriodicSelectorState createState() => _PeriodicSelectorState();
}

class _PeriodicSelectorState extends State<PeriodicSelector> {
  late String _repeatUnit;
  late int _repeatValue;
  int _minRepeatValue = 1;
  int _maxRepeatValue = 28;

  @override
  void initState() {
    super.initState();
    _repeatUnit = widget.repeatUnit;
    _repeatValue = widget.repeatValue;
    _updateRepeatRange();
  }

  void _updateRepeatRange() {
    switch (_repeatUnit) {
      case 'days':
        _minRepeatValue = 1;
        _maxRepeatValue = 28;
        break;
      case 'weeks':
        _minRepeatValue = 1;
        _maxRepeatValue = 52;
        break;
      case 'months':
        _minRepeatValue = 1;
        _maxRepeatValue = 12;
        break;
      default:
        _minRepeatValue = 1;
        _maxRepeatValue = 28;
    }

    if (_repeatValue > _maxRepeatValue) {
      _repeatValue = _maxRepeatValue;
    } else if (_repeatValue < _minRepeatValue) {
      _repeatValue = _minRepeatValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repeat Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _repeatUnit,
              onChanged: (String? newUnit) {
                setState(() {
                  _repeatUnit = newUnit ?? 'days';
                  widget.onRepeatUnitChanged?.call(newUnit!);
                  _updateRepeatRange();
                });
              },
              items: const [
                DropdownMenuItem(value: 'days', child: Text('Days')),
                DropdownMenuItem(value: 'weeks', child: Text('Weeks')),
                DropdownMenuItem(value: 'months', child: Text('Months')),
              ],
            ),
            const SizedBox(height: 10),
            Slider(
              value: _repeatValue.toDouble(),
              min: _minRepeatValue.toDouble(),
              max: _maxRepeatValue.toDouble(),
              divisions: _maxRepeatValue - _minRepeatValue,
              label: '$_repeatValue',
              onChanged: (double value) {
                setState(() {
                  _repeatValue = value.toInt();
                  widget.onRepeatValueChanged?.call(_repeatValue);
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              'This task will repeat every $_repeatValue $_repeatUnit(s)',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

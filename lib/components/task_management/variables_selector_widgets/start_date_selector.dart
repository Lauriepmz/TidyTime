import 'package:tidytime/utils/all_imports.dart';

class StartDateSelectorWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const StartDateSelectorWidget({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Select Start Date', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        CalendarDatePicker(
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          onDateChanged: onDateChanged,
        ),
      ],
    );
  }
}

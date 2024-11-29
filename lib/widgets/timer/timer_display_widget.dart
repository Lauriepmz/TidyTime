import 'package:tidytime/utils/all_imports.dart';

class TimerDisplayWidget extends StatelessWidget {
  final String formattedTime;
  final bool isFullScreen;

  const TimerDisplayWidget({
    super.key,
    required this.formattedTime,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSize = isFullScreen ? 48 : 25;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        formattedTime,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

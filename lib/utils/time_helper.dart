import 'package:intl/intl.dart';

class TimeHelper {
  // Méthode pour formater une durée (en secondes) en format hh:mm:ss
  static String formatDurationFromSeconds(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$remainingSeconds";
  }

  // Méthode pour convertir une chaîne de temps au format hh:mm:ss en secondes (int)
  static int parseFormattedTimeToSeconds(String formattedTime) {
    final parts = formattedTime.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);

    return (hours * 3600) + (minutes * 60) + seconds;
  }

  // Méthode pour calculer la différence entre deux chaînes de temps au format hh:mm:ss
  static String calculateElapsedTime(String startTime, String endTime) {
    int startSeconds = parseFormattedTimeToSeconds(startTime);
    int endSeconds = parseFormattedTimeToSeconds(endTime);
    int differenceInSeconds = endSeconds - startSeconds;

    return formatDurationFromSeconds(differenceInSeconds);
  }

  // Méthode pour convertir une DateTime en format hh:mm:ss
  static String dateTimeToFormattedTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  // Méthode pour convertir une DateTime en secondes depuis minuit
  static int dateTimeToSeconds(DateTime dateTime) {
    return (dateTime.hour * 3600) + (dateTime.minute * 60) + dateTime.second;
  }
}

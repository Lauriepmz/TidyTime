import 'package:tidytime/utils/all_imports.dart';

part 'temporary_time_proportion_model.g.dart'; // Indique à Hive de générer le fichier

@HiveType(typeId: 1)
class TimeProportion {
  @HiveField(0)
  final String day;

  @HiveField(1)
  final double allocatedProportion;

  TimeProportion({required this.day, required this.allocatedProportion});
}


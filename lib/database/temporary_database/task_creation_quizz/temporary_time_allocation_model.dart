import 'package:tidytime/utils/all_imports.dart';

part 'temporary_time_allocation_model.g.dart'; // Indique à Hive de générer le fichier

@HiveType(typeId: 2)
class TimeAllocation extends HiveObject {
  @HiveField(0)
  final String day;

  @HiveField(1)
  final double allocatedTime;

  TimeAllocation({required this.day, required this.allocatedTime});
}

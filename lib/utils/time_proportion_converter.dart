import 'package:tidytime/utils/all_imports.dart';

class TimeProportionConverter {
  final Box<TimeProportion> timeProportionBox;
  final Box<TimeAllocation> timeAllocationBox;

  TimeProportionConverter({
    required this.timeProportionBox,
    required this.timeAllocationBox,
  });

  // Stores daily time allocations and converts them to proportions for storage.
  Future<void> storeTimeAllocationsAndConvert(Map<String, double> dailyTimeAllocation) async {
    // Calculate total allocated time for the week
    double totalTime = dailyTimeAllocation.values.fold(0, (sum, value) => sum + value);

    // Store each day's allocation in the `TimeAllocation` box and convert to proportion in `TimeProportion`
    for (var entry in dailyTimeAllocation.entries) {
      double proportion = totalTime > 0 ? entry.value / totalTime : 0;

      // Store in TimeAllocation box
      var timeAllocation = TimeAllocation(day: entry.key, allocatedTime: entry.value);
      await timeAllocationBox.put(entry.key, timeAllocation);

      // Store converted proportion in TimeProportion box
      var timeProportion = TimeProportion(day: entry.key, allocatedProportion: proportion);
      await timeProportionBox.put(entry.key, timeProportion);
    }

    // Store total proportion with the 'total' key in `TimeProportion` box
    if (totalTime > 0) {
      var total = TimeProportion(day: 'total', allocatedProportion: 1.0);
      await timeProportionBox.put('total', total);
    } else {
      await timeProportionBox.delete('total');
    }
  }

  // Loads daily time allocations from the Hive `TimeAllocation` box.
  Future<Map<String, double>> loadDailyTimeAllocations() async {
    Map<String, double> allocations = {};

    for (var key in timeAllocationBox.keys) {
      TimeAllocation? timeAllocation = timeAllocationBox.get(key);
      if (timeAllocation != null) {
        allocations[key as String] = timeAllocation.allocatedTime;
      }
    }

    return allocations;
  }

  // Loads daily proportions from the Hive `TimeProportion` box.
  Future<Map<String, double>> loadDailyProportions() async {
    Map<String, double> proportions = {};

    for (var key in timeProportionBox.keys) {
      if (key != 'total') { // Skip 'total' as it's a special entry
        TimeProportion? timeProportion = timeProportionBox.get(key);
        if (timeProportion != null) {
          proportions[key as String] = timeProportion.allocatedProportion;
        }
      }
    }

    return proportions;
  }

  // Calculates and returns daily proportions based on provided times.
  Map<String, double> calculateDailyProportion(Map<String, double> dailyTimeAllocation) {
    double totalTime = dailyTimeAllocation.values.fold(0, (sum, value) => sum + value);
    Map<String, double> proportions = {};

    dailyTimeAllocation.forEach((day, time) {
      double proportion = totalTime > 0 ? time / totalTime : 0;
      proportions[day] = proportion;
    });

    return proportions;
  }
}

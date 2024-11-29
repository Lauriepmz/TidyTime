import 'package:tidytime/utils/all_imports.dart';

part 'temporary_quizz_results_model.g.dart';

@HiveType(typeId: 5) // Ensure this typeId is unique in your app's models
class QuizzResults extends HiveObject {
  @HiveField(0)
  int question;

  @HiveField(1)
  int rank;

  @HiveField(2)
  int answer;

  QuizzResults({
    required this.question,
    required this.rank,
    required this.answer,
  });
}

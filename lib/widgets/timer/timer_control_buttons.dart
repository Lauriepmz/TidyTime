import 'package:tidytime/utils/all_imports.dart';

class TimerControlButtons extends StatelessWidget {
  final TimerService timerService;
  final double iconSize;

  const TimerControlButtons({
    super.key,
    required this.timerService,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Bouton Play/Pause dynamique selon l'état du Timer
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              timerService.isRunning ? Icons.pause : Icons.play_arrow, // Icône changeante
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () {
              if (timerService.isRunning) {
                // Si le timer est en cours, on le met en pause
                print("Bouton Pause appuyé");
                timerService.pause();
              } else {
                // Si le timer est arrêté ou en pause, on le démarre
                print("Bouton Play appuyé");
                timerService.start((elapsedSeconds) {
                  // Callback ou mise à jour du temps ici
                });
              }
            },
          ),
        ),

        // Bouton Stop
        Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(Icons.stop, color: Colors.white, size: iconSize),
            onPressed: timerService.isRunning
                ? () {
              print("Bouton Stop appuyé");
              // Afficher la boîte de dialogue de confirmation avant d'arrêter le timer
              showStopCleaningSessionDialog(
                context,
                    (context) async {
                  // Appeler la méthode stop après confirmation
                  timerService.stop();
                  // Pass both DateTime and context to StopSession
                  context.read<SessionBloc>().add(StopSession(DateTime.now(), context));
                },
              );
            }
                : null, // Désactivé si déjà stoppé
          ),
        ),
      ],
    );
  }
}

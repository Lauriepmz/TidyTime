import 'package:tidytime/utils/all_imports.dart';

class EmptyTaskContainer extends StatelessWidget {
  final String message;
  final VoidCallback oncreateTask;

  const EmptyTaskContainer({
    super.key,
    required this.message, // Message to show
    required this.oncreateTask, // Callback to handle add task action
  });

  @override
  Widget build(BuildContext context) {
    return ButtonStyles.gradientContainer(
      child: Container(
        padding: const EdgeInsets.all(16.0), // Optional padding for spacing
        color: Colors.transparent, // Transparent since the gradient is applied to the outer container
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black, // Text in black
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Small white square button with "+" icon
              GestureDetector(
                onTap: oncreateTask, // Trigger the oncreateTask callback
                child: ButtonStyles.gradientContainer(
                  pattern: GradientPattern.patternTwo,  // Apply Pattern 2 here
                  borderRadius: 10,  // Add border radius of 10
                  child: SizedBox(
                    width: 60,  // Small square size
                    height: 60,
                    child: const Center(
                      child: Icon(
                        Icons.add,  // "+" icon
                        color: Colors.black,  // Icon color
                        size: 30,  // Icon size
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

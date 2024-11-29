import 'package:tidytime/utils/all_imports.dart';

// Enum for color pattern selection
enum GradientPattern {
  patternOne,
  patternTwo,
  patternThree, // Add Pattern 3
}

class ButtonStyles {
  // Method to create a button with a gradient and adjustable font size
  static Widget gradientButton({
    required String label,
    required VoidCallback onPressed,
    double fontSize = 16, // Default font size set to 16
    GradientPattern pattern = GradientPattern.patternOne, // Default color pattern set to patternOne
  }) {
    // Define the colors for each pattern
    List<Color> colors;
    Color textColor = Colors.black; // Default text color

    if (pattern == GradientPattern.patternOne) {
      colors = const [
        Color(0xFFB0CFFD), // Start color
        Color(0xFFD5E3FD), // End color
        Color(0xFFB0CFFD), // Start color
      ];
    } else if (pattern == GradientPattern.patternTwo) {
      colors = const [
        Color(0xFF6AA7EA), // Start color
        Color(0xFFA9C8FC), // Middle color
        Color(0xFF6AA7EA), // End color
      ];
    } else {
      // Pattern 3 colors
      colors = const [
        Color(0xFFD39BDD), // Start color
        Color(0xFFD6B5DC), // Middle color
        Color(0xFFD39BDD), // End color
      ];
      textColor = const Color(0xFF9C27B0); // Set text color to #9C27B0 only for patternThree
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors, // Use the selected color pattern
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize, // Use the specified font size
              color: textColor, // Apply the custom text color based on the pattern
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Method to create a container with gradient (for room tiles, etc.)
  static Widget gradientContainer({
    required Widget child,
    GradientPattern pattern = GradientPattern.patternOne, // Default pattern for containers
    double borderRadius = 0,
  }) {
    // Define the colors for each pattern
    List<Color> colors;
    if (pattern == GradientPattern.patternOne) {
      colors = const [
        Color(0xFFC3D9FD), // Start color
        Color(0xFFEEF2FA), // End color
        Color(0xFFC3D9FD), // Start color
      ];
    } else if (pattern == GradientPattern.patternTwo) {
      colors = const [
        Color(0xFF81ABE5), // Start color
        Color(0xFFA9C8FC), // Middle color
        Color(0xFF81ABE5), // End color
      ];
    } else {
      // Pattern 3 colors
      colors = const [
        Color(0xFFD39BDD), // Start color
        Color(0xFFD6B5DC), // Middle color
        Color(0xFFD39BDD), // End color
      ];
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),  // Apply custom border radius
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors, // Use the selected color pattern
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }
}

import 'package:tidytime/utils/all_imports.dart';

class FullScreenIcon extends StatelessWidget {
  final VoidCallback onFullScreenPressed;
  final VoidCallback? onClosePressed;  // Optional callback for the 'X' button
  final double iconSize;
  final bool showCloseButton;  // Condition to show the 'X' button

  const FullScreenIcon({
    super.key,
    required this.onFullScreenPressed,
    this.onClosePressed,  // 'X' button callback is optional
    required this.iconSize,
    this.showCloseButton = false,  // By default, the close button is not shown
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 10,
          top: 10,
          child: IconButton(
            icon: Icon(Icons.fullscreen, color: Colors.white, size: iconSize),
            onPressed: onFullScreenPressed,
          ),
        ),
        if (showCloseButton && onClosePressed != null)
          Positioned(
            left: 10,
            top: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: iconSize),
              onPressed: onClosePressed,
            ),
          ),
      ],
    );
  }
}

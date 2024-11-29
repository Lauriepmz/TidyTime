import 'package:tidytime/utils/all_imports.dart';

class HeaderStyles {
  // Méthode pour créer un AppBar avec gradient et leading widget
  static PreferredSizeWidget gradientAppBar(String title, {Widget? leading}) {
    return AppBar(
      title: Text(title),
      leading: leading,  // Allow for custom leading widget (e.g., hamburger menu)
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6AA7EA), // Couleur de départ
              Color(0xFFA9C8FC), // Couleur de milieu
              Color(0xFF6AA7EA), // Couleur de fin
            ],
          ),
        ),
      ),
      centerTitle: true,
    );
  }
}

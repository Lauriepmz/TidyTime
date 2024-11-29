import 'package:tidytime/utils/all_imports.dart'; // Import relevant utils

class ProfileImageSelector {
  final BuildContext context;
  final Function(String) onImageSelected; // Callback when an image is selected
  final Function(String) onCustomImageSelected; // Callback for custom image

  ProfileImageSelector({
    required this.context,
    required this.onImageSelected,
    required this.onCustomImageSelected,
  });

  // Method to show profile image selection overlay
  void showImageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to adjust its size dynamically
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // Adjust height based on screen size (50% of screen height)
          child: _buildImageSelectorOverlay(),
        );
      },
    );
  }

  // Build the UI for image selection overlay
  Widget _buildImageSelectorOverlay() {
    final localization = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization?.chooseProfilePicture ?? 'Choose your profile picture',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Predefined images in 3x3 grid
              _buildPredefinedImageGrid(),
            ],
          ),
          // Button to select a custom image from gallery at the bottom
          Positioned(
            bottom: 0, // Position the button at the bottom
            left: 0,
            right: 0,
            child: _buildCustomImageButton(),
          ),
        ],
      ),
    );
  }

  // Build predefined images grid (3x3)
  Widget _buildPredefinedImageGrid() {
    const List<String> predefinedImages = [
      'assets/images/profile/M1.png',
      'assets/images/profile/M2.png',
      'assets/images/profile/M3.png',
      'assets/images/profile/W1.png',
      'assets/images/profile/W2.png',
      'assets/images/profile/W3.png',
    ];

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 images per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: predefinedImages.length,
        itemBuilder: (context, index) {
          final imagePath = predefinedImages[index];
          return GestureDetector(
            onTap: () {
              onImageSelected(imagePath); // Call the callback with the selected image path
              _saveImageToDatabase(imagePath); // Save predefined image to database
              Navigator.pop(context); // Close the overlay
            },
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(imagePath),
            ),
          );
        },
      ),
    );
  }

  // Build button to choose a custom image from the device gallery
  Widget _buildCustomImageButton() {
    final localization = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () async {
        _selectCustomImageFromGallery(); // Open gallery for custom image selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
        margin: const EdgeInsets.only(bottom: 10), // Add some margin at the bottom
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              localization?.chooseFromGallery ?? 'Choose from Gallery',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Method to select custom image from the gallery
  Future<void> _selectCustomImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String customImagePath = pickedFile.path;
      onCustomImageSelected(customImagePath); // Call callback with the custom image path
      _saveImageToDatabase(customImagePath); // Save custom image path to database
      Navigator.pop(context); // Close the overlay
    }
  }

  // Method to save the selected image (predefined or custom) to the database
  Future<void> _saveImageToDatabase(String imagePath) async {
    try {
      await DatabaseHelper.instance.insertProfileImage(imagePath);
      print('Image path saved to database: $imagePath');
    } catch (e) {
      print('Error saving image to database: $e');
    }
  }
}

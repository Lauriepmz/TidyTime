import 'package:tidytime/utils/all_imports.dart';  // Import relevant utils

class MainDrawer extends StatefulWidget {
  final VoidCallback onCreateTaskPressed;
  final VoidCallback onStartCleaningPressed;

  const MainDrawer({
    super.key,
    required this.onCreateTaskPressed,
    required this.onStartCleaningPressed,
  });

  @override
  MainDrawerState createState() => MainDrawerState();
}

class MainDrawerState extends State<MainDrawer> {
  String? selectedImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Method to load the profile image from the database
  Future<void> _loadProfileImage() async {
    String? savedImagePath = await DatabaseHelper.instance.getProfileImage();
    setState(() {
      selectedImagePath = savedImagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // Trigger the profile image selector
              ProfileImageSelector(
                context: context,
                onImageSelected: (selectedImagePath) async {
                  // Save selected predefined image to the database
                  await DatabaseHelper.instance.insertProfileImage(selectedImagePath);
                  setState(() {
                    this.selectedImagePath = selectedImagePath;
                  });
                  print('Predefined image selected and saved: $selectedImagePath');
                },
                onCustomImageSelected: (customImagePath) async {
                  // Save selected custom image to the database
                  await DatabaseHelper.instance.insertProfileImage(customImagePath);
                  setState(() {
                    selectedImagePath = customImagePath;
                  });
                  print('Custom image selected and saved: $customImagePath');
                },
              ).showImageSelector();  // Show the image selector overlay
            },
            child: ButtonStyles.gradientContainer(
              pattern: GradientPattern.patternTwo,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: selectedImagePath != null
                            ? (selectedImagePath!.contains('assets')
                            ? AssetImage(selectedImagePath!)
                            : FileImage(File(selectedImagePath!)) as ImageProvider)
                            : const AssetImage('assets/images/profile/default_avatar.png'),  // Replace with a local default image
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          Text(
                            "Laurie Poitras",  // Dynamic account name
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_task),
            title: const Text('Create Task'),
            onTap: widget.onCreateTaskPressed,  // Call the function when "Create Task" is pressed
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Start Cleaning'),
            onTap: widget.onStartCleaningPressed,  // Trigger the method in MainPage
          ),
        ],
      ),
    );
  }
}

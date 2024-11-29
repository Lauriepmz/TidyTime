import 'package:tidytime/utils/all_imports.dart';

List<Map<String, String>> roomChoices(BuildContext context) {
  final localization = AppLocalizations.of(context);

  final List<Map<String, String>> choices = [
    {'key': 'Attic', 'name': localization?.attic ?? 'Attic'},
    {'key': 'Basement', 'name': localization?.basement ?? 'Basement'},
    {'key': 'Bathroom', 'name': localization?.bathroom ?? 'Bathroom'},
    {'key': 'Bedroom', 'name': localization?.bedroom ?? 'Bedroom'},
    {'key': "Children's Bedroom", 'name': localization?.childrensBedroom ?? "Children's Bedroom"},
    {'key': 'Closet', 'name': localization?.closet ?? 'Closet'},
    {'key': 'Corridor', 'name': localization?.corridor ?? 'Corridor'},
    {'key': 'Dining Room', 'name': localization?.diningRoom ?? 'Dining Room'},
    {'key': 'Entryway', 'name': localization?.entryway ?? 'Entryway'},
    {'key': 'Entire Home', 'name': localization?.entireHome ?? 'Entire Home'},
    {'key': 'Garage', 'name': localization?.garage ?? 'Garage'},
    {'key': 'Guest Bedroom', 'name': localization?.guestBedroom ?? 'Guest Bedroom'},
    {'key': 'Home Gym', 'name': localization?.homeGym ?? 'Home Gym'},
    {'key': 'Home Office', 'name': localization?.homeOffice ?? 'Home Office'},
    {'key': 'Kitchen', 'name': localization?.kitchen ?? 'Kitchen'},
    {'key': 'Laundry Room', 'name': localization?.laundryRoom ?? 'Laundry Room'},
    {'key': 'Living Room', 'name': localization?.livingRoom ?? 'Living Room'},
    {'key': 'Master Bedroom', 'name': localization?.masterBedroom ?? 'Master Bedroom'},
    {'key': 'Nursery', 'name': localization?.nursery ?? 'Nursery'},
    {'key': 'Pantry', 'name': localization?.pantry ?? 'Pantry'},
    {'key': 'Play Room', 'name': localization?.playRoom ?? 'Play Room'},
    {'key': 'Storage Room', 'name': localization?.storageRoom ?? 'Storage Room'},
    {'key': 'Terrace/Patio', 'name': localization?.terracePatio ?? 'Terrace/Patio'},
  ];

  return choices;
}

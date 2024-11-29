import 'package:tidytime/utils/all_imports.dart';

class SelectionTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> options;
  final ValueChanged<int> onSelectionChanged;

  const SelectionTabBar({
    Key? key,
    required this.controller,
    required this.options,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      onTap: onSelectionChanged,
      tabs: options.map((option) => Tab(text: option)).toList(),
    );
  }
}

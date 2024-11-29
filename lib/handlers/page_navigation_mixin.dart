import 'package:tidytime/utils/all_imports.dart';

mixin PageNavigationMixin<T extends StatefulWidget> on State<T> {
  late PageController _pageController;
  late int _currentPage;
  late int _maxPages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPage = 0;
    _maxPages = 4; // Default max page number, can be overridden
  }

  void nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _maxPages) {
      setState(() {
        _currentPage++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void previousPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void setMaxPages(int maxPages) {
    _maxPages = maxPages;
  }

  int get currentPage => _currentPage;
  int get maxPages => _maxPages;
  PageController get pageController => _pageController;
}

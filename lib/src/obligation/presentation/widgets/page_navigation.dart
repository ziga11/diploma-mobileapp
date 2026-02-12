import 'package:flutter/material.dart';
import 'package:diplomaapp/src/constants/theme.dart';

class PageNavigator extends StatefulWidget {
  final PageController pageController;

  const PageNavigator({super.key, required this.pageController});

  @override
  State<PageNavigator> createState() => PageNavigatorState();
}

class PageNavigatorState extends State<PageNavigator> {
  late final PageController _controller;
  final int pageCount = 2;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.pageController;
  }

  void nextPage() {
    setState(() {
      if (_currentPage == pageCount - 1) {
        return;
      }

      _currentPage++;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  void previousPage() {
    setState(() {
      if (_currentPage == 0) {
        return;
      }

      _currentPage--;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _currentPage == 0
                ? ColorTheme.white.withValues(alpha: 0.2)
                : ColorTheme.white,
          ),
          onPressed: _currentPage == 0 ? null : previousPage,
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: _currentPage == pageCount - 1
                ? ColorTheme.white.withValues(alpha: 0.2)
                : ColorTheme.white,
          ),
          onPressed: _currentPage == pageCount - 1 ? null : nextPage,
        ),
        const Spacer(),
      ],
    );
  }
}

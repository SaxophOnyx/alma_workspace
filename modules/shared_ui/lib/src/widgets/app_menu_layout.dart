import 'package:flutter/material.dart';

import '../../shared_ui.dart';

/// A table-of-contents page: the section title in the upper third and its entries below it,
/// all on the left margin, entering one after another.
class AppMenuLayout extends StatelessWidget {
  static const int _flexAbove = 2;
  static const int _flexBelow = 3;

  final String title;
  final List<Widget> items;

  const AppMenuLayout({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(flex: _flexAbove),
          AppFadeIn(
            child: AppSectionTitle(text: title),
          ),
          const SizedBox(height: AppDimens.gapXl),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.gapS),
              child: AppFadeIn(
                delay: AppMotions.staggerStep * (i + 1),
                child: items[i],
              ),
            ),
          const Spacer(flex: _flexBelow),
        ],
      ),
    );
  }
}

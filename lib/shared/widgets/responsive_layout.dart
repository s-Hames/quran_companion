import 'package:flutter/material.dart';

/// Layout utility and wrapper for responsive scaling across small phones,
/// foldables, and tablets.
class ResponsiveLayout {
  static const double maxContentWidth = 680.0;
  static const double compactBreakpoint = 360.0;
  static const double tabletBreakpoint = 600.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static EdgeInsets defaultPadding(BuildContext context, {double vertical = 18.0}) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < compactBreakpoint
        ? 12.0
        : (width >= tabletBreakpoint ? 24.0 : 18.0);
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }
}

/// Centers content with a maximum width constraint on larger screens (tablets/foldables/desktop)
/// while adapting to full width on mobile screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveLayout.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: content,
    );
  }
}

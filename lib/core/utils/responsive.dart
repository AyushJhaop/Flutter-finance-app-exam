import 'package:flutter/material.dart';

/// Screen size breakpoints for FinTrack cross-platform layout.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;

  static const double maxContentWidth = 840.0;
  static const double maxAuthWidth = 480.0;
  static const double maxWideContentWidth = 1120.0;
}

/// Screen type enum
enum ScreenType { mobile, tablet, desktop }

/// Helper extension on BuildContext for quick responsive queries
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < ResponsiveBreakpoints.tabletMin;
  bool get isTablet =>
      screenWidth >= ResponsiveBreakpoints.tabletMin &&
      screenWidth <= ResponsiveBreakpoints.tabletMax;
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.desktopMin;
  bool get isWide => screenWidth >= ResponsiveBreakpoints.tabletMin;

  ScreenType get screenType {
    if (screenWidth < ResponsiveBreakpoints.tabletMin) return ScreenType.mobile;
    if (screenWidth <= ResponsiveBreakpoints.tabletMax) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

/// ResponsiveContainer — centers and constrains content width on larger screens.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding,
  });

  const ResponsiveContainer.auth({
    super.key,
    required this.child,
    this.padding,
  }) : maxWidth = ResponsiveBreakpoints.maxAuthWidth;

  const ResponsiveContainer.wide({
    super.key,
    required this.child,
    this.padding,
  }) : maxWidth = ResponsiveBreakpoints.maxWideContentWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

/// ResponsiveRowColumn — switches between Row and Column depending on screen width.
class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final double breakpoint;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRowColumn({
    super.key,
    required this.children,
    this.breakpoint = ResponsiveBreakpoints.tabletMin,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final isRow = MediaQuery.sizeOf(context).width >= breakpoint;

    if (isRow) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildSpacedChildren(true),
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildSpacedChildren(false),
      );
    }
  }

  List<Widget> _buildSpacedChildren(bool isRow) {
    if (children.isEmpty) return [];
    final spaced = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1) {
        spaced.add(
          isRow ? SizedBox(width: spacing) : SizedBox(height: spacing),
        );
      }
    }
    return spaced;
  }
}

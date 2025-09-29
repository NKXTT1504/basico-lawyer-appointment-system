import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints - Tối ưu cho Tablet/iPad
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;  // iPad thường có width ~768px, iPad Pro ~1024px
  static const double desktopBreakpoint = 1200;
  
  // Additional breakpoints cho các loại tablet khác nhau
  static const double tabletSmall = 768;   // iPad Mini
  static const double tabletMedium = 834;  // iPad thường
  static const double tabletLarge = 1024;  // iPad Pro

  // Screen size helpers
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Device type detection
  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= desktopBreakpoint;
  }
  
  // Tablet size detection
  static bool isTabletSmall(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= tabletSmall && width < tabletMedium;
  }
  
  static bool isTabletMedium(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= tabletMedium && width < tabletLarge;
  }
  
  static bool isTabletLarge(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= tabletLarge && width < desktopBreakpoint;
  }
  
  // iPad specific detection
  static bool isIPad(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= tabletSmall && width < desktopBreakpoint;
  }

  // Responsive sizing
  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double getResponsivePadding(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  // iPad optimized sizing
  static double getIPadOptimizedFontSize(BuildContext context, {
    required double mobile,
    required double tabletSmall,
    required double tabletMedium,
    required double tabletLarge,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTabletSmall(context)) return tabletSmall;
    if (isTabletMedium(context)) return tabletMedium;
    if (isTabletLarge(context)) return tabletLarge;
    return desktop;
  }
  
  static double getIPadOptimizedPadding(BuildContext context, {
    required double mobile,
    required double tabletSmall,
    required double tabletMedium,
    required double tabletLarge,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTabletSmall(context)) return tabletSmall;
    if (isTabletMedium(context)) return tabletMedium;
    if (isTabletLarge(context)) return tabletLarge;
    return desktop;
  }

  static double getResponsiveWidth(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double getResponsiveHeight(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Percentage-based sizing for better responsiveness
  static double getPercentageWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * percentage;
  }

  static double getPercentageHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * percentage;
  }

  // Responsive layout helpers
  static Widget getResponsiveLayout(BuildContext context, {
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Responsive border radius
  static double getBorderRadius(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Responsive icon size
  static double getIconSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Responsive button size
  static Size getButtonSize(BuildContext context, {
    required Size mobile,
    required Size tablet,
    required Size desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // Responsive container constraints
  static BoxConstraints getContainerConstraints(BuildContext context, {
    required BoxConstraints mobile,
    required BoxConstraints tablet,
    required BoxConstraints desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
}

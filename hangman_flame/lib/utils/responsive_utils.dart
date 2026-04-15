import 'package:flutter/material.dart';

/// Responsive breakpoints for different screen sizes
class ResponsiveBreakpoints {
  /// Mobile: < 576px
  static const double mobile = 576;
  
  /// Tablet: 576px - 992px
  static const double tablet = 992;
  
  /// Desktop: >= 992px
  static const double desktop = 992;
  
  /// Large desktop: >= 1200px
  static const double largeDesktop = 1200;
}

/// Screen size classification
enum ScreenSize { mobile, tablet, desktop, largeDesktop }

/// Responsive utilities for building adaptive UI
class ResponsiveUtils {
  /// Get screen size classification
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < ResponsiveBreakpoints.mobile) {
      return ScreenSize.mobile;
    } else if (width < ResponsiveBreakpoints.tablet) {
      return ScreenSize.tablet;
    } else if (width < ResponsiveBreakpoints.largeDesktop) {
      return ScreenSize.desktop;
    } else {
      return ScreenSize.largeDesktop;
    }
  }

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobile && width < ResponsiveBreakpoints.tablet;
  }

  /// Check if screen is desktop or larger
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet;
  }

  /// Check if screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.largeDesktop;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double mobilePadding = 12,
    double tabletPadding = 20,
    double desktopPadding = 32,
  }) {
    final screenSize = getScreenSize(context);
    final padding = switch (screenSize) {
      ScreenSize.mobile => mobilePadding,
      ScreenSize.tablet => tabletPadding,
      ScreenSize.desktop || ScreenSize.largeDesktop => desktopPadding,
    };
    return EdgeInsets.all(padding);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    double mobileSize = 14,
    double tabletSize = 16,
    double desktopSize = 18,
  }) {
    final screenSize = getScreenSize(context);
    return switch (screenSize) {
      ScreenSize.mobile => mobileSize,
      ScreenSize.tablet => tabletSize,
      ScreenSize.desktop || ScreenSize.largeDesktop => desktopSize,
    };
  }

  /// Get responsive widget width
  static double getResponsiveWidth(BuildContext context, {
    double maxWidth = 800,
  }) {
    final width = MediaQuery.of(context).size.width;
    return width > maxWidth ? maxWidth : width;
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final screenSize = getScreenSize(context);
    return switch (screenSize) {
      ScreenSize.mobile => 2,
      ScreenSize.tablet => 3,
      ScreenSize.desktop => 4,
      ScreenSize.largeDesktop => 5,
    };
  }

  /// Get responsive card aspect ratio
  static double getCardAspectRatio(BuildContext context) {
    final screenSize = getScreenSize(context);
    return switch (screenSize) {
      ScreenSize.mobile => 1.0,
      ScreenSize.tablet => 1.2,
      ScreenSize.desktop || ScreenSize.largeDesktop => 1.4,
    };
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double mobileSpacing = 8,
    double tabletSpacing = 12,
    double desktopSpacing = 16,
  }) {
    final screenSize = getScreenSize(context);
    return switch (screenSize) {
      ScreenSize.mobile => mobileSpacing,
      ScreenSize.tablet => tabletSpacing,
      ScreenSize.desktop || ScreenSize.largeDesktop => desktopSpacing,
    };
  }

  /// Get device orientation helper
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get view insets (keyboard height, etc)
  static EdgeInsets getViewInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  /// Get pixel ratio for high DPI devices
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }
}

/// Extension for easier usage
extension ResponsiveExtension on BuildContext {
  /// Get screen size
  ScreenSize get screenSize => ResponsiveUtils.getScreenSize(this);

  /// Check if mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Check if desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  /// Check if large desktop
  bool get isLargeDesktop => ResponsiveUtils.isLargeDesktop(this);

  /// Get responsive padding
  EdgeInsets getResponsivePadding({
    double mobilePadding = 12,
    double tabletPadding = 20,
    double desktopPadding = 32,
  }) {
    return ResponsiveUtils.getResponsivePadding(
      this,
      mobilePadding: mobilePadding,
      tabletPadding: tabletPadding,
      desktopPadding: desktopPadding,
    );
  }

  /// Get responsive font size
  double getResponsiveFontSize({
    double mobileSize = 14,
    double tabletSize = 16,
    double desktopSize = 18,
  }) {
    return ResponsiveUtils.getResponsiveFontSize(
      this,
      mobileSize: mobileSize,
      tabletSize: tabletSize,
      desktopSize: desktopSize,
    );
  }

  /// Get responsive width
  double getResponsiveWidth({double maxWidth = 800}) {
    return ResponsiveUtils.getResponsiveWidth(this, maxWidth: maxWidth);
  }

  /// Get grid columns
  int get gridColumns => ResponsiveUtils.getGridColumns(this);

  /// Get card aspect ratio
  double get cardAspectRatio => ResponsiveUtils.getCardAspectRatio(this);

  /// Get spacing
  double getResponsiveSpacing({
    double mobileSpacing = 8,
    double tabletSpacing = 12,
    double desktopSpacing = 16,
  }) {
    return ResponsiveUtils.getResponsiveSpacing(
      this,
      mobileSpacing: mobileSpacing,
      tabletSpacing: tabletSpacing,
      desktopSpacing: desktopSpacing,
    );
  }

  /// Get orientation
  Orientation get orientation => ResponsiveUtils.getOrientation(this);

  /// Check if portrait
  bool get isPortrait => ResponsiveUtils.isPortrait(this);

  /// Check if landscape
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
}

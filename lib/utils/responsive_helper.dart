import 'package:flutter/material.dart';

/// Responsive tasarım için yardımcı sınıf
/// Tüm iPhone ve iPad boyutları için optimize edilmiş
class ResponsiveHelper {
  final BuildContext context;

  ResponsiveHelper(this.context);

  /// Ekran genişliği
  double get width => MediaQuery.of(context).size.width;

  /// Ekran yüksekliği
  double get height => MediaQuery.of(context).size.height;

  /// En küçük kenar
  double get shortestSide => MediaQuery.of(context).size.shortestSide;

  /// En uzun kenar
  double get longestSide => MediaQuery.of(context).size.longestSide;

  /// Tablet kontrolü (iPad)
  bool get isTablet => shortestSide >= 600;

  /// Küçük telefon (iPhone SE, iPhone 8)
  bool get isSmallPhone => width < 375;

  /// Orta telefon (iPhone 11, 12, 13, 14)
  bool get isMediumPhone => width >= 375 && width < 430;

  /// Büyük telefon (iPhone 14 Pro Max, 15 Pro Max)
  bool get isLargePhone => width >= 430 && !isTablet;

  /// Responsive genişlik - ekran genişliğinin yüzdesi
  double wp(double percentage) => width * percentage / 100;

  /// Responsive yükseklik - ekran yüksekliğinin yüzdesi
  double hp(double percentage) => height * percentage / 100;

  /// Responsive font boyutu
  /// Küçük: 12-14, Orta: 16-18, Büyük: 20-24
  double fontSize({double small = 14, double medium = 16, double large = 18}) {
    if (isTablet) {
      return large * 1.2; // iPad için %20 daha büyük
    } else if (isSmallPhone) {
      return small * 0.95; // Küçük telefonlar için %5 daha küçük
    } else if (isLargePhone) {
      return medium * 1.05; // Büyük telefonlar için %5 daha büyük
    }
    return medium;
  }

  /// Responsive padding
  EdgeInsets padding({
    double all = 15,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final multiplier = isTablet ? 1.5 : (isSmallPhone ? 0.8 : 1.0);

    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: (horizontal ?? 0) * multiplier,
        vertical: (vertical ?? 0) * multiplier,
      );
    }

    if (top != null || bottom != null || left != null || right != null) {
      return EdgeInsets.only(
        top: (top ?? 0) * multiplier,
        bottom: (bottom ?? 0) * multiplier,
        left: (left ?? 0) * multiplier,
        right: (right ?? 0) * multiplier,
      );
    }

    return EdgeInsets.all(all * multiplier);
  }

  /// Responsive icon boyutu
  double iconSize({double base = 24}) {
    if (isTablet) {
      return base * 1.3;
    } else if (isSmallPhone) {
      return base * 0.9;
    }
    return base;
  }

  /// Responsive border radius
  double borderRadius({double base = 15}) {
    if (isTablet) {
      return base * 1.2;
    }
    return base;
  }

  /// Responsive spacing
  double spacing({double base = 15}) {
    if (isTablet) {
      return base * 1.5;
    } else if (isSmallPhone) {
      return base * 0.8;
    }
    return base;
  }

  /// Grid item count - ekran boyutuna göre
  int gridCrossAxisCount({int phone = 2, int tablet = 3}) {
    return isTablet ? tablet : phone;
  }

  /// Aspect ratio - ekran boyutuna göre
  double aspectRatio({double phone = 1.0, double tablet = 1.2}) {
    return isTablet ? tablet : phone;
  }

  /// Button height
  double buttonHeight({double base = 50}) {
    if (isTablet) {
      return base * 1.2;
    } else if (isSmallPhone) {
      return base * 0.9;
    }
    return base;
  }

  /// App bar height
  double appBarHeight() {
    return isTablet ? 70 : 56;
  }

  /// Bottom sheet max height
  double bottomSheetMaxHeight() {
    return height * (isTablet ? 0.7 : 0.85);
  }

  /// Dialog width
  double dialogWidth() {
    if (isTablet) {
      return width * 0.6; // iPad'de daha dar
    }
    return width * 0.85;
  }

  /// Safe area padding aware spacing
  double safeAreaTop() {
    return MediaQuery.of(context).padding.top;
  }

  double safeAreaBottom() {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Responsive widget builder
  Widget responsive({required Widget phone, Widget? tablet}) {
    return isTablet ? (tablet ?? phone) : phone;
  }

  /// Text scale factor - accessibility için
  double get textScaleFactor {
    final textScaler = MediaQuery.of(context).textScaler;
    return textScaler.scale(1.0);
  }

  /// Maksimum text scale (erişilebilirlik)
  double get safeTextScaleFactor {
    final scale = textScaleFactor;
    return scale > 1.3 ? 1.3 : scale; // Max 1.3x zoom
  }
}

/// Extension for easy access
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}

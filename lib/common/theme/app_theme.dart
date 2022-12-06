import 'package:flutter/material.dart';

enum ThemeType {
  light,
  dark,
}

class AppTheme {
  static ThemeType defaultTheme = ThemeType.light;

  //Theme Colors
  bool isDark;
  Color txt;
  Color primary;
  Color secondary;
  Color accent;
  Color transparentColor;

  //Extra Colors
  Color grey;
  Color gray;
  Color darkGray;
  Color white;
  Color whiteColor;
  Color blackColor;
  Color textColor;
  Color bg1;
  Color error;
  Color borderGray;

  /// Default constructor
  AppTheme({
    required this.isDark,
    required this.txt,
    required this.primary,
    required this.secondary,
    required this.accent,
    //Extra
    required this.grey,
    required this.gray,
    required this.darkGray,
    required this.white,
    required this.whiteColor,
    required this.blackColor,
    required this.textColor,
    required this.transparentColor,
    required this.bg1,
    required this.error,
    required this.borderGray,
  });

  /// fromType factory constructor
  factory AppTheme.fromType(ThemeType t) {
    switch (t) {
      case ThemeType.light:
        return AppTheme(
          isDark: false,
          txt: const Color(0xFF001928),
          primary: const Color(0xFF3e474d),
          secondary: const Color(0xFF6EBAE7),
          accent: const Color(0xFFefefef),
          grey: Colors.grey,
          gray: const Color(0xFFaeaeae),
          darkGray: const Color(0xFFE8E8E8),
          white: Colors.white,
          whiteColor: Colors.white,
          textColor: Colors.white,
          transparentColor: Colors.transparent,
          bg1: Colors.white,
          error: Colors.red,
          borderGray: const Color(0xFFE6E8EA),
          blackColor: Colors.black,
        );

      case ThemeType.dark:
        return AppTheme(
            isDark: true,
            txt: Colors.white,
            primary: Colors.white,
            secondary: const Color(0xFF6EBAE7),
            accent: const Color(0xFFefefef),
            grey: Colors.grey,
            gray: const Color(0xFFaeaeae),
            darkGray: const Color(0xFFE8E8E8),
            white: Colors.white,
            whiteColor: Colors.black,
            blackColor: Colors.white,
            textColor: const Color(0xFF636363),
            bg1: const Color(0xFF151A1E),
            error: Colors.red,
            borderGray: const Color(0xFF353C41),
            transparentColor: Colors.transparent);
    }
  }

  ThemeData get themeData {
    var t = ThemeData.from(
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
        secondary: secondary,
        background: bg1,
        surface: bg1,
        onBackground: txt,
        onSurface: txt,
        onError: txt,
        onPrimary: accent,
        onSecondary: accent,
        error: error,
      ),
    );
    return t.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: borderGray,
        selectionHandleColor: Colors.transparent,
        cursorColor: primary,
      ),
      buttonTheme: ButtonThemeData(buttonColor: primary),
      highlightColor: Colors.transparent,
      toggleableActiveColor: primary,
    );
  }

//Color shift(Color c, double d) => shiftHsl(c, d * (isDark ? -1 : 1));
}

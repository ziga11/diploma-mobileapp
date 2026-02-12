import 'package:flutter/material.dart';

class ColorTheme {
  static Color bgDark = HSLColor.fromAHSL(1, 247, 0.05, 0.15).toColor();
  static Color bgLight = HSLColor.fromAHSL(1, 247, 0.05, 0.2).toColor();
  static Color bgHighlight = HSLColor.fromAHSL(1, 247, 0.05, 0.3).toColor();
  static Color white = Color(0xFFDADADA);
  static Color lightGray = Color(0xFFAAAAAA);
  static Color primaryColor = HSLColor.fromAHSL(1, 247, 0.41, 0.485).toColor();
  static Color secondaryColor = HSLColor.fromAHSL(1, 200, 0.35, 0.45).toColor();
  static Color orange = HSLColor.fromAHSL(1, 15, 0.55, 0.45).toColor();
  static Color green = HSLColor.fromAHSL(1, 145, 0.35, 0.45).toColor();
  static Color red = HSLColor.fromAHSL(1, 0, 0.50, 0.45).toColor();

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: secondaryColor,
        secondaryContainer: bgHighlight,
        surface: bgDark,
        error: red,
        onPrimary: white,
        onSecondary: white,
        onSurface: white,
        onError: white,
        brightness: Brightness.dark,
        primaryContainer: bgHighlight,
        onPrimaryContainer: white,
        onSecondaryContainer: white,
        tertiary: green,
        onTertiary: white,
        tertiaryContainer: bgLight,
        onTertiaryContainer: white,
        errorContainer: HSLColor.fromAHSL(1, 0, 0.50, 0.25).toColor(),
        onErrorContainer: white,
        outline: lightGray,
        outlineVariant: HSLColor.fromAHSL(1, 247, 0.15, 0.25).toColor(),
        shadow: Colors.black,
        scrim: Colors.black54,
        inverseSurface: white,
        onInverseSurface: bgDark,
        inversePrimary: HSLColor.fromAHSL(1, 247, 0.41, 0.65).toColor(),
        surfaceTint: primaryColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
            color: white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat"),
        bodyMedium: TextStyle(
            color: white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat"),
        bodySmall: TextStyle(
            color: white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: "Montserrat"),
        titleLarge: TextStyle(
            color: white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat"),
        titleMedium: TextStyle(
            color: white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat"),
        titleSmall: TextStyle(
            color: white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat"),
        headlineLarge: TextStyle(
            color: white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat"),
        headlineMedium: TextStyle(
            color: white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat"),
        headlineSmall: TextStyle(
            color: white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat"),
        displayLarge: TextStyle(
            color: white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat"),
        displayMedium: TextStyle(
            color: white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat"),
        displaySmall: TextStyle(
            color: white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: "Montserrat"),
        labelLarge: TextStyle(
            color: white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat"),
        labelMedium: TextStyle(
            color: white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat"),
        labelSmall: TextStyle(
            color: white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat"),
      ),
      scaffoldBackgroundColor: bgDark,
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: "Montserrat",
        ),
        iconTheme: IconThemeData(color: white),
        actionsIconTheme: IconThemeData(color: white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          elevation: 5,
          padding: EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: ColorTheme.primaryColor,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: "Montserrat",
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Montserrat",
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightGray, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: red, width: 2),
        ),
        labelStyle: TextStyle(color: lightGray, fontFamily: "Montserrat"),
        hintStyle: TextStyle(color: lightGray, fontFamily: "Montserrat"),
        floatingLabelStyle:
            TextStyle(color: lightGray, fontFamily: "Montserrat"),
        iconColor: lightGray,
        errorStyle: const TextStyle(fontWeight: FontWeight.w900),
        prefixIconColor: lightGray,
        suffixIconColor: lightGray,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: lightGray.withValues(alpha: 0.3),
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: white,
        size: 24,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: bgLight,
        textColor: white,
        iconColor: white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: bgHighlight,
        circularTrackColor: bgHighlight,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: bgHighlight,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.2),
        valueIndicatorColor: primaryColor,
        valueIndicatorTextStyle: TextStyle(
          color: white,
          fontFamily: "Montserrat",
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgLight,
        deleteIconColor: white,
        disabledColor: bgHighlight,
        selectedColor: primaryColor,
        secondarySelectedColor: secondaryColor,
        labelPadding: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: TextStyle(
          color: white,
          fontFamily: "Montserrat",
        ),
        secondaryLabelStyle: TextStyle(
          color: white,
          fontFamily: "Montserrat",
        ),
        brightness: Brightness.dark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgLight,
        contentTextStyle: TextStyle(
          color: white,
          fontFamily: "Montserrat",
        ),
        actionTextColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      cardColor: bgLight,
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: bgHighlight,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: TextStyle(
          color: white,
          fontSize: 12,
          fontFamily: "Montserrat",
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bgLight,
        modalBackgroundColor: bgLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bgLight,
        indicatorColor: primaryColor.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontFamily: "Montserrat",
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: bgLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: white,
          fontFamily: "Montserrat",
        ),
      ),
    );
  }
}

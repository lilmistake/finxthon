import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  Brightness brightness = Brightness.light;
  changeTheme() {
    if (brightness == Brightness.light) {
      brightness = Brightness.dark;
    } else {
      brightness = Brightness.light;
    }
    notifyListeners();
  }
}

ThemeData theme(ThemeProvider themeProvider) {
  return ThemeData(
      fontFamily: GoogleFonts.poppins().fontFamily,
      useMaterial3: true,
      textTheme: const TextTheme(
        displayMedium: TextStyle(fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontWeight: FontWeight.bold),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.pink,
        brightness: themeProvider.brightness,
      ));
}

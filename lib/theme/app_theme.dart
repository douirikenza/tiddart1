import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryBrown = Color(0xFF8B4513);      // Brun traditionnel plus riche
  static const Color secondaryBrown = Color(0xFF5C3317);    // Brun foncé pour les accents
  static const Color backgroundLight = Color(0xFFF5EDE4);   // Beige clair modernisé
  static const Color accentGold = Color(0xFFD4AF37);        // Or traditionnel
  static const Color textDark = Color(0xFF2C1810);         // Brun très foncé pour le texte
  static const Color surfaceLight = Color(0xFFECE0D1);     // Beige pour les surfaces

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBrown, secondaryBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Styles de texte
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textDark,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textDark,
    ),
    bodyLarge: GoogleFonts.lato(
      fontSize: 16,
      color: textDark,
    ),
    bodyMedium: GoogleFonts.lato(
      fontSize: 14,
      color: textDark,
    ),
  );

  // Styles de boutons
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryBrown,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 2,
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryBrown,
    side: const BorderSide(color: primaryBrown, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );

  // Styles de cartes
  static final CardTheme cardTheme = CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    color: surfaceLight,
  );

  // Styles d'input
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: surfaceLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: primaryBrown, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: accentGold, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );

  // Styles d'ombre
  static List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.brown.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
} 
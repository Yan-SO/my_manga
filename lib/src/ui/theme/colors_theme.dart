import 'package:flutter/material.dart';

class MyColorsTheme {
  static ColorScheme myColors() {
    // Definindo as cores personalizadas
    const brightness = Brightness.dark; // Modo de brilho escuro
    const primary = Color(0xFF4CAF50); // Cor do texto sobre a cor primária
    const onPrimary = Color(0xFF333333); // Cor primária
    const secondary = Color(0xFF6D6D6D); // Cor secundária
    const onSecondary = Colors.white; // Cor do texto sobre a cor secundária
    const tertiary = Color(0xFF1E1E1E);
    const onTertiary = Color.fromARGB(255, 221, 221, 221);
    const error = Colors.red; // Cor de erro
    const onError = Colors.white; // Cor do texto sobre a cor de erro
    const surface = Color.fromARGB(255, 59, 59, 59); // Cor da superfície
    const onSurface = Colors.white; // Cor do texto sobre a cor da superfície

    return const ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      tertiary: tertiary,
      onTertiary: onTertiary,
      error: error,
      onError: onError,
      surface: surface,
      onSurface: onSurface,
    );
  }
}

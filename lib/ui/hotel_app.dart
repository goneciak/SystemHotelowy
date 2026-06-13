import 'package:flutter/material.dart';

import 'screens/hotel_dashboard_screen.dart';

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coffee = Color(0xFF5B4033);
    const porcelain = Color(0xFFF8F4EE);
    const sage = Color(0xFF6F8F83);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: coffee,
      brightness: Brightness.light,
      primary: coffee,
      secondary: sage,
      surface: porcelain,
    );

    return MaterialApp(
      title: 'Hotel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: porcelain,
        appBarTheme: const AppBarTheme(
          backgroundColor: porcelain,
          foregroundColor: coffee,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: coffee.withValues(alpha: 0.10)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: coffee,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: coffee,
            side: BorderSide(color: coffee.withValues(alpha: 0.35)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: coffee.withValues(alpha: 0.14)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: coffee.withValues(alpha: 0.14)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: sage, width: 1.4),
          ),
        ),
      ),
      home: const HotelDashboardScreen(),
    );
  }
}

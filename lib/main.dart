import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Keep these imports - must match your project layout
import 'package:my_app/firebase_options.dart';
import 'package:my_app/providers/cart_provider.dart';
import 'package:my_app/screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Soft pink color scheme (light & warm)
  static const Color _pinkPrimary = Color(0xFFF48FB1);
  static const Color _pinkPrimaryVariant = Color(0xFFD77AA3);
  static const Color _accent = Color(0xFFFFC1E3);
  static const Color _deep = Color(0xFF6A1B9A);

  ThemeData _buildTheme() {
    final base = ThemeData.light();

    // ✅ Replaced deprecated 'background' with 'surface'
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _deep,
      primary: _pinkPrimary,
      secondary: _deep,
      surface: const Color(0xFFFDF6F9),
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.quicksandTextTheme(base.textTheme).apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      useMaterial3: true,
      textTheme: textTheme,
      primaryColor: colorScheme.primary,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: _deep,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _deep,
        ),
        iconTheme: const IconThemeData(color: _deep),
      ),
      // ✅ Removed cardTheme completely (safe)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _pinkPrimary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w700),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _deep,
          textStyle: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          // ✅ replaced withOpacity() → withValues() to avoid precision loss
          borderSide: BorderSide(color: _pinkPrimaryVariant.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _pinkPrimaryVariant),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _deep,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
      ),
      pageTransitionsTheme: PageTransitionsTheme(builders: {
        for (final platform in TargetPlatform.values)
          platform: const FadeUpwardsPageTransitionsBuilder(),
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _buildTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Commerce App',
      theme: theme,
      home: const AuthWrapper(),
    );
  }
}

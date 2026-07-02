import 'package:flutter/material.dart';

import 'data/sample_messages.dart';
import 'screens/welcome_screen.dart';
import 'services/session_tracker.dart';

void main() {
  runApp(
    PhishAlertApp(sessionTracker: SessionTracker(messages: sampleMessages)),
  );
}

/// Root of the interim Phish Alert prototype.
///
/// A single [SessionTracker] is created up front and threaded through the
/// screens. Theming is kept light on purpose for this stage: a seeded Material 3
/// colour scheme with a few button tweaks, rather than the fully art-directed
/// look planned for the finished app.
class PhishAlertApp extends StatelessWidget {
  const PhishAlertApp({super.key, required this.sessionTracker});

  final SessionTracker sessionTracker;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B5B6C),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Phish Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: const AppBarTheme(centerTitle: false),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: WelcomeScreen(tracker: sessionTracker),
    );
  }
}

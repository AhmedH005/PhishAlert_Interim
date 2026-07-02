import 'package:flutter/material.dart';

import '../services/session_tracker.dart';
import 'level_selection_screen.dart';

/// Landing screen. Introduces the app and lets the learner pick a practice
/// mode. Only "Learning Levels" is wired up in this interim build; the other
/// two modes are shown but marked "Planned".
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.tracker});

  final SessionTracker tracker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Icon(Icons.shield_outlined, size: 40, color: colors.primary),
              const SizedBox(height: 16),
              Text(
                'Phish Alert',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Practise spotting phishing emails and texts. Classify each '
                'message, rate your confidence, and get instant feedback.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              const _HowItWorks(),
              const SizedBox(height: 28),
              Text(
                'Practice modes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _ModeCard(
                key: const Key('mode-levels'),
                icon: Icons.layers_outlined,
                title: 'Learning Levels',
                subtitle:
                    '${tracker.levelCount} levels • '
                    '${tracker.messagePoolCount} messages, in order',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LevelSelectionScreen(tracker: tracker),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const _ModeCard(
                icon: Icons.shuffle_rounded,
                title: 'Random Practice',
                subtitle: 'Shuffle a mixed set of messages',
                planned: true,
              ),
              const SizedBox(height: 12),
              const _ModeCard(
                icon: Icons.history_rounded,
                title: 'Review Mistakes',
                subtitle: 'Replay questions you missed',
                planned: true,
              ),
              const SizedBox(height: 24),
              Text(
                'Interim prototype • on-device only, no login or cloud sync.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = [
    'Read a realistic email or SMS',
    'Decide: Phish or Legit',
    'Rate how confident you are (1–5)',
    'See instant feedback and a session summary',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How it works',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == _steps.length - 1 ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colors.primary,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(_steps[i], style: theme.textTheme.bodyMedium),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A selectable practice-mode row. When [planned] is true it is greyed out,
/// shows a "Planned" badge, and cannot be tapped.
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.planned = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool planned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final enabled = !planned && onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (planned) ...[
                            const SizedBox(width: 8),
                            const _PlannedBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  enabled
                      ? Icons.chevron_right_rounded
                      : Icons.lock_outline_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannedBadge extends StatelessWidget {
  const _PlannedBadge();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Planned',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: colors.onTertiaryContainer,
        ),
      ),
    );
  }
}

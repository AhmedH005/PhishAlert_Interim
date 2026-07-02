import 'package:flutter/material.dart';

import '../services/session_tracker.dart';
import 'quiz_screen.dart';
import 'welcome_screen.dart';

/// End-of-session summary. Shows accuracy and average confidence, plus the raw
/// over/under-confidence counts. The full confidence-analytics view (charts and
/// personalised tips) is intentionally left for a later sprint and flagged
/// in-app as "in development".
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.tracker});

  final SessionTracker tracker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accuracyPercent = (tracker.accuracy * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score hero.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tracker.currentSessionTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tracker.score} / ${tracker.totalQuestions} correct',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$accuracyPercent% accuracy',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Key stats.
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Average confidence',
                      value: tracker.averageConfidence.toStringAsFixed(1),
                      suffix: '/ 5',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Questions',
                      value: '${tracker.totalQuestions}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Overconfident',
                      value: '${tracker.overconfidenceCount}',
                      caption: 'wrong, but sure (4–5)',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Underconfident',
                      value: '${tracker.underconfidenceCount}',
                      caption: 'right, but unsure (1–2)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Honest "not built yet" marker for the analytics view.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.construction_rounded, color: colors.tertiary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confidence analytics — in development',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'A later sprint will turn these raw counts into an '
                            'over/under-confidence breakdown with personalised '
                            'tips.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: () {
                  tracker.restartCurrentSession();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => QuizScreen(tracker: tracker),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Repeat this level'),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    tracker.reset();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => WelcomeScreen(tracker: tracker),
                      ),
                    );
                  },
                  child: const Text('Back to start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.suffix,
    this.caption,
  });

  final String label;
  final String value;
  final String? suffix;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  suffix!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(
              caption!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

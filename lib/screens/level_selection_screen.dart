import 'package:flutter/material.dart';

import '../models/message_item.dart';
import '../services/session_tracker.dart';
import 'quiz_screen.dart';

/// Lists the available levels grouped by difficulty tier. Choosing a level
/// starts an in-order session (the only mode wired up in this build).
class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key, required this.tracker});

  final SessionTracker tracker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a level')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Work through the levels in order. Each level groups a few '
              'messages of similar difficulty.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ..._buildSections(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context) {
    final sections = <Widget>[];
    for (final difficulty in MessageDifficulty.values) {
      final levels = tracker.levelsForDifficulty(difficulty);
      if (levels.isEmpty) {
        continue;
      }
      sections.add(
        _DifficultyHeader(difficulty: difficulty, levelCount: levels.length),
      );
      sections.add(const SizedBox(height: 10));
      for (final level in levels) {
        sections.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LevelTile(
              key: Key('level-$level'),
              levelNumber: level,
              questionCount: tracker.messageCountForLevel(level),
              onTap: () => _startLevel(context, level),
            ),
          ),
        );
      }
      sections.add(const SizedBox(height: 16));
    }
    return sections;
  }

  void _startLevel(BuildContext context, int level) {
    tracker.startLevel(level);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => QuizScreen(tracker: tracker)),
    );
  }
}

class _DifficultyHeader extends StatelessWidget {
  const _DifficultyHeader({required this.difficulty, required this.levelCount});

  final MessageDifficulty difficulty;
  final int levelCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          difficulty.label,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$levelCount ${levelCount == 1 ? 'level' : 'levels'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    super.key,
    required this.levelNumber,
    required this.questionCount,
    required this.onTap,
  });

  final int levelNumber;
  final int questionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$levelNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Level $levelNumber',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$questionCount ${questionCount == 1 ? 'question' : 'questions'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/message_item.dart';
import '../services/session_tracker.dart';
import 'feedback_screen.dart';

/// The main question screen: show a message, let the learner classify it and
/// rate their confidence, then submit. A one-time hint is available per
/// question.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.tracker});

  final SessionTracker tracker;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  MessageClassification? _selected;
  int _confidence = 3;
  bool _hintUsed = false;

  @override
  Widget build(BuildContext context) {
    final tracker = widget.tracker;
    final message = tracker.currentMessage;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = tracker.currentQuestionNumber / tracker.totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: Text(tracker.currentSessionTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress, minHeight: 4),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Question ${tracker.currentQuestionNumber} of '
                    '${tracker.totalQuestions}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Score ${tracker.score}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _MessageCard(message: message),
              const SizedBox(height: 16),
              _HintSection(
                hint: message.hint,
                hintUsed: _hintUsed,
                onUseHint: () => setState(() => _hintUsed = true),
              ),
              const SizedBox(height: 24),
              Text(
                'Is this message Phish or Legit?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _VerdictButton(
                      key: const Key('decision-phish'),
                      label: 'Phish',
                      icon: Icons.report_gmailerrorred_outlined,
                      color: colors.error,
                      selected: _selected == MessageClassification.phish,
                      onTap: () => setState(
                        () => _selected = MessageClassification.phish,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VerdictButton(
                      key: const Key('decision-legit'),
                      label: 'Legit',
                      icon: Icons.verified_outlined,
                      color: const Color(0xFF0B6E4F),
                      selected: _selected == MessageClassification.legit,
                      onTap: () => setState(
                        () => _selected = MessageClassification.legit,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'How confident are you?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '1 = just guessing, 5 = certain',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (var level = 1; level <= 5; level++)
                    ChoiceChip(
                      key: Key('confidence-$level'),
                      label: Text('$level'),
                      selected: _confidence == level,
                      onSelected: (_) => setState(() => _confidence = level),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton(
                key: const Key('submit-answer'),
                onPressed: _selected == null ? null : _submit,
                child: const Text('Submit answer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    final selected = _selected;
    if (selected == null) {
      return;
    }
    final record = widget.tracker.submitAnswer(
      classification: selected,
      confidence: _confidence,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FeedbackScreen(tracker: widget.tracker, record: record),
      ),
    );
  }
}

/// Renders the message under test: channel/level/difficulty tags, the sender,
/// the subject (emails only) and the body.
class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final MessageItem message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(text: message.levelLabel),
              _Tag(text: message.difficulty.label),
              _Tag(text: message.channel.label),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                message.isEmail ? Icons.mail_outline : Icons.sms_outlined,
                color: colors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message.sender,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (message.subject != null) ...[
            const SizedBox(height: 16),
            Text(
              message.subject!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            message.content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// One-time hint control. Once revealed, the button is disabled and the hint
/// text stays on screen.
class _HintSection extends StatelessWidget {
  const _HintSection({
    required this.hint,
    required this.hintUsed,
    required this.onUseHint,
  });

  final String hint;
  final bool hintUsed;
  final VoidCallback onUseHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: hintUsed ? null : onUseHint,
          icon: const Icon(Icons.lightbulb_outline_rounded),
          label: Text(hintUsed ? 'Hint used' : 'Use hint'),
        ),
        if (hintUsed) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hint,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ],
    );
  }
}

/// A large, selectable Phish/Legit choice tile.
class _VerdictButton extends StatelessWidget {
  const _VerdictButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected ? color.withValues(alpha: 0.12) : colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : colors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

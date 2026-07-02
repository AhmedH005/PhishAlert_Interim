import 'package:flutter/material.dart';

import '../models/message_item.dart';
import '../services/session_tracker.dart';
import 'quiz_screen.dart';
import 'summary_screen.dart';

/// Immediate feedback for a single answer: correct/incorrect banner, the chosen
/// vs correct label, a short explanation, the cues (highlighted in place within
/// the message text for phishing examples), and a takeaway tip.
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({
    super.key,
    required this.tracker,
    required this.record,
  });

  final SessionTracker tracker;
  final AnswerRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final message = record.message;
    final isCorrect = record.isCorrect;
    final isPhish = message.classification == MessageClassification.phish;

    final good = const Color(0xFF0B6E4F);
    final accent = isCorrect ? good : colors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Result banner.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: accent,
                            size: 30,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect ? 'Correct' : 'Not quite',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'You answered '
                                  '${record.selectedClassification.label} · '
                                  'confidence ${record.confidence}/5',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Row(
                      label: 'Correct answer',
                      value: message.classification.label,
                    ),
                    const Divider(height: 24),

                    // Explanation.
                    Text(
                      'Why?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message.explanation,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),

                    // The message re-shown, with suspicious cues highlighted in
                    // place (phishing messages only).
                    Text(
                      isPhish
                          ? 'Suspicious cues in the message'
                          : 'Signals this message is legitimate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
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
                            message.sender,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (message.subject != null) ...[
                            const SizedBox(height: 10),
                            _HighlightedText(
                              text: message.subject!,
                              cues: message.cues,
                              highlight: isPhish,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              highlightColor: colors.error,
                            ),
                          ],
                          const SizedBox(height: 10),
                          _HighlightedText(
                            text: message.content,
                            cues: message.cues,
                            highlight: isPhish,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                            highlightColor: colors.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final cue in message.cues)
                          Chip(
                            label: Text(cue),
                            visualDensity: VisualDensity.compact,
                            side: BorderSide(color: colors.outlineVariant),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Takeaway tip.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 18,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Takeaway',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            message.takeawayTip,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: FilledButton(
                key: const Key('feedback-continue'),
                onPressed: () => _continue(context),
                child: Text(
                  tracker.hasNextQuestion ? 'Next message' : 'View summary',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continue(BuildContext context) {
    if (tracker.hasNextQuestion) {
      tracker.advance();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => QuizScreen(tracker: tracker)),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => SummaryScreen(tracker: tracker)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Renders [text], highlighting any case-insensitive occurrences of [cues] when
/// [highlight] is true. Cues that do not literally appear in the text (such as
/// descriptive cues like "brand impersonation") simply render as normal text.
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.cues,
    required this.highlight,
    required this.style,
    required this.highlightColor,
  });

  final String text;
  final List<String> cues;
  final bool highlight;
  final TextStyle? style;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ?? Theme.of(context).textTheme.bodyLarge ?? const TextStyle();

    if (!highlight) {
      return Text(text, style: baseStyle);
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: _buildSpans(baseStyle)),
    );
  }

  List<InlineSpan> _buildSpans(TextStyle baseStyle) {
    final needles =
        cues
            .map((cue) => cue.trim().toLowerCase())
            .where((cue) => cue.isNotEmpty)
            .toSet()
            .toList()
          // Prefer longer matches first so overlapping cues highlight cleanly.
          ..sort((a, b) => b.length.compareTo(a.length));

    if (needles.isEmpty) {
      return [TextSpan(text: text)];
    }

    final lower = text.toLowerCase();
    final spans = <InlineSpan>[];
    var index = 0;

    while (index < text.length) {
      int? matchStart;
      var matchLength = 0;

      for (final needle in needles) {
        final found = lower.indexOf(needle, index);
        if (found == -1) {
          continue;
        }
        if (matchStart == null ||
            found < matchStart ||
            (found == matchStart && needle.length > matchLength)) {
          matchStart = found;
          matchLength = needle.length;
        }
      }

      if (matchStart == null) {
        spans.add(TextSpan(text: text.substring(index)));
        break;
      }

      if (matchStart > index) {
        spans.add(TextSpan(text: text.substring(index, matchStart)));
      }

      final end = matchStart + matchLength;
      spans.add(
        TextSpan(
          text: text.substring(matchStart, end),
          style: baseStyle.copyWith(
            color: highlightColor,
            fontWeight: FontWeight.bold,
            backgroundColor: highlightColor.withValues(alpha: 0.12),
          ),
        ),
      );
      index = end;
    }

    return spans;
  }
}

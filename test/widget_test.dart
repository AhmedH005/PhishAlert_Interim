import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phish_alert/data/sample_messages.dart';
import 'package:phish_alert/main.dart';
import 'package:phish_alert/models/message_item.dart';
import 'package:phish_alert/services/session_tracker.dart';

/// A tiny two-question level used by the unit tests so they do not depend on
/// the exact contents of the bundled dataset.
const _testMessages = [
  MessageItem(
    id: 'T1',
    levelNumber: 1,
    difficulty: MessageDifficulty.easy,
    channel: MessageChannel.email,
    sender: 'test-phish@example.com',
    subject: 'Urgent action needed',
    content: 'verify your account now',
    classification: MessageClassification.phish,
    hint: 'Watch the wording.',
    explanation: 'Urgent wording is suspicious.',
    cues: ['verify your account now'],
    takeawayTip: 'Urgency is a common tactic.',
  ),
  MessageItem(
    id: 'T2',
    levelNumber: 1,
    difficulty: MessageDifficulty.easy,
    channel: MessageChannel.sms,
    sender: 'Campus',
    content: 'Lecture is at 2pm.',
    classification: MessageClassification.legit,
    hint: 'Look for normal context.',
    explanation: 'Routine update.',
    cues: ['routine update'],
    takeawayTip: 'Routine updates are usually low risk.',
  ),
];

void main() {
  group('SessionTracker (core answer logic)', () {
    test('starts a level with its questions in order', () {
      final tracker = SessionTracker(messages: _testMessages);
      tracker.startLevel(1);

      expect(tracker.currentSessionTitle, 'Level 1');
      expect(tracker.totalQuestions, 2);
      expect(tracker.currentMessage.id, 'T1');
    });

    test('scores a correct answer and advances', () {
      final tracker = SessionTracker(messages: _testMessages);
      tracker.startLevel(1);

      final record = tracker.submitAnswer(
        classification: MessageClassification.phish, // T1 is phishing.
        confidence: 4,
      );

      expect(record.isCorrect, isTrue);
      expect(tracker.score, 1);
      expect(tracker.hasNextQuestion, isTrue);

      tracker.advance();
      expect(tracker.currentMessage.id, 'T2');
    });

    test('flags overconfidence and underconfidence with the repo rule', () {
      final tracker = SessionTracker(messages: _testMessages);
      tracker.startLevel(1);

      // T1 is phishing; answering "legit" with high confidence is overconfident.
      tracker.submitAnswer(
        classification: MessageClassification.legit,
        confidence: 5,
      );
      tracker.advance();

      // T2 is legit; answering correctly with low confidence is underconfident.
      tracker.submitAnswer(
        classification: MessageClassification.legit,
        confidence: 1,
      );

      expect(tracker.overconfidenceCount, 1); // wrong AND confidence >= 4
      expect(tracker.underconfidenceCount, 1); // correct AND confidence <= 2
      expect(tracker.score, 1);
      expect(tracker.accuracy, 0.5);
      expect(tracker.averageConfidence, 3.0); // (5 + 1) / 2
    });

    test('planned modes are honestly unimplemented', () {
      final tracker = SessionTracker(messages: _testMessages);
      expect(tracker.startRandomPractice, throwsUnimplementedError);
      expect(tracker.startReviewMistakes, throwsUnimplementedError);
    });
  });

  group('Bundled dataset', () {
    test('holds the exact interim set of 12 messages across 7 levels', () {
      expect(sampleMessages.length, 12);
      expect(sampleMessages.map((m) => m.levelNumber).toSet().length, 7);

      // Only the easy and medium tiers are populated in this build.
      final tiers = sampleMessages.map((m) => m.difficulty).toSet();
      expect(tiers, {MessageDifficulty.easy, MessageDifficulty.medium});

      // Every phishing message carries at least one cue to highlight.
      for (final phish in sampleMessages.where(
        (m) => m.classification == MessageClassification.phish,
      )) {
        expect(phish.cues, isNotEmpty);
      }
    });
  });

  group('Widget flow', () {
    testWidgets('welcome screen shows the app and its planned modes', (
      tester,
    ) async {
      await tester.pumpWidget(
        PhishAlertApp(sessionTracker: SessionTracker(messages: sampleMessages)),
      );

      expect(find.text('Phish Alert'), findsOneWidget);
      expect(find.text('Learning Levels'), findsOneWidget);
      expect(find.text('Random Practice'), findsOneWidget);
      expect(find.text('Review Mistakes'), findsOneWidget);
      // Two modes are still to come.
      expect(find.text('Planned'), findsNWidgets(2));
    });

    testWidgets('core loop: classify a message and land on feedback', (
      tester,
    ) async {
      // Use a tall phone-sized surface so each screen fits without scrolling.
      tester.view.physicalSize = const Size(1200, 4200);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        PhishAlertApp(sessionTracker: SessionTracker(messages: sampleMessages)),
      );
      await tester.pumpAndSettle();

      // Welcome → level selection.
      await tester.tap(find.byKey(const Key('mode-levels')));
      await tester.pumpAndSettle();

      // Level selection → quiz (Level 1).
      await tester.tap(find.byKey(const Key('level-1')));
      await tester.pumpAndSettle();

      // Level 1, question 1 (L1Q1) is a phishing email — classify it as Phish.
      await tester.tap(find.byKey(const Key('decision-phish')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('confidence-5')));
      await tester.pump();

      final submit = find.byKey(const Key('submit-answer'));
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      // Feedback for a correct answer, showing the takeaway tip.
      expect(find.text('Correct'), findsOneWidget);
      expect(
        find.textContaining('Urgency is one of the most common'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('feedback-continue')), findsOneWidget);
    });
  });
}

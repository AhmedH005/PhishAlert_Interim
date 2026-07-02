import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/message_item.dart';

/// The practice modes the finished app offers. Only [PracticeMode.byLevel] is
/// implemented in this interim build; the other two are planned for a later
/// sprint (see [startRandomPractice] / [startReviewMistakes]).
enum PracticeMode { byLevel, randomPractice, reviewMistakes }

/// A single answered question: what the learner picked, how confident they
/// were, and whether it was correct.
class AnswerRecord {
  const AnswerRecord({
    required this.message,
    required this.selectedClassification,
    required this.confidence,
    required this.isCorrect,
  });

  final MessageItem message;
  final MessageClassification selectedClassification;
  final int confidence;
  final bool isCorrect;
}

/// In-memory session state for one run through a set of messages.
///
/// This is a scoped-down version of the finished app's tracker. It fully drives
/// the core loop — start a level, answer, score, advance, summarise — and
/// exposes the confidence metrics the summary needs. Random practice and
/// mistake review are stubbed out for a future sprint.
///
/// It extends [ChangeNotifier] so screens can later observe it reactively; for
/// now the flow is navigation-driven and each screen reads the tracker directly.
class SessionTracker extends ChangeNotifier {
  SessionTracker({required List<MessageItem> messages})
    : assert(messages.isNotEmpty, 'At least one message is required.'),
      _messages = List.unmodifiable(messages);

  final List<MessageItem> _messages;
  final List<AnswerRecord> _responses = [];

  List<MessageItem> _activeMessages = [];
  PracticeMode? _practiceMode;
  int? _selectedLevelNumber;
  String _currentSessionTitle = 'Phish Alert';
  String _currentSessionSubtitle = 'Choose a level to begin.';

  int _currentIndex = 0;
  int _score = 0;
  bool _started = false;

  // --- Session state -------------------------------------------------------

  bool get hasStarted => _started;
  bool get hasActiveSession => _practiceMode != null;
  int get messagePoolCount => _messages.length;
  int get levelCount => levels.length;
  int get totalQuestions => _activeMessages.length;
  int get currentQuestionNumber => totalQuestions == 0 ? 0 : _currentIndex + 1;
  int get score => _score;
  bool get hasNextQuestion => _currentIndex < _activeMessages.length - 1;
  bool get isComplete =>
      totalQuestions > 0 && _responses.length == _activeMessages.length;
  PracticeMode? get practiceMode => _practiceMode;
  int? get selectedLevelNumber => _selectedLevelNumber;
  String get currentSessionTitle => _currentSessionTitle;
  String get currentSessionSubtitle => _currentSessionSubtitle;

  MessageItem get currentMessage {
    if (_activeMessages.isEmpty) {
      throw StateError('There is no active session.');
    }
    return _activeMessages[_currentIndex];
  }

  UnmodifiableListView<AnswerRecord> get responses =>
      UnmodifiableListView(_responses);

  List<AnswerRecord> get mistakes =>
      _responses.where((response) => !response.isCorrect).toList();

  // --- Metrics used by the summary ----------------------------------------

  double get accuracy {
    if (_responses.isEmpty || totalQuestions == 0) {
      return 0;
    }
    return _score / totalQuestions;
  }

  double get averageConfidence => _averageConfidenceFor(_responses);

  /// Wrong answers submitted with high confidence (4-5). The full over/under-
  /// confidence analytics view is planned; the summary shows this raw count.
  int get overconfidenceCount => _responses
      .where((response) => !response.isCorrect && response.confidence >= 4)
      .length;

  /// Correct answers submitted with low confidence (1-2).
  int get underconfidenceCount => _responses
      .where((response) => response.isCorrect && response.confidence <= 2)
      .length;

  // --- Level helpers -------------------------------------------------------

  /// Sorted, de-duplicated list of level numbers present in the dataset.
  List<int> get levels =>
      _messages.map((message) => message.levelNumber).toSet().toList()..sort();

  List<MessageItem> messagesForLevel(int levelNumber) =>
      _messages.where((message) => message.levelNumber == levelNumber).toList();

  int messageCountForLevel(int levelNumber) =>
      messagesForLevel(levelNumber).length;

  /// Sorted level numbers that belong to a given difficulty tier.
  List<int> levelsForDifficulty(MessageDifficulty difficulty) =>
      _messages
          .where((message) => message.difficulty == difficulty)
          .map((message) => message.levelNumber)
          .toSet()
          .toList()
        ..sort();

  // --- Practice modes ------------------------------------------------------

  /// Starts a level, presenting its questions in their fixed order.
  void startLevel(int levelNumber) {
    final levelMessages = messagesForLevel(levelNumber);
    if (levelMessages.isEmpty) {
      throw StateError('No questions found for level $levelNumber.');
    }

    _practiceMode = PracticeMode.byLevel;
    _selectedLevelNumber = levelNumber;
    final count = levelMessages.length;
    _startSession(
      messages: levelMessages,
      title: 'Level $levelNumber',
      subtitle:
          '${levelMessages.first.difficulty.label} • $count '
          '${count == 1 ? 'question' : 'questions'} in order',
    );
  }

  // TODO(next sprint): Random Practice mode — shuffle a chosen difficulty pool
  // with no repetition. Surfaced as "Planned" on the welcome screen and not yet
  // wired to any button.
  void startRandomPractice() {
    throw UnimplementedError('Random Practice is planned for a future sprint.');
  }

  // TODO(next sprint): Review Mistakes mode — replay questions answered
  // incorrectly in earlier sessions. Needs persisted history, which this
  // in-memory build does not keep yet.
  void startReviewMistakes() {
    throw UnimplementedError('Review Mistakes is planned for a future sprint.');
  }

  /// Replays the current level from the start (used by the summary screen).
  void restartCurrentSession() {
    final levelNumber = _selectedLevelNumber;
    if (_practiceMode == PracticeMode.byLevel && levelNumber != null) {
      startLevel(levelNumber);
    }
  }

  // --- Core answer loop ----------------------------------------------------

  /// Records an answer for the current question and updates the score.
  ///
  /// This is the heart of the app and the piece exercised by the widget test.
  AnswerRecord submitAnswer({
    required MessageClassification classification,
    required int confidence,
  }) {
    if (!_started || _activeMessages.isEmpty) {
      throw StateError('Start a session before answering.');
    }
    if (isComplete) {
      throw StateError('The session is already complete.');
    }
    if (_responses.length != _currentIndex) {
      throw StateError('The current question has already been answered.');
    }

    final message = currentMessage;
    final isCorrect = message.classification == classification;

    final record = AnswerRecord(
      message: message,
      selectedClassification: classification,
      confidence: confidence,
      isCorrect: isCorrect,
    );

    _responses.add(record);
    if (isCorrect) {
      _score += 1;
    }

    notifyListeners();
    return record;
  }

  /// Moves to the next question when there is one.
  void advance() {
    if (_responses.length <= _currentIndex) {
      throw StateError('Answer the current question before advancing.');
    }
    if (hasNextQuestion) {
      _currentIndex += 1;
      notifyListeners();
    }
  }

  /// Clears all session state and returns to the welcome state.
  void reset() {
    _started = false;
    _practiceMode = null;
    _selectedLevelNumber = null;
    _currentIndex = 0;
    _score = 0;
    _responses.clear();
    _activeMessages = [];
    _currentSessionTitle = 'Phish Alert';
    _currentSessionSubtitle = 'Choose a level to begin.';
    notifyListeners();
  }

  // --- Internals -----------------------------------------------------------

  void _startSession({
    required List<MessageItem> messages,
    required String title,
    required String subtitle,
  }) {
    _started = true;
    _currentIndex = 0;
    _score = 0;
    _responses.clear();
    _activeMessages = List<MessageItem>.from(messages);
    _currentSessionTitle = title;
    _currentSessionSubtitle = subtitle;
    notifyListeners();
  }

  double _averageConfidenceFor(Iterable<AnswerRecord> entries) {
    if (entries.isEmpty) {
      return 0;
    }
    final total = entries.fold<int>(
      0,
      (sum, response) => sum + response.confidence,
    );
    return total / entries.length;
  }
}

// Domain model for a single training message shown to the learner.
//
// This mirrors the structure of the finished Phish Alert app so the interim
// prototype can grow into it, but it is deliberately scoped down for this
// mid-development snapshot. For example, there is no rich `title` field yet —
// the subject line (email) or sender (SMS) is used as the heading instead.

/// Whether a message is a phishing attempt or a legitimate message.
enum MessageClassification { phish, legit }

extension MessageClassificationX on MessageClassification {
  String get label {
    return switch (this) {
      MessageClassification.phish => 'Phish',
      MessageClassification.legit => 'Legit',
    };
  }
}

/// The channel a message arrived through.
enum MessageChannel { email, sms }

extension MessageChannelX on MessageChannel {
  String get label {
    return switch (this) {
      MessageChannel.email => 'Email',
      MessageChannel.sms => 'SMS',
    };
  }
}

/// Difficulty tier for the level a message belongs to.
///
/// `hard` is defined for parity with the finished app's difficulty ladder even
/// though the interim dataset only reaches the `medium` tier so far.
enum MessageDifficulty { easy, medium, hard }

extension MessageDifficultyX on MessageDifficulty {
  String get label {
    return switch (this) {
      MessageDifficulty.easy => 'Easy',
      MessageDifficulty.medium => 'Medium',
      MessageDifficulty.hard => 'Hard',
    };
  }
}

/// An immutable phishing/legitimate message plus the teaching metadata used to
/// give feedback (hint, explanation, suspicious cues, takeaway tip).
class MessageItem {
  const MessageItem({
    required this.id,
    required this.levelNumber,
    required this.difficulty,
    required this.channel,
    required this.sender,
    required this.content,
    required this.classification,
    required this.hint,
    required this.explanation,
    required this.cues,
    required this.takeawayTip,
    this.subject,
  });

  /// Builds a [MessageItem] from the plain-string "content pack" format used by
  /// the bundled dataset. Keeping the parsing here mirrors the finished app and
  /// keeps `sample_messages.dart` readable. An empty [subject] becomes `null`
  /// (SMS messages have no subject line).
  factory MessageItem.contentPack({
    required String id,
    required int levelNumber,
    required String difficulty,
    required String channel,
    required String sender,
    required String subject,
    required String content,
    required String label,
    required String hint,
    required String explanation,
    required List<String> cues,
    required String takeawayTip,
  }) {
    return MessageItem(
      id: id,
      levelNumber: levelNumber,
      difficulty: _difficultyFromString(difficulty),
      channel: _channelFromString(channel),
      sender: sender,
      subject: subject.isEmpty ? null : subject,
      content: content,
      classification: _classificationFromString(label),
      hint: hint,
      explanation: explanation,
      cues: List.unmodifiable(cues),
      takeawayTip: takeawayTip,
    );
  }

  final String id;
  final int levelNumber;
  final MessageDifficulty difficulty;
  final MessageChannel channel;
  final String sender;

  /// Subject line for emails; `null` for SMS messages.
  final String? subject;
  final String content;
  final MessageClassification classification;
  final String hint;
  final String explanation;

  /// Short suspicious/reassuring phrases. For phishing messages these are
  /// highlighted in place within the message text on the feedback screen.
  final List<String> cues;
  final String takeawayTip;

  bool get isEmail => channel == MessageChannel.email;

  String get levelLabel => 'Level $levelNumber';
}

MessageClassification _classificationFromString(String value) {
  return switch (value.toLowerCase()) {
    'phish' => MessageClassification.phish,
    'legit' => MessageClassification.legit,
    _ => throw ArgumentError.value(value, 'label', 'Unknown classification'),
  };
}

MessageChannel _channelFromString(String value) {
  return switch (value.toLowerCase()) {
    'email' => MessageChannel.email,
    'sms' => MessageChannel.sms,
    _ => throw ArgumentError.value(value, 'channel', 'Unknown channel'),
  };
}

MessageDifficulty _difficultyFromString(String value) {
  return switch (value.toLowerCase()) {
    'easy' => MessageDifficulty.easy,
    'medium' => MessageDifficulty.medium,
    'hard' => MessageDifficulty.hard,
    _ => throw ArgumentError.value(value, 'difficulty', 'Unknown difficulty'),
  };
}
